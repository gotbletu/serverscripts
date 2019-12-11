#!/usr/bin/env bash
# AUTHOR: gotbletu
# DESC: [archlinux] simi autoinstaller to setup transmission-daemon with webui and ipblocklist support
# DEMO:

# check for sudo access
if [ "$(id -u)" != "0" ]; then
  echo "Sorry, you need to run this with sudo."
  exit 1
fi

Color_Off='\e[0m'
Black='\e[0;30m'
Red='\e[0;31m'
Green='\e[0;32m'
Yellow='\e[0;33m'
Blue='\e[0;34m'
Purple='\e[0;35m'
Cyan='\e[0;36m'
White='\e[0;37m'

__desc="${Red}========== Ubooquity ==========${Color_Off}
Ubooquity is small content server that you can use on any device on which Java is installed.
It runs in the background and makes all the comics and books you chose to share available through a web page.
The idea behind Ubooquity is to be able to browse your personal digital library from your tablet, your e-reader or your smartphone, either at home or from anywhere else.
Ubooquity is free for non-commercial use.
https://vaemendis.net/ubooquity/static12/license
"
echo -e "$__desc" | fold -s

# auto detect default package manager
find_pkm() { for i;do command -v "$i" > /dev/null 2>&1 && { echo "$i"; return 0;};done;return 1; }
PKMGR=$(find_pkm apt apt-get aptitude dnf emerge eopkg pacman zypper)

# ask to refresh repo
echo -ne "${Yellow}Do you want to refresh system repository? [y/n] ${Color_Off}"
read -r REPLY
if [[ $REPLY =~ ^[Yy]$ ]]; then
  if [ "$PKMGR" = "apt" ]; then
    apt update
  elif [ "$PKMGR" = "apt-get" ]; then
    apt-get update
  elif [ "$PKMGR" = "aptitude" ]; then
    aptitude update
  elif [ "$PKMGR" = "dnf" ]; then
    dnf check-update
  elif [ "$PKMGR" = "emerge" ]; then
    emerge --sync
  elif [ "$PKMGR" = "eopkg" ]; then
    eopkg update-repo
  elif [ "$PKMGR" = "pacman" ]; then
    pacman -Syy
  elif [ "$PKMGR" = "zypper" ]; then
    zypper refresh
  else
    echo -e "${Red}Sorry your package manager is not supported. Exiting setup.${Color_Off}"
    exit 1
  fi
fi

# install required packages
if [ "$PKMGR" = "apt" ]; then
  apt install -y openjdk-8-jre-headless curl unzip coreutils sed gawk
elif [ "$PKMGR" = "apt-get" ]; then
  apt-get install --no-install-recommends -y openjdk-8-jre-headless curl unzip coreutils sed gawk
elif [ "$PKMGR" = "aptitude" ]; then
  aptitude install --without-recommends -y openjdk-8-jre-headless curl unzip coreutils sed gawk
elif [ "$PKMGR" = "dnf" ]; then
  dnf install -y java-1.8.0-openjdk-headless curl unzip coreutils sed gawk
elif [ "$PKMGR" = "emerge" ]; then
  emerge openjdk-8-jre-headless curl unzip coreutils sed gawk
elif [ "$PKMGR" = "eopkg" ]; then
  eopkg install openjdk-8 curl unzip coreutils sed gawk
elif [ "$PKMGR" = "pacman" ]; then
  pacman --noconfirm -S jre8-openjdk-headless curl unzip coreutils sed gawk
elif [ "$PKMGR" = "zypper" ]; then
  zypper install -y java-1_8_0-openjdk-headless curl unzip coreutils sed gawk
else
  echo -e "${Red}Sorry your package manager is not supported. Exiting setup.${Color_Off}"
  exit 1
fi

echo

# copy service file
SERVICE_FILE="/etc/systemd/system/ubooquity.service"
cp ubooquity.service "$SERVICE_FILE"

# create home directory/user/group
HOMEDIR="/var/lib/ubooquity"
USERNAME=ubooquity
GROUPNAME=ubooquity
mkdir -p "$HOMEDIR"
chmod -R 775 "$HOMEDIR"
groupadd "$GROUPNAME"
useradd -d "$HOMEDIR" -M -s /usr/sbin/nologin -g "$GROUPNAME" "$USERNAME"
chown "$USERNAME":"$GROUPNAME" "$HOMEDIR"

# manual install
PACKAGE_URL="http://vaemendis.net/ubooquity/service/download.php"
curl -kL "$PACKAGE_URL" | unzip && mv Ubooquity.jar "$HOMEDIR" && rm download.php

# enable services on boot
systemctl enable --now ubooquity.service

echo

MY_IP="$(ip addr | awk '/global/ {print $1,$2}' | cut -d'/' -f1 | cut -d' ' -f2 | head -n 1)"
echo -e "${Yellow}>>>Initial Admin Account Setup Require for Ubooquity ${Red}http://$MY_IP:2203/admin${Color_Off}"
echo -e "${Yellow}>>>Server will be hosted at ${Red}http://$MY_IP:2202${Color_Off}"
