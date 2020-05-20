#!/usr/bin/env bash
# AUTHOR: gotbletu <gotbletu@gmail.com>
# SOCIAL: https://www.youtube.com/user/gotbletu|https://github.com/gotbletu|https://twitter.com/gotbletu
# DESC:   easy transmission server setup with webui login and ipblocklist
# DEMO:   https://youtu.be/EN0ycEqg8Iw
# REFF:   https://www.smarthomebeginner.com/install-transmission-web-interface-on-ubuntu-1204/
#         https://linuxconfig.org/how-to-set-up-transmission-daemon-on-a-raspberry-pi-and-control-it-via-web-interface
#         https://askubuntu.com/a/738118
#         https://www.linuxtrainingacademy.com/all-umasks/

# requires root
[ "$(whoami)" != "root" ] && exec sudo -- "$0" "$@"

Color_Off='\e[0m'
Red='\e[0;31m'
Green='\e[0;32m'
Yellow='\e[0;33m'
Purple='\e[0;35m'
Cyan='\e[0;36m'

__desc="${Red}========== Transmission ==========${Color_Off}
Transmission is a BitTorrent client which features a variety of user interfaces on top of a cross-platform back-end. Transmission is free software licensed under the terms of the GNU General Public License, with parts under the MIT License.
https://transmissionbt.com
"
printf "%b\n" "$__desc" | fold -s

# auto detect default package manager
find_pkm() { for i;do command -v "$i" > /dev/null 2>&1 && { printf "%s" "$i"; return 0;};done;return 1; }
PKMGR=$(find_pkm apt apt-get aptitude dnf emerge eopkg pacman zypper)

# ask to refresh repo
printf "%b" "${Yellow}Do you want to refresh system repository? [y/n] ${Color_Off}"
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
    printf "%b\n" "${Red}Sorry your package manager is not supported. Exiting setup.${Color_Off}"
    exit 1
  fi
fi

# install required packages
if [ "$PKMGR" = "apt" ]; then
  PATH_CONFIG="/etc/transmission-daemon/settings.json"
  GROUPNAME="debian-transmission"
  SERVICE_NAME="transmission-daemon.service"
  apt install -y transmission-cli transmission-daemon coreutils sed gawk
  systemctl start transmission-daemon.service
  systemctl stop transmission-daemon.service
elif [ "$PKMGR" = "apt-get" ]; then
  PATH_CONFIG="/etc/transmission-daemon/settings.json"
  GROUPNAME="debian-transmission"
  SERVICE_NAME="transmission-daemon.service"
  apt-get install --no-install-recommends -y transmission-cli transmission-daemon coreutils sed gawk
  systemctl start transmission-daemon.service
  systemctl stop transmission-daemon.service
elif [ "$PKMGR" = "aptitude" ]; then
  PATH_CONFIG="/etc/transmission-daemon/settings.json"
  GROUPNAME="debian-transmission"
  SERVICE_NAME="transmission-daemon.service"
  aptitude install --without-recommends -y transmission-cli transmission-daemon coreutils sed gawk
  systemctl start transmission-daemon.service
  systemctl stop transmission-daemon.service
elif [ "$PKMGR" = "dnf" ]; then
  PATH_CONFIG="/var/lib/transmission/.config/transmission-daemon/settings.json"
  GROUPNAME="transmission"
  SERVICE_NAME="transmission-daemon.service"
  dnf install -y transmission-cli transmission-daemon coreutils sed gawk
  systemctl start transmission-daemon.service
  systemctl stop transmission-daemon.service
elif [ "$PKMGR" = "emerge" ]; then
  PATH_CONFIG="/var/lib/transmission/.config/transmission-daemon/settings.json"
  GROUPNAME="transmission"
  SERVICE_NAME="transmission-daemon.service"
  emerge transmission-cli transmission-daemon coreutils sed gawk
  systemctl start transmission-daemon.service
  systemctl stop transmission-daemon.service
elif [ "$PKMGR" = "eopkg" ]; then
  PATH_CONFIG="/var/lib/transmission/.config/transmission-daemon/settings.json"
  GROUPNAME="transmission"
  SERVICE_NAME="transmission.service"
  eopkg install transmission coreutils sed gawk
  systemctl start transmission.service
  systemctl stop transmission.service
