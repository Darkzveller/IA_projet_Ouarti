# =============================================================
#  PC GAMING (Windows) - Projet IA F1
#  Installe tout ce qui est automatisable.
#  Le jeu, le patch CSP et le plugin restent MANUELS.
# =============================================================
#  Lancer : clic droit > "Executer avec PowerShell"
#  Si Windows bloque, ouvrir PowerShell et taper d'abord :
#     Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
# =============================================================

$ErrorActionPreference = "Stop"
trap {
    Write-Host ""
    Write-Host "=== ERREUR ===" -ForegroundColor Red
    Write-Host $_ -ForegroundColor Red
    Write-Host ""
    Read-Host "Appuyez sur Entree pour fermer"
    exit 1
}

Write-Host "=== PC GAMING (Windows) - installation ===" -ForegroundColor Cyan

# --- Git ---
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Installation de Git..." -ForegroundColor Yellow
    winget install -e --id Git.Git --accept-source-agreements --accept-package-agreements
} else { Write-Host "Git : deja installe." -ForegroundColor Green }

# --- Miniconda ---
# On cherche conda dans le PATH, puis dans les dossiers d'installation habituels.
function Trouver-Conda {
    if (Get-Command conda -ErrorAction SilentlyContinue) { return $true }
    $chemins = @(
        "$env:USERPROFILE\miniconda3",
        "$env:USERPROFILE\anaconda3",
        "$env:LOCALAPPDATA\miniconda3",
        "$env:LOCALAPPDATA\Continuum\miniconda3",
        "C:\ProgramData\miniconda3",
        "C:\ProgramData\anaconda3"
    )
    foreach ($c in $chemins) {
        if (Test-Path "$c\Scripts\conda.exe") {
            # On l'ajoute au PATH de cette session
            $env:Path = "$c;$c\Scripts;$c\Library\bin;" + $env:Path
            Write-Host "Conda trouve dans $c (ajoute au PATH de cette session)." -ForegroundColor Green
            return $true
        }
    }
    return $false
}

if (Trouver-Conda) {
    Write-Host "Conda : disponible." -ForegroundColor Green
} else {
    Write-Host "Installation de Miniconda..." -ForegroundColor Yellow
    winget install -e --id Anaconda.Miniconda3 --accept-source-agreements --accept-package-agreements

    if (Trouver-Conda) {
        Write-Host "Conda : installe et detecte, on continue." -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "!! Miniconda installe mais introuvable." -ForegroundColor Red
        Write-Host "!! Ouvrez le menu Demarrer, cherchez 'Anaconda Prompt'," -ForegroundColor Red
        Write-Host "!! lancez-le, puis relancez ce script depuis cette fenetre." -ForegroundColor Red
        Read-Host "Appuyez sur Entree pour fermer"
        exit
    }
}

# --- Visual Studio C++ Build Tools (compilation du plugin) ---
$vsInstalle = winget list --id Microsoft.VisualStudio.2022.BuildTools 2>$null | Select-String "BuildTools"
if ($vsInstalle) {
    Write-Host "Build Tools C++ : deja installes." -ForegroundColor Green
} else {
    Write-Host "Installation des Build Tools C++ (long)..." -ForegroundColor Yellow
    winget install -e --id Microsoft.VisualStudio.2022.BuildTools --accept-source-agreements --accept-package-agreements
}
Write-Host "-> Dans l'installeur VS, cocher 'Desktop development with C++'." -ForegroundColor Magenta

# --- Depot de l'interface ---
if (-not (Test-Path ".\assetto_corsa_gym")) {
    Write-Host "Telechargement de assetto_corsa_gym..." -ForegroundColor Yellow
    git clone https://github.com/dasGringuen/assetto_corsa_gym.git
} else { Write-Host "Depot : deja present." -ForegroundColor Green }

# --- Environnement conda ---
# Les versions recentes de conda exigent d'accepter les conditions
# d'utilisation des canaux Anaconda avant toute creation d'environnement.
Write-Host "Acceptation des conditions des canaux conda..." -ForegroundColor Yellow
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main 2>$null
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r 2>$null
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/msys2 2>$null

$cheminEnv = (conda info --base).Trim() + "\envs\p309"

