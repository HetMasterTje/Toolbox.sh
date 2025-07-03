#!/bin/bash

set -e

echo "🟡 Starting upgrade to Proxmox VE 8..."

# Backup sources
cp -v /etc/apt/sources.list /etc/apt/sources.list.bak_pve7
cp -v /etc/apt/sources.list.d/pve-install-repo.list /etc/apt/sources.list.d/pve-install-repo.list.bak_pve7 || true

# Update apt sources to bookworm (Debian 12)
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list.d/*.list || true

# Replace with Proxmox 8 repo
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
echo "deb http://security.debian.org/debian-security bookworm-security main contrib" > /etc/apt/sources.list.d/debian-security.list

# Update and upgrade
apt update
apt full-upgrade -y

echo "✅ Proxmox VE 8 upgrade complete. Reboot your system."
