#!/bin/bash

# YOU MUST BE ROOT
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

set -e

echo "[*] Updating system..."
apt update && apt upgrade -y

echo "[*] Installing required packages..."
apt install -y ca-certificates curl gnupg lsb-release

echo "[*] Setting up Docker's GPG key..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "[*] Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "[*] Updating package index..."
apt update

echo "[*] Installing Docker packages..."
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "[✔] Docker installation complete!"
docker --version
docker compose version
