#!/bin/bash
#set -eu -o pipefail

# Configuration directories
ME="$HOME"
DOTDIR="$ME/ZPatchFiles"
NVMDIR="$ME/.nvm"
DOTLOCAL="$ME/.local"
CFG="$ME/.config"

# Color definitions
declare -A COLORS=(
  [RED]=$'\033[0;31m'
  [GREEN]=$'\033[0;32m'
  [CYAN]=$'\033[0;36m'
  [YELLOW]=$'\033[0;33m'
  [OFF]=$'\033[0m'
)

print_message() {
  local color=$1
  shift
  echo -e "${COLORS[$color]}$*${COLORS[OFF]}"
}

link_file() {
  local source=$1
  local target=$2
  sudo rm -rf "$target"
  ln -s "$source" "$target"
}

link_dotfiles() {
  print_message "YELLOW" "LINKING DOTFILES ..."
  mkdir -p "$DOTLOCAL"
  
  home_files=(
    "profile/profile .profile"
    "bash/bashrc .bashrc"
    "bash/inputrc .inputrc"
    "zsh/zshrc .zshrc"
    "zsh/zshenv .zshenv"
    "tmux/tmux.conf .tmux.conf"
    "x/XCompose .XCompose"
    "themes .themes"
    "mame .mame"
    "darkplaces .darkplaces"
    "lutris .local/share/lutris"
    "attract .attract"
    "vst3 .vst3"
  )
  
  config_files=(
    "scummvm"
    "screenkey"
    "nvim"
    "i3"
    "i3status"
    "polybar"
    "alacritty"
    "picom"
    "dunst"
    "neofetch"
  )
  
  for file in "${home_files[@]}"; do
    link_file "$DOTDIR/homeconfig/${file% *}" "$ME/${file#* }"
  done
  
  for file in "${config_files[@]}"; do
    link_file "$DOTDIR/dotconfig/$file" "$CFG/$file"
  done
}

install_packages() {
  print_message "YELLOW" "INSTALLING BASIC PACKAGES ..."
  sudo systemctl daemon-reload
  sudo add-apt-repository --yes multiverse
  sudo apt update
  sudo apt install -y plocate build-essential llvm pkg-config cmake ninja-build \
    python3-pip curl git zsh tmux htop neofetch ripgrep fzf jq
  sudo updatedb
}

remove_neovim() {
    if command -v nvim >/dev/null 2>&1; then
        print_message "YELLOW" "REMOVING NEOVIM..."
        
        # Check for package manager installation and remove
        if dpkg -l | grep -q 'neovim'; then
            sudo apt remove -y neovim
        elif brew list --formula | grep -q 'neovim'; then
            brew uninstall neovim
        elif pacman -Qs neovim > /dev/null; then
            sudo pacman -Rns neovim
        fi

        # Remove possible directories left behind
        rm -rf ~/.config/nvim ~/.local/share/nvim ~/.cache/nvim

        print_message "GREEN" "Neovim has been removed."
    else
        print_message "RED" "No existing Neovim installation found."
    fi
}


install_neovim() {
  remove_neovim

  if ! command -v nvim >/dev/null 2>&1; then
    print_message "YELLOW" "INSTALLING NEOVIM ..."
    git clone https://github.com/neovim/neovim "$DOTDIR/neovim"
    cd "$DOTDIR/neovim" || exit
    git checkout v0.10.1
    make CMAKE_BUILD_TYPE=RelWithDebInfo -j"$(nproc)"
    sudo make install
  else
    print_message "GREEN" "Neovim already installed."
  fi
}

install_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    print_message "YELLOW" "INSTALLING DOCKER ..."
    sudo apt update
    sudo apt install -y ca-certificates curl
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc >/dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo usermod -aG docker "$USER"
  else
    print_message "GREEN" "Docker already installed."
  fi
}

bomba_patch() {
  echo "100% atualizado"
  sleep 2
  echo "É ruim de aturar"
  sleep 2
  echo "Bombapatch virou moda"
  sleep 2
  echo "todo mundo quer instalar"
}

main() {
  link_dotfiles
  install_packages
  install_neovim
  install_docker
  bomba_patch
}

main
 
