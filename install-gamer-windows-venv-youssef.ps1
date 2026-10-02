# =============================================================
#  PC GAMING (Windows) - Projet IA F1
#  Version SANS Conda / Anaconda
#
#  Prerequis :
#    - le venv existe deja dans .\python\py3.9
#    - Python du venv = 3.9.x
#
#  Le script :
#    - verifie/installe Git
#    - verifie/installe Visual Studio C++ Build Tools
#    - clone assetto_corsa_gym si necessaire
#    - installe toutes les dependances dans python\py3.9
#    - installe PyTorch 1.12.1 + CUDA 11.6 via pip
#    - telecharge les donnees de circuits et copie les .pickle
#
#  Assetto Corsa, Content Manager, CSP et le plugin AC restent
#  des etapes manuelles.
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

# Toujours travailler depuis le dossier ou se trouve ce script.
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

$VenvDir = Join-Path $Root "python\py3.9"
$Python  = Join-Path $VenvDir "Scripts\python.exe"
$Pip     = @($Python, "-m", "pip")

$AssettoRepo = Join-Path $Root "assetto_corsa_gym"
$AssettoRequirements = Join-Path $AssettoRepo "requirements.txt"
$ProjectRequirements = Join-Path $Root "python\requirements.txt"

$DatasetDir = Join-Path $Root "AssettoCorsaGymDataSet"
$DownloadedTracks = Join-Path $DatasetDir "AssettoCorsaConfigs\tracks"
$DestinationTracks = Join-Path $AssettoRepo "assetto_corsa_gym\AssettoCorsaConfigs\tracks"

Write-Host "=== PC GAMING (Windows) - installation SANS Conda ===" -ForegroundColor Cyan
Write-Host "Racine : $Root" -ForegroundColor DarkGray
Write-Host "Venv   : $VenvDir" -ForegroundColor DarkGray
Write-Host ""

# -------------------------------------------------------------
# 1. Verifier le venv Python 3.9
# -------------------------------------------------------------
if (-not (Test-Path $Python)) {
    Write-Host "Le venv attendu n'existe pas :" -ForegroundColor Red
    Write-Host "  $Python" -ForegroundColor Red
    Write-Host ""
    Write-Host "Cree d'abord ton environnement py3.9 avec ton Makefile," -ForegroundColor Yellow
    Write-Host "par exemple : make setup PY=3.9" -ForegroundColor Yellow
    exit 1
}

$PythonVersion = (& $Python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')").Trim()
$PythonMajorMinor = (& $Python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')").Trim()

if ($PythonMajorMinor -ne "3.9") {
    Write-Host "Le venv existe, mais il utilise Python $PythonVersion." -ForegroundColor Red
    Write-Host "Ce projet attend Python 3.9.x." -ForegroundColor Red
    exit 1
}

Write-Host "Python $PythonVersion : OK ($Python)" -ForegroundColor Green

# -------------------------------------------------------------
# 2. Git
# -------------------------------------------------------------
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "Git n'est pas installe et winget est introuvable. Installe Git manuellement puis relance le script."
    }

    Write-Host "Installation de Git..." -ForegroundColor Yellow
    winget install -e --id Git.Git --accept-source-agreements --accept-package-agreements

    # Le PATH peut ne pas etre recharge dans la session en cours.
    $GitCandidates = @(
        "$env:ProgramFiles\Git\cmd\git.exe",
        "$env:ProgramFiles\Git\bin\git.exe",
        "$env:LOCALAPPDATA\Programs\Git\cmd\git.exe"
    )
    foreach ($candidate in $GitCandidates) {
        if (Test-Path $candidate) {
            $env:Path = "$(Split-Path $candidate);$env:Path"
            break
        }
    }
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Git a ete installe mais n'est pas encore disponible dans cette session. Rouvre PowerShell puis relance le script."
}
Write-Host "Git : OK" -ForegroundColor Green

# -------------------------------------------------------------
# 3. Visual Studio C++ Build Tools / MSVC
#    GCC/MinGW peut rester installe, mais le projet Windows
#    demande le toolchain C++ de Visual Studio.
# -------------------------------------------------------------
function Test-MsvcCppTools {
    if (Get-Command cl.exe -ErrorAction SilentlyContinue) {
        return $true
    }

    $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    if (Test-Path $vswhere) {
        $installPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath 2>$null
        if ($installPath) {
            return $true
        }
    }

    return $false
}

