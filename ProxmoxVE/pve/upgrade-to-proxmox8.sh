#!/bin/bash

set -e

echo "🟢 Starting upgrade to Proxmox VE 8..."

# Backup current APT sources
cp -v /etc/apt/sources.list /etc/apt/sources.list.bak_pve7
cp -v /etc/apt/sources.list.d/pve-install-repo.list /etc/apt/sources.list.d/pve-install-repo.list.bak_pve7 || true

# Clean up deprecated bullseye/updates entries if any
echo "🧹 Cleaning up deprecated bullseye/updates entries..."
find /etc/apt/sources.list /etc/apt/sources.list.d -type f -exec sed -i '/bullseye\/updates/d' {} +

# Replace 'bullseye' with 'bookworm' in all relevant APT source files
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list.d/*.list || true

# Add Proxmox 8 no-subscription repo and valid security repo
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
echo "deb http://security.debian.org/debian-security bookworm-security main contrib" > /etc/apt/sources.list.d/debian-security.list

# Update and perform full upgrade
apt update
apt dist-upgrade -y

echo "✅ Proxmox VE 8 upgrade complete. Please reboot your system."
