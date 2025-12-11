#!/usr/bin/env bash

# ==========================
#  CONFIG + GLOBALS
# ==========================

FAILED=()
SUCCESS=()

log() {
    echo -e "\n\033[1;34m[INFO]\033[0m $1"
}

ok() {
    echo -e "\033[1;32m[SUCCESS]\033[0m $1"
}

fail() {
    echo -e "\033[1;31m[FAILED]\033[0m $1"
}

# Функция для надёжного выполнения шагов
install_step() {
    local name="$1"
    shift
    local cmd="$@"

    log "Installing: $name"

    if eval "$cmd"; then
        ok "$name installed"
        SUCCESS+=("$name")
    else
        fail "$name not installed"
        FAILED+=("$name")
    fi
}

# ==========================
#  START
# ==========================

log "Updating system"
sudo apt update && sudo apt upgrade -y


# ==========================
# BASE TOOLS
# ==========================

install_step "curl" "sudo apt install -y curl"
install_step "wget" "sudo apt install -y wget"
install_step "git" "sudo apt install -y git"
install_step "vim" "sudo apt install -y vim"
install_step "nano" "sudo apt install -y nano"
install_step "htop" "sudo apt install -y htop"


# ==========================
# NEMO (F3 двухпанельный менеджер)
# ==========================

install_step "Nemo file manager" "sudo apt install -y nemo"


# ==========================
# DOCKER (официальный способ)
# ==========================

install_step "Docker prerequisites" "sudo apt install -y ca-certificates curl gnupg"

install_step "Docker GPG key" "
    sudo install -m 0755 -d /etc/apt/keyrings &&
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg |
      sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
"

install_step "Docker repo" "
    echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    \$(. /etc/os-release && echo \$VERSION_CODENAME) stable\" |
    sudo tee /etc/apt/sources.list.d/docker.list
"

install_step "Docker Engine" "
    sudo apt update &&
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
"

install_step "Add user to docker group" "sudo usermod -aG docker \$USER"


# ==========================
# GOOGLE CHROME
# ==========================

install_step "Chrome download" "
    wget -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
"

install_step "Chrome install" "
    sudo apt install -y ./chrome.deb
"

rm -f chrome.deb



# ==========================
# TELEGRAM
# ==========================

install_step "Telegram Desktop" "sudo apt install -y telegram-desktop"


# ==========================
# MEGASYNC
# ==========================

install_step "MegaSync repo" "
    wget -qO - https://mega.nz/linux/MEGAsync/xUbuntu_24.04/Release.key |
      sudo gpg --dearmor -o /usr/share/keyrings/megasync.gpg &&
    echo \"deb [signed-by=/usr/share/keyrings/megasync.gpg] https://mega.nz/linux/MEGAsync/xUbuntu_24.04/ ./\" |
      sudo tee /etc/apt/sources.list.d/megasync.list
"

install_step "MegaSync install" "
    sudo apt update &&
    sudo apt install -y megasync
"


# ==========================
# GITKRAKEN
# ==========================

install_step "GitKraken download" "
    wget -O gitkraken.deb https://release.axocdn.com/linux/gitkraken-amd64.deb
"

install_step "GitKraken install" "
    sudo apt install -y ./gitkraken.deb
"

rm -f gitkraken.deb


# ==========================
# DBEAVER
# ==========================

install_step "DBeaver download" "
    wget -O dbeaver.deb https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb
"

install_step "DBeaver install" "
    sudo apt install -y ./dbeaver.deb
"

rm -f dbeaver.deb


# ==========================
# POSTMAN
# ==========================

install_step "Postman" "sudo snap install postman"



# ==========================
# FINAL REPORT
# ==========================

echo -e "\n==========================================="
echo -e "\033[1;32m   INSTALLATION COMPLETE\033[0m"
echo "==========================================="

echo -e "\n\033[1;34mInstalled successfully:\033[0m"
printf ' - %s\n' "${SUCCESS[@]}"

echo -e "\n\033[1;31mFailed to install:\033[0m"
if [ ${#FAILED[@]} -eq 0 ]; then
    echo " - None 🎉"
else
    printf ' - %s\n' "${FAILED[@]}"
fi

echo -e "\nAll done!"
