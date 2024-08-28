#!/bin/bash
#set -eu -o pipefail

# Configuration directories
ME="$HOME"
DOTDIR="$ME/ZPatchFiles"
NVMDIR="$ME/.nvm"
DOTLOCAL="$ME/.local"
CFG="$ME/.config"
BINDIR="$DOTDIR/bin"

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
  echo "trying to link ${source} to ${target}"
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
    "nvim"
  )

  for file in "${home_files[@]}"; do
    link_file "$DOTDIR/homeconfig/${file% *}" "$ME/${file#* }"
  done

  for file in "${config_files[@]}"; do
    link_file "$DOTDIR/dotconfig/$file" "$CFG/$file"
  done
}

install_basic_packages() {
  echo
  print_message "YELLOW" "${msg}""INSTALLING BASIC PACKAGES ..."
  mkdir -p "${BINDIR}"
  # sudo killall packagekitd
  sudo systemctl daemon-reload
  sudo add-apt-repository --yes multiverse
  sudo apt --assume-yes update
  sudo apt --assume-yes install plocate build-essential llvm \
    pkg-config autoconf automake cmake cmake-data autopoint \
    ninja-build gettext libtool libtool-bin g++ meson \
    clang clang-tools ca-certificates curl gnupg lsb-release \
    python-is-python3 ipython3 python3-pip python3-dev gawk \
    unzip lzma tree neofetch git git-lfs zsh tmux gnome-tweaks \
    inxi most ttfautohint v4l2loopback-dkms ffmpeg htop bc fzf \
    ranger libxext-dev ripgrep python3-pynvim xclip libnotify-bin \
    libfontconfig1-dev libfreetype-dev jq pixz hashdeep liblxc-dev \
    libxrandr-dev libxinerama-dev libxcursor-dev libglx-dev libgl-dev \
    screenkey mypaint rofi gimp blender imagemagick net-tools \
    libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev \
    libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev \
    libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev \
    libxcb-shape0-dev libxcb-xrm-dev libxcb-xrm0 libxcb-xkb-dev \
    libconfig-dev libdbus-1-dev libegl-dev libpcre2-dev libpixman-1-dev \
    libx11-xcb-dev libxcb-composite0-dev libxcb-damage0-dev \
    libxcb-dpms0-dev libxcb-glx0-dev libxcb-image0-dev libxcb-present-dev \
    libxcb-render0-dev libxcb-render-util0-dev libxcb-util-dev \
    libxcb-xfixes0-dev uthash-dev libxkbcommon-dev libxkbcommon-x11-dev \
    xutils-dev asciidoc libconfuse-dev libasound2-dev libiw-dev \
    libpulse-dev libnl-genl-3-dev feh notification-daemon dunst \
    python3-sphinx python3-packaging libuv1-dev libcairo2-dev \
    python3-xcbgen libxcb-ewmh-dev libjsoncpp-dev libmpdclient-dev \
    libcurl4-openssl-dev xcb-proto policykit-1-gnome \
    python3-gi gir1.2-gtk-3.0 python3-gi-cairo python3-cairo \
    python3-setuptools python3-babel python3-dbus playerctl \
    fonts-font-awesome slop gir1.2-ayatanaappindicator3-0.1 \
    libgtk-4-dev libx11-dev libxcomposite-dev libxfixes-dev \
    libgl1-mesa-dev libxi-dev libwayland-dev \
    libncurses5-dev libreadline-dev usbview v4l-utils \
    libxrender-dev libglew-dev python3-venv

  # sudo apt --assume-yes install install \
  #     openjdk-8-jre=8u312-b07-0ubuntu1 \
  #     openjdk-8-jre-headless=8u312-b07-0ubuntu1
  sudo updatedb
}

setup_fonts() {
  rm -rf "$ME"/.fonts >/dev/null 2>&1 &&
    ln -s "$DOTDIR"/fonts "$ME"/.fonts ||
    ln -s "$DOTDIR"/fonts "$ME"/.fonts
  fc-cache -f
}

setup_nvim_alias() {
  local shell_rc
  if [ -f "$HOME/.bashrc" ]; then
    shell_rc="$HOME/.bashrc"
  elif [ -f "$HOME/.zshrc" ]; then
    shell_rc="$HOME/.zshrc"
  else
    print_message "RED" "No suitable shell configuration file found."
    return 1
  fi

  print_message "YELLOW" "Setting up nvim alias in $shell_rc..."

  echo 'alias nvim="/usr/local/bin/nvim"' >>"$shell_rc"
  source "$shell_rc"
}

remove_neovim() {
  if command -v nvim >/dev/null 2>&1; then
    print_message "YELLOW" "REMOVING NEOVIM..."

    # Check for package manager installation and remove
    if dpkg -l | grep -q 'neovim'; then
      sudo apt remove -y neovim
    elif brew list --formula | grep -q 'neovim'; then
      brew uninstall neovim
    elif pacman -Qs neovim >/dev/null; then
      sudo pacman -Rns neovim
    fi

    rm -rf ~/.config/nvim ~/.local/share/nvim ~/.cache/nvim "$DOTDIR/neovim"

    print_message "GREEN" "Neovim has been removed."
  else
    print_message "RED" "No existing Neovim installation found."
  fi
}

install_lazygit() {
  echo
  if lazygit --version >/dev/null 2>&1; then
    print_message "GREEN" "Lazygit already installed."
  else
    print_message "GREEN" "Installing Lazygit..."
    cd "$DOTDIR" || exit
    mkdir temp
    cd temp || exit
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    cd "$DOTDIR" || exit
  fi
}

install_neovim() {
  #remove_neovim
  install_lazygit

  if ! command -v nvim >/dev/null 2>&1; then
    print_message "YELLOW" "INSTALLING NEOVIM ..."
    git clone https://github.com/neovim/neovim "$DOTDIR/neovim"
    cd "$DOTDIR/neovim" || exit
    git checkout v0.10.1
    make CMAKE_BUILD_TYPE=RelWithDebInfo -j"$(nproc)"
    sudo make install
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

install_vscode() {
  print_message "YELLOW" "INSTALLING VSCODE..."
  sudo apt --assume-yes install software-properties-common apt-transport-https wget
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] \
            https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
  sudo apt --assume-yes update
  sudo apt --assume-yes install code
}

install_discord() {
  sudo apt install discord
}

bomba_patch() {
  echo "100% atualizado"
  sleep 2
  echo "É ruim de aturar"
  sleep 2
  echo "Patch script virou moda"
  sleep 2
  echo "todo mundo quer instalar"
}

main() {
  link_dotfiles
  setup_fonts
  install_basic_packages
  install_neovim
  install_docker
  install_vscode
  install_discord
  bomba_patch
}

main
