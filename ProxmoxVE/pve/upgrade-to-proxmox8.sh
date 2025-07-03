#!/bin/bash

set -e

echo "🟢 Proxmox VE 7 ➜ 8 Upgrade Script"

# Prompt user to continue
read -p "❓ Are you sure you want to upgrade to Proxmox VE 8? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "❌ Upgrade cancelled."
    exit 1
fi

# Optional auto-reboot
read -p "🔁 Reboot automatically after upgrade? (yes/no): " AUTOREBOOT

# Set non-interactive mode for apt
export DEBIAN_FRONTEND=noninteractive

echo "📦 Backing up APT sources..."
cp -v /etc/apt/sources.list /etc/apt/sources.list.bak_pve7
cp -v /etc/apt/sources.list.d/pve-install-repo.list /etc/apt/sources.list.d/pve-install-repo.list.bak_pve7 || true

# Remove deprecated entries
echo "🧹 Cleaning up old entries..."
find /etc/apt/sources.list /etc/apt/sources.list.d -type f -exec sed -i '/bullseye\/updates/d' {} +

# Disable enterprise repo if it exists
if [ -f /etc/apt/sources.list.d/pve-enterprise.list ]; then
    echo "🔒 Disabling enterprise repo..."
    sed -i 's/^deb /# deb /' /etc/apt/sources.list.d/pve-enterprise.list
fi

# Update to bookworm
echo "🔁 Updating sources to Bookworm (Debian 12)..."
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list.d/*.list || true

# Set new repo files
echo "🌐 Writing Proxmox 8 no-subscription and security repos..."
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
echo "deb http://security.debian.org/debian-security bookworm-security main contrib" > /etc/apt/sources.list.d/debian-security.list

# Update & upgrade
echo "📥 Running apt update and full upgrade..."
apt update
apt dist-upgrade -y

echo "✅ Proxmox VE 8 upgrade complete."

if [[ "$AUTOREBOOT" == "yes" ]]; then
    echo "🔄 Rebooting now..."
    reboot
else
    echo "ℹ️ Please run 'reboot' to finish the upgrade."
fi
