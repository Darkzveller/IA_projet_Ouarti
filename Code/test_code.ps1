# $GAME = "C:\Program Files\Assetto-Corsa-SteamRIP.com\Assetto Corsa"

# $LOG = Join-Path $GAME "sensor_par_subprocess_log.txt"

# if (Test-Path $LOG) {
#     Get-Content $LOG -Tail 80
# } else {
#     Write-Host "Journal de capture introuvable à cet emplacement"
# }



# $FICHIER = "C:\Users\elkat\Documents\Github\IA_projet_Ouarti_ds_github\Code\reports\ppo_vision_pedales_v2\ppo_steps.jsonl"

# $donnees = Get-Content $FICHIER | ConvertFrom-Json

# $donnees |
#     Group-Object episode_id |
#     ForEach-Object {
#         $mesures = $_.Group

#         [PSCustomObject]@{
#             Episode = [int]$_.Name
#             Actions = $mesures.Count
#             Reward = [math]::Round(($mesures | Measure-Object reward -Sum).Sum, 2)
#             Progression = [math]::Round(($mesures | Measure-Object progress_m -Sum).Sum, 2)
#             VitesseMaxKmh = [math]::Round(($mesures | Measure-Object speed_ms -Maximum).Maximum * 3.6, 1)
#         }
#     } |
#     Select-Object -Last 10 |
#     Format-Table -AutoSize


# $APP = "C:\Program Files\Assetto-Corsa-SteamRIP.com\Assetto Corsa\apps\lua\OUARTICheckpoint"

# Get-ChildItem $APP | Select-Object Name, Length



# $LOGS = "$env:USERPROFILE\Documents\Assetto Corsa\logs"

# Get-Content "$LOGS\custom_shaders_patch.log" -Tail 1000 |
#     Select-String -Pattern "OUARTI|Checkpoint|ERROR|Lua|failed" |
#     Select-Object -Last 40


# Get-ChildItem "$env:USERPROFILE\Documents\Assetto Corsa\logs" |
#     Where-Object Name -Match "lua|shader|error"



bridge = CheckpointBridge()

try:
    print("Réponse CSP :", bridge.request("PING"))
except Exception as e:
    print("Communication impossible :", e)