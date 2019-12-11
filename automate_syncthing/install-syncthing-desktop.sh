#!/usr/bin/env bash
# AUTHOR: gotbletu <gotbletu@gmail.com>
# SOCIAL: https://www.youtube.com/user/gotbletu|https://github.com/gotbletu|https://twitter.com/gotbletu
# DESC:   easy samba server setup
# DEMO:   https://youtu.be/HGO4lqh0LN8
# REFF:   https://docs.syncthing.net/users/faq.html#how-do-i-access-the-web-gui-from-another-computer

Color_Off='\e[0m'
Black='\e[0;30m'
Red='\e[0;31m'
Green='\e[0;32m'
Yellow='\e[0;33m'
Blue='\e[0;34m'
Purple='\e[0;35m'
Cyan='\e[0;36m'
White='\e[0;37m'

__desc="${Red}========== Syncthing (Desktop Only) ==========${Color_Off}
Syncthing is a continuous file synchronization program.
It synchronizes files between two or more computers and replaces proprietary sync and cloud services with something open, trustworthy and decentralized.
Your data is your data alone and you deserve to choose where it is stored, if it is shared with some third party and how it's transmitted over the internet.
https://syncthing.net
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
    sudo apt update
  elif [ "$PKMGR" = "apt-get" ]; then
    sudo apt-get update
  elif [ "$PKMGR" = "aptitude" ]; then
    sudo aptitude update
  elif [ "$PKMGR" = "dnf" ]; then
    sudo dnf check-update
  elif [ "$PKMGR" = "emerge" ]; then
    sudo emerge --sync
  elif [ "$PKMGR" = "eopkg" ]; then
    sudo eopkg update-repo
  elif [ "$PKMGR" = "pacman" ]; then
    sudo pacman -Syy
  elif [ "$PKMGR" = "zypper" ]; then
    sudo zypper refresh
  else
    echo -e "${Red}Sorry your package manager is not supported. Exiting setup.${Color_Off}"
    exit 1
  fi
fi

# install required packages
if [ "$PKMGR" = "apt" ]; then
  sudo apt install -y syncthing coreutils sed gawk
elif [ "$PKMGR" = "apt-get" ]; then
  sudo apt-get install --no-install-recommends -y syncthing coreutils sed gawk
elif [ "$PKMGR" = "aptitude" ]; then
  sudo aptitude install --without-recommends -y syncthing coreutils sed gawk
elif [ "$PKMGR" = "dnf" ]; then
  sudo dnf install -y syncthing coreutils sed gawk
elif [ "$PKMGR" = "emerge" ]; then
  sudo emerge syncthing coreutils sed gawk
elif [ "$PKMGR" = "eopkg" ]; then
  sudo eopkg install syncthing coreutils sed gawk
elif [ "$PKMGR" = "pacman" ]; then
  sudo pacman --noconfirm -S syncthing coreutils sed gawk
elif [ "$PKMGR" = "zypper" ]; then
  sudo zypper install -y syncthing coreutils sed gawk
else
  echo -e "${Red}Sorry your package manager is not supported. Exiting setup.${Color_Off}"
  exit 1
fi

echo

# generate initial default config
USERNAME="$(whoami)"
sudo systemctl start syncthing@"$USERNAME".service
sudo systemctl stop syncthing@"$USERNAME".service

# enable services on boot
sudo systemctl enable --now syncthing@"$USERNAME".service

echo

PATH_CONFIG="$HOME/.config/syncthing/config.xml"
MY_IP="$(grep address "$PATH_CONFIG" | tail -n1 | cut -d '>' -f2 | cut -d '<' -f1)"
echo -e "${Yellow}>>>Server will be hosted at ${Red}http://$MY_IP${Color_Off}"
echo -e "${Red}>>>Setup WebUI Login: WebUI > Actions > Settings > GUI > GUI Authentication. Then Actions > Restart${Color_Off}"
echo -e "${Purple}You might need to check your firewall/iptables configurations.${Color_Off}"
