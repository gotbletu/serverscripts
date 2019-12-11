#!/usr/bin/env bash
# AUTHOR: gotbletu <gotbletu@gmail.com>
# SOCIAL: https://www.youtube.com/user/gotbletu|https://github.com/gotbletu|https://twitter.com/gotbletu
# DESC:   easy samba server setup
# DEMO:   https://youtu.be/HGO4lqh0LN8
# REFF:   https://docs.syncthing.net/users/faq.html#how-do-i-access-the-web-gui-from-another-computer

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

__desc="${Red}========== Syncthing ==========${Color_Off}
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
  apt install -y syncthing coreutils sed gawk
elif [ "$PKMGR" = "apt-get" ]; then
  apt-get install --no-install-recommends -y syncthing coreutils sed gawk
elif [ "$PKMGR" = "aptitude" ]; then
  aptitude install --without-recommends -y syncthing coreutils sed gawk
elif [ "$PKMGR" = "dnf" ]; then
  dnf install -y syncthing coreutils sed gawk
elif [ "$PKMGR" = "emerge" ]; then
  emerge syncthing coreutils sed gawk
elif [ "$PKMGR" = "eopkg" ]; then
  eopkg install syncthing coreutils sed gawk
elif [ "$PKMGR" = "pacman" ]; then
  pacman --noconfirm -S syncthing coreutils sed gawk
elif [ "$PKMGR" = "zypper" ]; then
  zypper install -y syncthing coreutils sed gawk
else
  echo -e "${Red}Sorry your package manager is not supported. Exiting setup.${Color_Off}"
  exit 1
fi

echo

echo -e "${Green}create save directory (e.g /media/data/syncthing, do not use home directory e.g /home/user/):${Color_Off}"
echo -e "${Green}>>>Note<<< directory path will auto be created if path does not exist${Color_Off}"
read -r -e SAVEDIR
SAVEDIR=$(echo "$SAVEDIR" | sed 's/\/*$//g') # remove trailing slashes in path
mkdir -p "$SAVEDIR"

# create home directory/user/group
HOMEDIR="/var/lib/syncthing"
USERNAME=syncthing
GROUPNAME=syncthing
mkdir -p "$HOMEDIR"
chmod -R 775 "$HOMEDIR"
groupadd "$GROUPNAME"
useradd -d "$HOMEDIR" -M -s /usr/sbin/nologin -g "$GROUPNAME" "$USERNAME"
chown "$USERNAME":"$GROUPNAME" "$HOMEDIR"

# generate initial default config
systemctl start syncthing@"$USERNAME".service

# chmod permissions
echo -e "${Cyan}

  Directory Permission
  --------------------
  777      (rwxrwxrwx)
  775      (rwxrwxr-x)
  774      (rwxrwxr--)
  770      (rwxrwx---)
  755      (rwxr-xr-x)
  750      (rwxr-x---)
  700      (rwx------)

  owner     rwx------
  group     ---rwx---
  other     ------rwx

${Color_Off}"

echo -e "${Green}set save directory permission (e.g 770):${Color_Off}"
echo -e "${Green}>>>Note<<< add users to ${Red}${GROUPNAME}${Green} group if you need${Color_Off}"
read -r DIR_PERM
chmod -R "$DIR_PERM" "$SAVEDIR"
chgrp -R "$GROUPNAME" "$SAVEDIR"

# stop initial startup
systemctl stop syncthing@"$USERNAME".service

# allow remote WebUI access and set default save path
PATH_CONFIG="$HOMEDIR/.config/syncthing/config.xml"
sed -i "s/127.0.0.1/0.0.0.0/g" "$PATH_CONFIG"
sed -i 's@~@'"$SAVEDIR"'@g' "$PATH_CONFIG"

# enable services on boot
systemctl enable --now syncthing@"$USERNAME".service

echo

MY_IP="$(ip addr | awk '/global/ {print $1,$2}' | cut -d'/' -f1 | cut -d' ' -f2 | head -n 1)"
echo -e "${Yellow}>>>Server will be hosted at ${Red}http://$MY_IP:8384${Color_Off}"
echo -e "${Red}>>>Setup WebUI Login: WebUI > Actions > Settings > GUI > GUI Authentication. Then Actions > Restart${Color_Off}"
echo -e "${Purple}You might need to check your firewall/iptables configurations.${Color_Off}"