if (Test-MsvcCppTools) {
    Write-Host "Visual Studio C++ Build Tools / MSVC : OK" -ForegroundColor Green
} else {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "MSVC C++ Build Tools manquent et winget est introuvable. Installe 'Desktop development with C++' manuellement."
    }

    Write-Host "Installation de Visual Studio 2022 Build Tools + C++..." -ForegroundColor Yellow
    Write-Host "Cette etape peut etre longue." -ForegroundColor Yellow

    winget install -e --id Microsoft.VisualStudio.2022.BuildTools `
        --accept-source-agreements `
        --accept-package-agreements `
        --override "--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"

    if (Test-MsvcCppTools) {
        Write-Host "Visual Studio C++ Build Tools / MSVC : installe." -ForegroundColor Green
    } else {
        Write-Host "Build Tools ont ete lances, mais MSVC n'est pas encore detectable." -ForegroundColor Yellow
        Write-Host "Si Visual Studio Installer s'est ouvert, verifie que 'Desktop development with C++' est installe." -ForegroundColor Yellow
    }
}

# -------------------------------------------------------------
# 4. Depot assetto_corsa_gym
# -------------------------------------------------------------
if (-not (Test-Path $AssettoRepo)) {
    Write-Host "Telechargement de assetto_corsa_gym..." -ForegroundColor Yellow
    git clone https://github.com/dasGringuen/assetto_corsa_gym.git $AssettoRepo
} else {
    Write-Host "Depot assetto_corsa_gym : deja present." -ForegroundColor Green
}

if (-not (Test-Path $AssettoRequirements)) {
    throw "requirements.txt introuvable dans $AssettoRepo"
}

# -------------------------------------------------------------
# 5. Preparer pip pour les anciennes dependances du projet
# -------------------------------------------------------------
Write-Host ""
Write-Host "Preparation de pip/setuptools/wheel dans py3.9..." -ForegroundColor Yellow
& $Python -m pip install --upgrade "pip==24.0"
& $Python -m pip install "setuptools==65.5.0" "cython<3" "wheel<0.40.0"

# -------------------------------------------------------------
# 6. Dependances officielles assetto_corsa_gym
# -------------------------------------------------------------
Write-Host ""
Write-Host "Installation des dependances Assetto Corsa Gym dans py3.9..." -ForegroundColor Yellow
& $Python -m pip install -r $AssettoRequirements

# -------------------------------------------------------------
# 7. Dependances du projet personnel (python\requirements.txt)
# -------------------------------------------------------------
if (Test-Path $ProjectRequirements) {
    Write-Host ""
    Write-Host "Installation de python\requirements.txt dans py3.9..." -ForegroundColor Yellow
    & $Python -m pip install -r $ProjectRequirements
} else {
    Write-Host "python\requirements.txt absent : etape ignoree." -ForegroundColor DarkYellow
}

# -------------------------------------------------------------
# 8. PyTorch 1.12.1 + CUDA 11.6 via pip, SANS Conda
#    Commande officielle PyTorch pour Windows/Linux CUDA 11.6.
# -------------------------------------------------------------
Write-Host ""
Write-Host "Installation de PyTorch 1.12.1 + CUDA 11.6 dans py3.9..." -ForegroundColor Yellow
Write-Host "Le telechargement peut faire plusieurs Go." -ForegroundColor Yellow

& $Python -m pip install `
    "torch==1.12.1+cu116" `
    "torchvision==0.13.1+cu116" `
    "torchaudio==0.12.1" `
    --extra-index-url "https://download.pytorch.org/whl/cu116"

# -------------------------------------------------------------
# 9. Hugging Face + donnees de circuits
# -------------------------------------------------------------
Write-Host ""
Write-Host "Installation de huggingface_hub..." -ForegroundColor Yellow
& $Python -m pip install huggingface_hub

if (-not (Test-Path $DownloadedTracks)) {
    Write-Host "Telechargement des donnees de circuits..." -ForegroundColor Yellow

    $DownloadCode = @"
from huggingface_hub import snapshot_download
snapshot_download(
    repo_id='dasgringuen/assettoCorsaGym',
    repo_type='dataset',
    local_dir=r'$DatasetDir',
    allow_patterns='AssettoCorsaConfigs/tracks/*'
)
"@

    & $Python -c $DownloadCode
} else {
    Write-Host "Donnees de circuits : deja telechargees." -ForegroundColor Green
}

# -------------------------------------------------------------
# 10. Copier automatiquement les fichiers .pickle au bon endroit
# -------------------------------------------------------------
if (-not (Test-Path $DestinationTracks)) {
    New-Item -ItemType Directory -Path $DestinationTracks -Force | Out-Null
}

$PickleFiles = Get-ChildItem -Path $DownloadedTracks -Filter "*.pickle" -File -ErrorAction SilentlyContinue
if (-not $PickleFiles) {
    throw "Aucun fichier .pickle trouve dans $DownloadedTracks"
}

Write-Host "Copie des fichiers de circuits vers :" -ForegroundColor Yellow
Write-Host "  $DestinationTracks" -ForegroundColor DarkGray
Copy-Item -Path (Join-Path $DownloadedTracks "*.pickle") -Destination $DestinationTracks -Force

# -------------------------------------------------------------
# 11. Verification finale
# -------------------------------------------------------------
Write-Host ""
Write-Host "Verification de PyTorch..." -ForegroundColor Yellow
& $Python -c "import torch; print('PyTorch :', torch.__version__); print('CUDA PyTorch :', torch.version.cuda); print('GPU CUDA disponible :', torch.cuda.is_available())"

Write-Host ""
Write-Host "Verification des dependances pip..." -ForegroundColor Yellow
& $Python -m pip check

$NbTracks = (Get-ChildItem -Path $DestinationTracks -Filter "*.pickle" -File -ErrorAction SilentlyContinue | Measure-Object).Count

Write-Host ""
Write-Host "===============================================================" -ForegroundColor Green
Write-Host "  INSTALLATION AUTOMATISEE TERMINEE" -ForegroundColor Green
Write-Host "===============================================================" -ForegroundColor Green
Write-Host "Venv utilise :" -ForegroundColor Cyan
Write-Host "  $VenvDir"
Write-Host ""
Write-Host "Assetto Corsa Gym :" -ForegroundColor Cyan
Write-Host "  $AssettoRepo"
Write-Host ""
Write-Host "Circuits (.pickle) : $NbTracks fichier(s)" -ForegroundColor Cyan
Write-Host "  $DestinationTracks"
Write-Host ""
Write-Host "Etapes encore manuelles :" -ForegroundColor Magenta
Write-Host "1. Installer Assetto Corsa (version originale) via Steam"
Write-Host "2. Installer Content Manager"
Write-Host "3. Installer CSP 0.2.1"
Write-Host "4. Installer/configurer le plugin Assetto Corsa Gym"
Write-Host "5. Mettre a jour le pilote NVIDIA si necessaire"
Write-Host ""
