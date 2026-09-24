#!/usr/bin/env bash
# =============================================================
#  PC GAMING (Linux) - Projet IA F1
#  Teste par les auteurs du depot sur Ubuntu 24.04.
#  Le jeu, Proton, le patch CSP et le plugin restent MANUELS.
# =============================================================
#  Lancer :  chmod +x install-gamer-linux.sh && ./install-gamer-linux.sh
# =============================================================
set -e

echo "=== PC GAMING (Linux) - installation ==="

# --- Git ---
if ! command -v git &> /dev/null; then
    echo ">> Installation de Git..."
    sudo apt update && sudo apt install -y git
else
    echo "Git : deja installe."
fi

# --- Outils de compilation ---
echo ">> Installation des outils de compilation..."
sudo apt install -y build-essential wget

# --- Miniconda ---
if ! command -v conda &> /dev/null; then
    echo ">> Installation de Miniconda..."
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
    bash /tmp/miniconda.sh -b -p "$HOME/miniconda3"
    "$HOME/miniconda3/bin/conda" init bash
    echo "!! Fermez et rouvrez le terminal, puis relancez ce script."
    exit 0
else
    echo "Conda : deja installe."
fi

# --- Depot de l'interface ---
if [ ! -d "./assetto_corsa_gym" ]; then
    echo ">> Telechargement de assetto_corsa_gym..."
    git clone https://github.com/dasGringuen/assetto_corsa_gym.git
else
    echo "Depot : deja present."
fi

# --- Environnement conda ---
echo ">> Acceptation des conditions des canaux conda..."
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main 2>/dev/null || true
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r 2>/dev/null || true

CHEMIN_ENV="$(conda info --base)/envs/p309"

if [ -x "$CHEMIN_ENV/bin/python" ]; then
    echo "Environnement p309 : deja present."
else
    echo ">> Creation de l'environnement conda p309 (Python 3.9.13)..."
    conda create -y -n p309 python=3.9.13 -c conda-forge

    if [ ! -x "$CHEMIN_ENV/bin/python" ]; then
        echo ""
        echo "=== ECHEC : l'environnement p309 n'a pas ete cree ==="
        echo "Lisez le message d'erreur de conda ci-dessus."
        exit 1
    fi
    echo "Environnement p309 cree."

    conda run -n p309 pip install setuptools==65.5.0 "cython<3"
    conda run -n p309 pip install "wheel<0.40.0"
    conda run -n p309 python -m pip install pip==24.0
fi
echo ""
echo "###############################################################"
echo "  ETAPE LONGUE : 5 a 15 minutes (parfois plus)"
echo "  Des dizaines de bibliotheques vont se telecharger."
echo ""
echo "  NE FERMEZ PAS LE TERMINAL."
echo "  Meme si rien ne bouge pendant plusieurs minutes, c'est normal."
echo ""
echo "  Ce sera fini quand vous verrez : === Partie automatisee terminee ==="
echo "###############################################################"
echo ""
sleep 3
conda run -n p309 pip install -r ./assetto_corsa_gym/requirements.txt

# --- PyTorch + CUDA ---
echo ""
echo "###############################################################"
echo "  ETAPE TRES LONGUE : PyTorch + CUDA, 10 a 30 minutes"
echo "  Plusieurs Go a telecharger. NE FERMEZ PAS LE TERMINAL."
echo "###############################################################"
echo ""
sleep 3
echo ">> Installation de PyTorch 1.12.1 + CUDA 11.6..."
conda run -n p309 conda install -y pytorch==1.12.1 cudatoolkit=11.6 -c pytorch -c conda-forge

# --- Circuits ---
if [ -d "./AssettoCorsaGymDataSet/AssettoCorsaConfigs/tracks" ]; then
    echo "Circuits : deja telecharges."
else
    echo ">> Telechargement des circuits..."
    conda run -n p309 pip install huggingface_hub
    conda run -n p309 python -c "from huggingface_hub import snapshot_download; snapshot_download(repo_id='dasgringuen/assettoCorsaGym', repo_type='dataset', local_dir='AssettoCorsaGymDataSet', allow_patterns='AssettoCorsaConfigs/tracks/*')"
fi
echo ">> Deplacer les .pickle vers assetto_corsa_gym/AssettoCorsaConfigs/tracks"

echo ""
echo "=== ETAPES MANUELLES (lire le README.md du pack) ==="
echo "1. Installer Steam puis ASSETTO CORSA (PAS Competizione, PAS EVO)"
echo "2. Installer Proton GE-Proton9-2 via ProtonUp-Qt"
echo "   Steam > AC > Proprietes > Compatibilite > forcer GE-Proton9-2"
echo "3. Lien symbolique du dossier config + Content Manager + CSP 0.2.1"
echo "4. Copier le plugin et les fichiers windows-libs (voir INSTALL_Linux.md)"
echo "5. Dans AC : resolution mini, graphismes au minimum, PAS de plein ecran"
echo ""
echo "=== Partie automatisee terminee ==="
