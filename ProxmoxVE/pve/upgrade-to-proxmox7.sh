#!/bin/bash

set -e

echo "🟡 Starting upgrade to Proxmox VE 7..."

# Backup sources
cp -v /etc/apt/sources.list /etc/apt/sources.list.bak
cp -v /etc/apt/sources.list.d/pve-enterprise.list /etc/apt/sources.list.d/pve-enterprise.list.bak || true

# Remove invalid bullseye/updates entries
echo "🧹 Cleaning up deprecated bullseye/updates entries..."
find /etc/apt/sources.list /etc/apt/sources.list.d -type f -exec sed -i '/bullseye\/updates/d' {} +

# Update sources to bullseye (Debian 11)
sed -i 's/buster/bullseye/g' /etc/apt/sources.list
sed -i 's/buster/bullseye/g' /etc/apt/sources.list.d/*.list || true

# Add no-subscription Proxmox repo and valid security repo
echo "deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
echo "deb http://security.debian.org/debian-security bullseye-security main contrib" > /etc/apt/sources.list.d/debian-security.list

# Update & upgrade
apt update
apt dist-upgrade -y

echo "✅ Proxmox VE 7 packages installed. Reboot to complete the upgrade."
