#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

# =========================================================
# LOGGING HELPERS
# =========================================================

FAILED=()
SUCCESS=()

log() { echo -e "\n\033[1;34m[INFO]\033[0m $1"; }
ok() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }
fail() { echo -e "\033[1;31m[FAILED]\033[0m $1"; }

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

# =========================================================
# CHECKERS
# =========================================================

is_installed() {
    command -v "$1" >/dev/null 2>&1
}

has_desktop() {
    local f="$1"
    [ -f "/usr/share/applications/$f" ] || [ -f "$HOME/.local/share/applications/$f" ]
}

# =========================================================
# FAVORITES FUNCTION
# =========================================================

add_to_favorites() {
    local app="$1"

    local current
    current=$(gsettings get org.gnome.shell favorite-apps)

    if [[ "$current" == *"$app"* ]]; then
        echo "[INFO] $app already in favorites"
        return
    fi

    local updated
    updated=$(echo "$current" | sed "s/]$/, '$app']/")

    gsettings set org.gnome.shell favorite-apps "$updated"
    echo "[INFO] Added $app to favorites"
}


install_phpstorm() {
    if [ -d "/opt/phpstorm" ]; then
        ok "PhpStorm already installed — skipping"
        return
    fi

    echo -n "Do you have an active PhpStorm license (Y/n)? "
    read ANSWER

    if [[ "$ANSWER" == "Y" || "$ANSWER" == "y" || "$ANSWER" == "" ]]; then
        # Активная лицензия — скачиваем последнюю версию
        log "Downloading latest PhpStorm"
        wget -O phpstorm.tar.gz https://download.jetbrains.com/webide/PhpStorm-2024.2.tar.gz
    else
        # Нет лицензии — fallback версия
        echo -n "Enter fallback version (e.g., 2023.3.1): "
        read FALLBACK

        log "Downloading fallback PhpStorm version $FALLBACK"
        wget -O phpstorm.tar.gz "https://download.jetbrains.com/webide/PhpStorm-$FALLBACK.tar.gz"
    fi

    install_step "Extract PhpStorm" "
        sudo mkdir -p /opt/phpstorm &&
        sudo tar -xzf phpstorm.tar.gz -C /opt/phpstorm --strip-components=1
    "

    install_step "Create symlink" "
        sudo ln -sf /opt/phpstorm/bin/phpstorm.sh /usr/local/bin/phpstorm
    "

    rm phpstorm.tar.gz
}

# =========================================================
# UPDATE SYSTEM
# =========================================================

log "Updating system"
sudo apt update -y && sudo apt upgrade -y

# =========================================================
# BASE TOOLS
# =========================================================

install_step "curl" "sudo apt install -y curl"
install_step "wget" "sudo apt install -y wget"
install_step "git" "sudo apt install -y git"
install_step "vim" "sudo apt install -y vim"
install_step "nano" "sudo apt install -y nano"
install_step "htop" "sudo apt install -y htop"

# =========================================================
# KATE + THUNDERBIRD
# =========================================================

if is_installed kate; then
    ok "Kate already installed — skipping"
else
    install_step "Kate" "sudo apt install -y kate"
fi

if is_installed thunderbird; then
    ok "Thunderbird already installed — skipping"
else
    install_step "Thunderbird" "sudo apt install -y thunderbird"
fi

# =========================================================
# NEMO
# =========================================================

if is_installed nemo; then
    ok "Nemo already installed — skipping"
else
    install_step "Nemo" "sudo apt install -y nemo"
fi

# =========================================================
# DOCKER (OFFICIAL REPO)
# =========================================================

if is_installed docker; then
    ok "Docker already installed — skipping"
else
    install_step 'Docker prerequisites' "
        sudo apt install -y ca-certificates curl gnupg
    "

    install_step 'Docker GPG key' "
        sudo install -d -m 0755 /etc/apt/keyrings &&
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg |
            sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg &&
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
    "

    install_step 'Docker repo' "
        echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
        https://download.docker.com/linux/ubuntu \
        \$(. /etc/os-release && echo \$VERSION_CODENAME) stable\" |
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    "

    install_step 'Docker Engine' "
        sudo apt update -y &&
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    "

    install_step 'Add user to docker group' "sudo usermod -aG docker \$USER"
fi

# =========================================================
# GOOGLE CHROME
# =========================================================

if has_desktop google-chrome.desktop; then
    ok "Chrome already installed — skipping"
else
    install_step 'Chrome download' "
        wget -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    "
    install_step 'Chrome install' "
        sudo apt install -y ./chrome.deb
    "
    rm -f chrome.deb
fi

# =========================================================
# TELEGRAM (snap)
# =========================================================

if has_desktop telegramdesktop.desktop; then
    ok "Telegram already installed — skipping"
else
    install_step "Telegram Desktop" "sudo snap install telegram-desktop"
fi

# =========================================================
# MEGASYNC (flatpak)
# =========================================================

if is_installed flatpak; then
    ok "Flatpak already installed"
else
    install_step "Flatpak" "sudo apt install -y flatpak"
fi

if flatpak list | grep -q nz.mega.MEGAsync; then
    ok "MegaSync already installed — skipping"
else
    install_step "Flathub repo" "sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"
    install_step "MegaSync" "flatpak install -y flathub nz.mega.MEGAsync"
fi

# =========================================================
# GITKRAKEN
# =========================================================

if has_desktop com.gitkraken.gitkraken.desktop; then
    ok "GitKraken already installed — skipping"
else
    install_step 'GitKraken download' "
        wget -O gitkraken.deb https://release.axocdn.com/linux/gitkraken-amd64.deb
    "
    install_step 'GitKraken install' "
        sudo apt install -y ./gitkraken.deb
    "
    rm -f gitkraken.deb
fi

# =========================================================
# DBEAVER
# =========================================================

if has_desktop dbeaver.desktop; then
    ok "DBeaver already installed — skipping"
else
    install_step 'DBeaver download' "
        wget -O dbeaver.deb https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb
    "
    install_step 'DBeaver install' "
        sudo apt install -y ./dbeaver.deb
    "
    rm -f dbeaver.deb
fi

# =========================================================
# POSTMAN (snap)
# =========================================================

if has_desktop postman_postman.desktop; then
    ok "Postman already installed — skipping"
else
    install_step "Postman" "sudo snap install postman"
fi

# =========================================================
# JETBRAINS TOOLBOX + PHPSTORM
# =========================================================

if is_installed jetbrains-toolbox; then
    ok "Toolbox already installed — skipping"
else
    install_step "Toolbox download" "
        wget -O toolbox.tar.gz https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.3.2.32632.tar.gz
    "
    install_step "Toolbox install" "
        tar -xzf toolbox.tar.gz &&
        ./jetbrains-toolbox*/jetbrains-toolbox &
    "
    rm -f toolbox.tar.gz
fi

install_phpstorm

# =========================================================
# SSH DIRECTORY PREP
# =========================================================

mkdir -p ~/.ssh
chmod 700 ~/.ssh

# =========================================================
# FAVORITES
# =========================================================

add_to_favorites 'google-chrome.desktop'
add_to_favorites 'com.gitkraken.gitkraken.desktop'
add_to_favorites 'org.gnome.Nautilus.desktop'
add_to_favorites 'org.gnome.Terminal.desktop'
add_to_favorites 'org.kde.kate.desktop'
add_to_favorites 'thunderbird.desktop'
add_to_favorites 'dbeaver.desktop'
add_to_favorites 'jetbrains-toolbox.desktop'

# =========================================================
# FINAL REPORT
# =========================================================

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
