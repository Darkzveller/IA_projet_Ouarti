-- OUARTI Checkpoint V3.2: sauvegarde complete lorsque supportee, sinon sauvegarde de pose.
-- Le mode pose est un fallback EXPERIMENTAL et ne sauvegarde PAS l'etat physique complet.
-- Toutes les commandes sont reservees aux sessions locales, jamais en multijoueur.

local bridgeDir = ac.getFolder(ac.FolderID.ACDocuments) .. '/OUARTI_checkpoint_v3'
io.createDir(bridgeDir)
local cmdPath = bridgeDir .. '/command.txt'
local statusPath = bridgeDir .. '/status.txt'

local lastID = nil
local snapshot = nil
local snapshotMode = nil
local snapshotTrack = nil
local snapshotCar = nil
local stateLabel = 'PAS DE CHECKPOINT'
local throttle = 0
local pendingTeleport = nil

local function status(id, code, detail)
  local safeDetail = tostring(detail or ''):gsub('[\r\n|]', ' ')
  io.save(statusPath, tostring(id) .. '|' .. code .. '|' .. safeDetail)
end

local function isOffline()
  local sim = ac.getSim()
  return sim ~= nil and not sim.isOnlineRace
end

local function sameSession()
  return snapshot ~= nil and snapshotTrack == ac.getTrackID()
     and snapshotCar == ac.getCarID(0)
end

local function canSaveFullState()
  return type(ac.saveCarStateAsync) == 'function'
     and type(ac.loadCarState) == 'function'
end

local function canTeleport()
  if physics == nil or type(physics.setCarPosition) ~= 'function'
      or type(physics.allowed) ~= 'function' then
    return false
  end
  local ok, allowed = pcall(physics.allowed)
  return ok and allowed == true
end

local function capabilities()
  return 'full_snapshot=' .. tostring(canSaveFullState())
     .. '; position_fallback=' .. tostring(canTeleport())
     .. '; offline=' .. tostring(isOffline())
end

local function capturePose(id)
  if not canTeleport() then
    status(id, 'ERROR', 'Pas de snapshot complet ni de positionnement via physics.setCarPosition: '
      .. capabilities() .. '. Mettre a jour CSP ou activer un contexte physique compatible.')
    return
  end
  local car = ac.getCar(0)
  if not car or not car.position or not car.look then
    status(id, 'ERROR', 'Position ou direction du vehicule indisponible')
    return
  end
  -- Copier les valeurs : ne pas garder les references vers les structures vivantes.
  snapshot = {
    pos = vec3(car.position.x, car.position.y, car.position.z),
    look = vec3(car.look.x, car.look.y, car.look.z),
  }
  snapshotMode = 'pose'
  snapshotTrack = ac.getTrackID()
  snapshotCar = ac.getCarID(0)
  stateLabel = 'POSITION SEULEMENT: ' .. tostring(snapshotTrack) .. ' / ' .. tostring(snapshotCar)
  status(id, 'SAVED', stateLabel .. ' (sans sauvegarde physique)')
end

local function saveCheckpoint(id)
  if not isOffline() then
    status(id, 'ERROR', 'Sauvegarde interdite en session en ligne')
    return
  end
  if canSaveFullState() then
    status(id, 'PENDING', 'Sauvegarde physique CSP en cours')
    local ok, err = pcall(ac.saveCarStateAsync, function(saveError, data)
      if saveError or data == nil then
        stateLabel = 'ERREUR SAUVEGARDE'
        status(id, 'ERROR', 'saveCarStateAsync: ' .. tostring(saveError or 'donnees absentes'))
        return
      end
      snapshot = data
      snapshotMode = 'full'
      snapshotTrack = ac.getTrackID()
      snapshotCar = ac.getCarID(0)
      stateLabel = 'ETAT COMPLET: ' .. tostring(snapshotTrack) .. ' / ' .. tostring(snapshotCar)
      status(id, 'SAVED', stateLabel)
    end)
    if not ok then
      status(id, 'ERROR', 'Echec appel saveCarStateAsync: ' .. tostring(err))
    end
  else
    capturePose(id)
  end
end

