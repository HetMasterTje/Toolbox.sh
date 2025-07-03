#!/bin/bash

set -e

echo "🟢 Starting upgrade to Proxmox VE 8..."

# Backup current APT sources
cp -v /etc/apt/sources.list /etc/apt/sources.list.bak_pve7
cp -v /etc/apt/sources.list.d/pve-install-repo.list /etc/apt/sources.list.d/pve-install-repo.list.bak_pve7 || true

# Clean up deprecated bullseye/updates entries
echo "🧹 Cleaning up deprecated bullseye/updates entries..."
find /etc/apt/sources.list /etc/apt/sources.list.d -type f -exec sed -i '/bullseye\/updates/d' {} +

# Disable Proxmox Enterprise repo if present
if [ -f /etc/apt/sources.list.d/pve-enterprise.list ]; then
    echo "🔒 Disabling Proxmox enterprise repo (no subscription)..."
    sed -i 's/^deb /# deb /' /etc/apt/sources.list.d/pve-enterprise.list
fi

# Replace 'bullseye' with 'bookworm' in all source files
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list.d/*.list || true

# Set Proxmox 8 no-subscription repo and security repo
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
echo "deb http://security.debian.org/debian-security bookworm-security main contrib" > /etc/apt/sources.list.d/debian-security.list

# Update and upgrade
apt update
apt dist-upgrade -y

echo "✅ Proxmox VE 8 upgrade complete. Please reboot your system."
