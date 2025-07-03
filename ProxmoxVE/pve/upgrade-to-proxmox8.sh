#!/bin/bash

set -e
export DEBIAN_FRONTEND=noninteractive

echo "🟢 Starting full unattended upgrade to Proxmox VE 8..."

# Backup APT sources
cp -v /etc/apt/sources.list /etc/apt/sources.list.bak_pve7
cp -v /etc/apt/sources.list.d/pve-install-repo.list /etc/apt/sources.list.d/pve-install-repo.list.bak_pve7 || true

# Remove deprecated bullseye/updates entries
echo "🧹 Cleaning up old bullseye/updates entries..."
find /etc/apt/sources.list /etc/apt/sources.list.d -type f -exec sed -i '/bullseye\/updates/d' {} +

# Disable enterprise repo
if [ -f /etc/apt/sources.list.d/pve-enterprise.list ]; then
    echo "🔒 Disabling enterprise repo..."
    sed -i 's/^deb /# deb /' /etc/apt/sources.list.d/pve-enterprise.list
fi

# Switch from bullseye → bookworm
echo "🔁 Switching sources from bullseye → bookworm..."
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list.d/*.list || true

# Set correct no-subscription and security repos
echo "🌐 Writing new Proxmox 8 and Debian 12 security sources..."
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
echo "deb http://security.debian.org/debian-security bookworm-security main contrib" > /etc/apt/sources.list.d/debian-security.list

# Update and upgrade
echo "📥 Running apt update and full dist-upgrade..."
apt update
apt dist-upgrade -y \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confnew"

echo "✅ Proxmox VE 8 upgrade complete."

# Reboot automatically
echo "🔄 Rebooting system in 5 seconds..."
sleep 5
reboot
