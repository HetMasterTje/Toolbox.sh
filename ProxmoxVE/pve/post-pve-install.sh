#!/usr/bin/env bash

# Modified for Proxmox VE 6.4
# Original Author: tteck (tteckster)
# License: MIT
# https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE

header_info() {
  clear
  cat <<"EOF"
    ____ _    ________   ____             __     ____           __        ____  
   / __ \ |  / / ____/  / __ \____  _____/ /_   /  _/___  _____/ /_____ _/ / /  
  / /_/ / | / / __/    / /_/ / __ \/ ___/ __/   / // __ \/ ___/ __/ __ `/ / /  
 / ____/| |/ / /___   / ____/ /_/ (__  ) /_   _/ // / / (__  ) /_/ /_/ / / /   
/_/     |___/_____/  /_/    \____/____/\__/  /___/_/ /_/____/\__/\__,_/_/_/    

EOF
}

RD=$(echo "\033[01;31m")
YW=$(echo "\033[33m")
GN=$(echo "\033[1;92m")
CL=$(echo "\033[m")
BFR="\\r\\033[K"
HOLD="-"
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"

set -euo pipefail
shopt -s inherit_errexit nullglob

msg_info() { echo -ne " ${HOLD} ${YW}${1}..."; }
msg_ok() { echo -e "${BFR} ${CM} ${GN}${1}${CL}"; }
msg_error() { echo -e "${BFR} ${CROSS} ${RD}${1}${CL}"; }

start_routines() {
  header_info

  CHOICE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "SOURCES" --menu "Set correct Debian sources for PVE 6.4 (Buster)?" 14 58 2 "yes" " " "no" " " 3>&2 2>&1 1>&3)
  case $CHOICE in
  yes)
    msg_info "Correcting Proxmox VE Sources"
    cat <<EOF >/etc/apt/sources.list
deb http://deb.debian.org/debian buster main contrib
deb http://deb.debian.org/debian buster-updates main contrib
deb http://security.debian.org/debian-security buster/updates main contrib
EOF
    msg_ok "Corrected Proxmox VE Sources"
    ;;
  no) msg_error "Skipped correcting sources";;
  esac

  CHOICE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "PVE-ENTERPRISE" --menu "Disable 'pve-enterprise' repository?" 14 58 2 "yes" " " "no" " " 3>&2 2>&1 1>&3)
  case $CHOICE in
  yes)
    msg_info "Disabling 'pve-enterprise' repository"
    echo "# deb https://enterprise.proxmox.com/debian/pve buster pve-enterprise" >/etc/apt/sources.list.d/pve-enterprise.list
    msg_ok "Disabled 'pve-enterprise' repository"
    ;;
  no) msg_error "Skipped disabling 'pve-enterprise'";;
  esac

  CHOICE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "PVE-NO-SUBSCRIPTION" --menu "Enable 'pve-no-subscription' repository?" 14 58 2 "yes" " " "no" " " 3>&2 2>&1 1>&3)
  case $CHOICE in
  yes)
    msg_info "Enabling 'pve-no-subscription' repository"
    echo "deb http://download.proxmox.com/debian/pve buster pve-no-subscription" >/etc/apt/sources.list.d/pve-install-repo.list
    msg_ok "Enabled 'pve-no-subscription' repository"
    ;;
  no) msg_error "Skipped enabling 'pve-no-subscription'";;
  esac

  CHOICE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "UPDATE" --menu "\nUpdate Proxmox VE now?" 11 58 2 "yes" " " "no" " " 3>&2 2>&1 1>&3)
  case $CHOICE in
  yes)
    msg_info "Updating Proxmox VE (Patience)"
    apt-get update &>/dev/null
    apt-get -y dist-upgrade &>/dev/null
    msg_ok "Updated Proxmox VE"
    ;;
  no) msg_error "Skipped updating Proxmox VE";;
  esac

  CHOICE=$(whiptail --backtitle "Proxmox VE Helper Scripts" --title "REBOOT" --menu "\nReboot Proxmox VE now? (recommended)" 11 58 2 "yes" " " "no" " " 3>&2 2>&1 1>&3)
  case $CHOICE in
  yes)
    msg_info "Rebooting Proxmox VE"
    sleep 2
    msg_ok "Completed Post Install Routines"
    reboot
    ;;
  no)
    msg_error "Skipped reboot"
    msg_ok "Completed Post Install Routines"
    ;;
  esac
}

header_info
echo -e "\nThis script will Perform Post Install Routines for Proxmox VE 6.4.\n"
while true; do
  read -p "Start the Proxmox VE Post Install Script (y/n)? " yn
  case $yn in
  [Yy]*) break ;;
  [Nn]*) clear; exit ;;
  *) echo "Please answer yes or no." ;;
  esac
done

if ! pveversion | grep -q "pve-manager/6.4"; then
  msg_error "This version of Proxmox VE is not supported"
  echo -e "Requires Proxmox Virtual Environment Version 6.4."
  echo -e "Exiting..."
  sleep 2
  exit
fi

start_routines