elif [ "$PKMGR" = "pacman" ]; then
  PATH_CONFIG="/var/lib/transmission/.config/transmission-daemon/settings.json"
  GROUPNAME="transmission"
  SERVICE_NAME="transmission.service"
  pacman --noconfirm -S transmission-cli coreutils sed gawk
  systemctl start transmission.service
  systemctl stop transmission.service
elif [ "$PKMGR" = "zypper" ]; then
  PATH_CONFIG="/var/lib/transmission/.config/transmission-daemon/settings.json"
  GROUPNAME="transmission"
  SERVICE_NAME="transmission-daemon.service"
  zypper install -y transmission transmission-daemon coreutils sed gawk
  systemctl start transmission-daemon.service
  systemctl stop transmission-daemon.service
else
  printf "%b\n" "${Red}Sorry your package manager is not supported. Exiting setup.${Color_Off}"
  exit 1
fi

printf "\n"

# copy settings
cp settings.json "$PATH_CONFIG"

# create torrent directory
printf "%b\n" "${Green}create save directory (e.g /media/data/transmission, do not use home directory /home/user/):${Color_Off}"
printf "%b\n" "${Green}>>>Note<<< directory path will auto be created if path does not exist${Color_Off}"
read -rep "Save Directory: " SAVEDIR
SAVEDIR=$(printf "%s" "$SAVEDIR" | sed 's/\/*$//g') # remove trailing slashes in path
mkdir -vp "$SAVEDIR"/{completed,incomplete,watchdir}
sed -i 's@MYSAVEDIR@'"$SAVEDIR"'@g' "$PATH_CONFIG"

# chart for umask and chmod permissions
printf "%b\n" "${Cyan}

    Umask   File Permission    Directory Permission
    -----------------------------------------------
    000     666 (rw-rw-rw-)    777      (rwxrwxrwx)
    002     664 (rw-rw-r--)    775      (rwxrwxr-x)
    003     664 (rw-rw-r--)    774      (rwxrwxr--)
    007     660 (rw-rw----)    770      (rwxrwx---)
    022     644 (rw-r--r--)    755      (rwxr-xr-x)
    027     640 (rw-r-----)    750      (rwxr-x---)
    077     600 (rw-------)    700      (rwx------)

${Color_Off}"

printf "%b\n" "${Green}set save directory permission (e.g 777):${Color_Off}"
printf "%b\n" "${Green}>>>Note<<< add users to ${Red}${GROUPNAME}${Green} group if you need${Color_Off}"
read -rp "DIR Permission: " DIR_PERM
chmod -R "$DIR_PERM" "$SAVEDIR"
printf "\n"

printf "%b\n" "${Green}set umask permission for incoming torrent creation (e.g 000):${Color_Off}"
read -rp "UMASK Permission: " UMASK_PERM
UMASK_PERM="$((8#$UMASK_PERM))"
sed -i "s/MYUMASK_PERM/$UMASK_PERM/g" "$PATH_CONFIG"
printf "\n"

# create user and password for webui
printf "%b\n" "${Green}create username for the webui (e.g godmode):${Color_Off}"
read -rp "New username: " USER_NAME
sed -i "s/MYUSERNAME/$USER_NAME/g" "$PATH_CONFIG"
printf "\n"

printf "%b\n" "${Green}create password for the webui:${Color_Off}"
read -rsp "New password: " PASSWORD
sed -i "s/MYPASSWORD/$PASSWORD/g" "$PATH_CONFIG"
printf "\n"

# change group
chgrp -R "$GROUPNAME" "$SAVEDIR"

# enable service on boot
systemctl enable --now "$SERVICE_NAME"

printf "\n"

MY_IP="$(ip addr | awk '/global/ {print $1,$2}' | cut -d'/' -f1 | cut -d' ' -f2 | head -n 1)"
printf "%b\n" "${Yellow}>>>Server will be hosted at ${Red}http://$MY_IP:9091${Color_Off}"
printf "%b\n" "${Purple}>>>Extra<<< WEBUI > Edit Preferences > Peers > Blocklist > Update ${Color_Off}"
