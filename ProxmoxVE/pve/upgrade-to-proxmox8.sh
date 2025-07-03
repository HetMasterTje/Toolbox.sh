#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive

echo "🟢 Starting FULLY AUTOMATIC upgrade to Proxmox VE 8..."

# Backup current APT sources
cp -v /etc/apt/sources.list /etc/apt/sources.list.bak_pve7
cp -v /etc/apt/sources.list.d/pve-install-repo.list /etc/apt/sources.list.d/pve-install-repo.list.bak_pve7 || true

# Clean up deprecated bullseye/updates entries
echo "🧹 Removing deprecated bullseye/updates sources..."
find /etc/apt/sources.list /etc/apt/sources.list.d -type f -exec sed -i '/bullseye\/updates/d' {} +

# Disable enterprise repo if present
if [ -f /etc/apt/sources.list.d/pve-enterprise.list ]; then
    echo "🔒 Disabling Proxmox Enterprise repo..."
    sed -i 's/^deb /# deb /' /etc/apt/sources.list.d/pve-enterprise.list
fi

# Replace bullseye with bookworm
echo "🔁 Updating sources from bullseye → bookworm..."
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list.d/*.list || true

# Set Proxmox 8 no-subscription and security repos
echo "🌐 Writing Proxmox 8 repo sources..."
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
echo "deb http://security.debian.org/debian-security bookworm-security main contrib" > /etc/apt/sources.list.d/debian-security.list

# Update package lists
echo "📦 Running apt update..."
apt update

# Upgrade system
echo "📥 Running full upgrade..."
apt dist-upgrade -y

echo "✅ Proxmox VE 8 upgrade complete."

# Reboot
echo "🔁 Rebooting system in 5 seconds..."
sleep 5
reboot
