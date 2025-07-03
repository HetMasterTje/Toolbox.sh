#!/bin/bash

set -e

echo "🟡 Starting upgrade to Proxmox VE 7..."

# Backup sources
cp -v /etc/apt/sources.list /etc/apt/sources.list.bak
cp -v /etc/apt/sources.list.d/pve-enterprise.list /etc/apt/sources.list.d/pve-enterprise.list.bak || true

# Update apt sources to bullseye (Debian 11)
sed -i 's/buster/bullseye/g' /etc/apt/sources.list
sed -i 's/buster/bullseye/g' /etc/apt/sources.list.d/*.list || true

# Replace enterprise with no-subscription
echo "deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
echo "deb http://security.debian.org/debian-security bullseye-security main contrib" > /etc/apt/sources.list.d/debian-security.list

# Update and upgrade
apt update
apt install -y proxmox-upgrade

# Run upgrade
proxmox-upgrade

echo "✅ Proxmox VE 7 upgrade complete. Reboot your system."
