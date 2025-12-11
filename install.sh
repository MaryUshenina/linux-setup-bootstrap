#!/bin/bash

set -e

echo "========== Updating system =========="
sudo apt update
sudo apt upgrade -y

echo "========== Installing base tools =========="
sudo apt install -y \
    curl wget git htop nano vim \
    ca-certificates software-properties-common apt-transport-https \
    gpg lsb-release

echo "========== Installing Nemo (F3 two-panel manager) =========="
sudo apt install -y nemo

echo "========== Installing Docker =========="
# Remove old versions
sudo apt remove -y docker docker-engine docker.io containerd runc || true

# Install dependencies
sudo apt install -y ca-certificates curl gnupg

# Add Docker’s official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repo
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update and install
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Allow running Docker without sudo
sudo usermod -aG docker $USER

echo "========== Installing Chrome =========="
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O chrome.deb
sudo apt install -y ./chrome.deb
rm chrome.deb

echo "========== Installing Telegram =========="
sudo apt install -y telegram-desktop

echo "========== Installing MegaSync =========="
# Add Mega repo
wget -qO - https://mega.nz/linux/MEGAsync/xUbuntu_24.04/Release.key | sudo apt-key add -
echo "deb https://mega.nz/linux/MEGAsync/xUbuntu_24.04/ ./" | sudo tee /etc/apt/sources.list.d/megasync.list

sudo apt update
sudo apt install -y megasync

echo "========== Installing GitKraken =========="
wget https://release.axocdn.com/linux/gitkraken-amd64.deb -O gitkraken.deb
sudo apt install -y ./gitkraken.deb
rm gitkraken.deb

echo "========== Installing DBeaver =========="
wget https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb -O dbeaver.deb
sudo apt install -y ./dbeaver.deb
rm dbeaver.deb

echo "========== Installing Postman =========="
sudo snap install postman

echo "========== Installing JetBrains Toolbox (PHPStorm installer) =========="
wget https://download-cdn.jetbrains.com/toolbox/jetbrains-toolbox-2.3.2.32632.tar.gz -O toolbox.tar.gz
tar -xzf toolbox.tar.gz
rm toolbox.tar.gz

TOOLBOX_DIR=$(find . -maxdepth 1 -type d -name "jetbrains-toolbox*" | head -n 1)

if [ -d "$TOOLBOX_DIR" ]; then
    echo "Running JetBrains Toolbox installer..."
    "$TOOLBOX_DIR"/jetbrains-toolbox &
else
    echo "ERROR: Toolbox directory not found."
fi

echo "========== ALL DONE =========="
echo "Restart your terminal or log out and log in again for Docker group changes."