local function loadCheckpoint(id)
  if not isOffline() then
    status(id, 'ERROR', 'Restauration interdite en session en ligne')
    return
  end
  if not sameSession() then
    status(id, 'ERROR', 'Pas de checkpoint pour ce circuit/vehicule')
    return
  end
  if snapshotMode == 'full' then
    if type(ac.loadCarState) ~= 'function' then
      status(id, 'ERROR', 'ac.loadCarState indisponible')
      return
    end
    local ok, result = pcall(ac.loadCarState, snapshot, 30)
    if not ok or result == false then
      status(id, 'ERROR', 'loadCarState: ' .. tostring(result))
    else
      status(id, 'LOAD_REQUESTED', 'Etat complet demande, verification telemetrie requise')
    end
  elseif snapshotMode == 'pose' then
    if not canTeleport() then
      status(id, 'ERROR', 'Teletransportation indisponible ou physique non autorisee')
      return
    end
    if pendingTeleport ~= nil then
      status(id, 'ERROR', 'Restauration deja en cours')
      return
    end
    if type(ac.resetCar) ~= 'function' then
      status(id, 'ERROR', 'ac.resetCar indisponible; impossible de stabiliser la voiture avant teleportation')
      return
    end
    -- Reinitialiser les vitesses/forces d'abord, puis remettre le vehicule au checkpoint.
    -- Cela reste un mode de compatibilite, pas un vrai snapshot complet.
    local ok, err = pcall(ac.resetCar)
    if not ok then
      status(id, 'ERROR', 'ac.resetCar a echoue: ' .. tostring(err))
      return
    end
    pendingTeleport = { id = id, remaining = 0.30 }
    status(id, 'PENDING', 'Reset classique puis re-positionnement en cours')
  else
    status(id, 'ERROR', 'Mode de sauvegarde inconnu')
  end
end

local function advanceTeleport(dt)
  if pendingTeleport == nil then return end
  pendingTeleport.remaining = pendingTeleport.remaining - (dt or 0)
  if pendingTeleport.remaining > 0 then return end
  local id = pendingTeleport.id
  pendingTeleport = nil
  if not isOffline() or not sameSession() or not canTeleport() then
    status(id, 'ERROR', 'Contexte incompatible au moment du repositionnement')
    return
  end
  local ok, result = pcall(physics.setCarPosition, 0,
    vec3(snapshot.pos.x, snapshot.pos.y, snapshot.pos.z),
    vec3(snapshot.look.x, snapshot.look.y, snapshot.look.z))
  if not ok or result == false then
    status(id, 'ERROR', 'physics.setCarPosition: ' .. tostring(result))
  else
    status(id, 'LOAD_REQUESTED',
      'POSITION SEULEMENT repositionnee, la telemetrie doit valider la position et la vitesse')
  end
end

local function processCommand(line)
  local id, op = line:match('^([%w_-]+)|([A-Z_]+)$')
  if not id or not op or id == lastID then return end
  lastID = id
  if op == 'PING' then
    status(id, 'PONG', 'OUARTI CSP app active - V3.2')
  elseif op == 'CAPABILITIES' then
    status(id, 'CAPABILITIES', capabilities())
  elseif op == 'STATUS' then
    status(id, sameSession() and 'SAVED' or 'NOT_SAVED', stateLabel)
  elseif op == 'SAVE' then
    saveCheckpoint(id)
  elseif op == 'LOAD' then
    loadCheckpoint(id)
  else
    status(id, 'ERROR', 'Commande inconnue')
  end
end

function script.update(dt)
  advanceTeleport(dt)
  throttle = throttle + (dt or 0)
  if throttle < 0.08 then return end
  throttle = 0
  local line = io.load(cmdPath, '')
  if type(line) ~= 'string' then return end
  line = line:gsub('%s+$', '')
  if line ~= '' then processCommand(line) end
end

function script.windowMain(dt)
  ui.text('OUARTI Checkpoint V3.2')
  ui.separator()
  ui.text('Etat: ' .. stateLabel)
  ui.text('Capacites: ' .. capabilities())
  ui.textWrapped('Le fallback POSITION SEULEMENT ne restaure pas tous les parametres physiques.')
end