if (Test-Path "$cheminEnv\python.exe") {
    Write-Host "Environnement p309 : deja present." -ForegroundColor Green
} else {
    Write-Host "Creation de l'environnement conda p309 (Python 3.9.13)..." -ForegroundColor Yellow
    # conda-forge : canal libre, evite les problemes de conditions d'utilisation
    conda create -y -n p309 python=3.9.13 -c conda-forge

    # Verification STRICTE : on n'avance pas si l'environnement n'existe pas
    if (-not (Test-Path "$cheminEnv\python.exe")) {
        Write-Host ""
        Write-Host "=== ECHEC : l'environnement p309 n'a pas ete cree ===" -ForegroundColor Red
        Write-Host "Lisez le message d'erreur de conda ci-dessus." -ForegroundColor Red
        Write-Host "Inutile de continuer, la suite echouerait aussi." -ForegroundColor Red
        Read-Host "Appuyez sur Entree pour fermer"
        exit 1
    }
    Write-Host "Environnement p309 cree." -ForegroundColor Green

    conda run -n p309 pip install setuptools==65.5.0 "cython<3"
    conda run -n p309 pip install "wheel<0.40.0"
    conda run -n p309 python -m pip install pip==24.0
}
Write-Host ""
Write-Host "###############################################################" -ForegroundColor Yellow
Write-Host "  ETAPE LONGUE : 5 a 15 minutes (parfois plus)" -ForegroundColor Yellow
Write-Host "  Des dizaines de bibliotheques vont se telecharger." -ForegroundColor Yellow
Write-Host ""
Write-Host "  NE FERMEZ PAS LA FENETRE." -ForegroundColor Red
Write-Host "  Meme si rien ne bouge pendant plusieurs minutes," -ForegroundColor Yellow
Write-Host "  c'est normal : laissez tourner." -ForegroundColor Yellow
Write-Host ""
Write-Host "  Ce sera fini quand vous verrez : === Termine ===" -ForegroundColor Green
Write-Host "###############################################################" -ForegroundColor Yellow
Write-Host ""
Start-Sleep -Seconds 3
conda run -n p309 pip install -r .\assetto_corsa_gym\requirements.txt

# --- PyTorch + CUDA (versions imposees par le depot) ---
Write-Host ""
Write-Host "###############################################################" -ForegroundColor Yellow
Write-Host "  ETAPE TRES LONGUE : PyTorch + CUDA, 10 a 30 minutes" -ForegroundColor Yellow
Write-Host "  Plusieurs Go a telecharger. NE FERMEZ PAS LA FENETRE." -ForegroundColor Red
Write-Host "###############################################################" -ForegroundColor Yellow
Write-Host ""
Start-Sleep -Seconds 3
Write-Host "Installation de PyTorch 1.12.1 + CUDA 11.6..." -ForegroundColor Yellow
conda run -n p309 conda install -y pytorch==1.12.1 cudatoolkit=11.6 -c pytorch -c conda-forge

# --- Grilles d'occupation des circuits ---
if (Test-Path ".\AssettoCorsaGymDataSet\AssettoCorsaConfigs\tracks") {
    Write-Host "Circuits : deja telecharges." -ForegroundColor Green
} else {
Write-Host "Telechargement des circuits (petits fichiers)..." -ForegroundColor Yellow
conda run -n p309 pip install huggingface_hub
conda run -n p309 python -c "from huggingface_hub import snapshot_download; snapshot_download(repo_id='dasgringuen/assettoCorsaGym', repo_type='dataset', local_dir='AssettoCorsaGymDataSet', allow_patterns='AssettoCorsaConfigs/tracks/*')"
}
Write-Host "-> Deplacer les fichiers .pickle vers assetto_corsa_gym\AssettoCorsaConfigs\tracks" -ForegroundColor Magenta

Write-Host ""
Write-Host "=== ETAPES MANUELLES (lire le README.md du pack) ===" -ForegroundColor Magenta
Write-Host "1. Acheter/installer ASSETTO CORSA sur Steam (PAS Competizione, PAS EVO)"
Write-Host "2. Installer Content Manager puis le patch CSP version 0.2.1"
Write-Host "3. Installer le plugin : suivre assetto_corsa_gym\INSTALL.md"
Write-Host "4. Mettre a jour les pilotes GPU"
Write-Host "5. Dans AC : resolution mini, graphismes au minimum, PAS de plein ecran"
Write-Host ""
Write-Host "=== Partie automatisee terminee ===" -ForegroundColor Green
