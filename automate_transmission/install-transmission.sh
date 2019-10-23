#!/usr/bin/env bash
# AUTHOR: gotbletu <gotbletu@gmail.com>
# SOCIAL: https://www.youtube.com/user/gotbletu|https://github.com/gotbletu|https://twitter.com/gotbletu
# DESC:   easy transmission server setup with webui login and ipblocklist
# DEMO:   https://youtu.be/UIWhQNDfMIw
# REFF:   https://www.smarthomebeginner.com/install-transmission-web-interface-on-ubuntu-1204/
#         https://linuxconfig.org/how-to-set-up-transmission-daemon-on-a-raspberry-pi-and-control-it-via-web-interface
#         https://askubuntu.com/a/738118
#         https://www.linuxtrainingacademy.com/all-umasks/

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

# install required packages
find_pkm() { for i;do command -v "$i" > /dev/null 2>&1 && { echo "$i"; return 0;};done;return 1; }
PKMGR=$(find_pkm apt apt-get aptitude dnf emerge eopkg pacman zypper)
if [ "$PKMGR" = "apt" ]; then
  TSM_CONFIG="/etc/transmission-daemon/settings.json"
  apt update
  apt install -y transmission-cli transmission-daemon coreutils sed gawk
  systemctl start transmission-daemon.service
  systemctl stop transmission-daemon.service
elif [ "$PKMGR" = "apt-get" ]; then
  TSM_CONFIG="/etc/transmission-daemon/settings.json"
  apt-get update
  apt-get install --no-install-recommends -y transmission-cli transmission-daemon coreutils sed gawk
  systemctl start transmission-daemon.service
  systemctl stop transmission-daemon.service
elif [ "$PKMGR" = "aptitude" ]; then
  TSM_CONFIG="/etc/transmission-daemon/settings.json"
  aptitude update
  aptitude install --without-recommends -y transmission-cli transmission-daemon coreutils sed gawk
  systemctl start transmission-daemon.service
  systemctl stop transmission-daemon.service
elif [ "$PKMGR" = "dnf" ]; then
  TSM_CONFIG="/var/lib/transmission/.config/transmission-daemon/settings.json"
  dnf check-update
  dnf install -y transmission-cli transmission-daemon coreutils sed gawk
  systemctl start transmission-daemon.service
  systemctl stop transmission-daemon.service
elif [ "$PKMGR" = "emerge" ]; then
  TSM_CONFIG="/var/lib/transmission/.config/transmission-daemon/settings.json"
  emerge --sync
  emerge transmission-cli transmission-daemon coreutils sed gawk
  systemctl start transmission-daemon.service
  systemctl stop transmission-daemon.service
elif [ "$PKMGR" = "eopkg" ]; then
  TSM_CONFIG="/var/lib/transmission/.config/transmission-daemon/settings.json"
  eopkg update-repo
  eopkg install transmission coreutils sed gawk
  systemctl start transmission.service
  systemctl stop transmission.service
elif [ "$PKMGR" = "pacman" ]; then
  TSM_CONFIG="/var/lib/transmission/.config/transmission-daemon/settings.json"
  pacman -Syy
  pacman --noconfirm -S transmission-cli coreutils sed gawk
  systemctl start transmission.service
  systemctl stop transmission.service
elif [ "$PKMGR" = "zypper" ]; then
  TSM_CONFIG="/var/lib/transmission/.config/transmission-daemon/settings.json"
  zypper refresh
  zypper install -y transmission transmission-daemon coreutils sed gawk
  systemctl start transmission-daemon.service
  systemctl stop transmission-daemon.service
fi

printf "\n"

# copy settings
cp settings.json "$TSM_CONFIG"

# create torrent directory
echo -e "${Green}create save directory (e.g /media/data/transmission, do not use home directory e.g /home/user/):${Color_Off}"
echo -e "${Green}>>>Note<<< directory path will auto be created if path does not exist${Color_Off}"
read -r -e SAVEDIR
SAVEDIR=$(echo "$SAVEDIR" | sed 's/\/*$//g') # remove trailing slashes in path
mkdir -vp "$SAVEDIR"/{completed,incomplete,watchdir}
sed -i 's@MYSAVEDIR@'"$SAVEDIR"'@g' "$TSM_CONFIG"

# chart for umask and chmod permissions
echo -e "${Cyan}

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

echo -e "${Green}set save directory permission (e.g 777):${Color_Off}"
read -r DIR_PERM
chmod -R "$DIR_PERM" "$SAVEDIR"

echo -e "${Green}set umask permission for incoming torrent creation (e.g 000):${Color_Off}"
read -r UMASK_PERM
UMASK_PERM="$((8#$UMASK_PERM))"
sed -i "s/MYUMASK_PERM/$UMASK_PERM/g" "$TSM_CONFIG"

# create user and password for webui
echo -e "${Green}create username for the webui (e.g godmode):${Color_Off}"
read -r USERNAME
sed -i "s/MYUSERNAME/$USERNAME/g" "$TSM_CONFIG"

echo -e "${Green}create password for the webui:${Color_Off}"
read -r -s -p "New password: " PASSWORD
sed -i "s/MYPASSWORD/$PASSWORD/g" "$TSM_CONFIG"

printf "\n"

# change group owner of save directory and enable services
if [ "$PKMGR" = "apt" ]; then
  chgrp -R debian-transmission "$SAVEDIR"
  systemctl enable --now transmission-daemon.service
elif [ "$PKMGR" = "apt-get" ]; then
  chgrp -R debian-transmission "$SAVEDIR"
  systemctl enable --now transmission-daemon.service
elif [ "$PKMGR" = "aptitude" ]; then
  chgrp -R debian-transmission "$SAVEDIR"
  systemctl enable --now transmission-daemon.service
elif [ "$PKMGR" = "dnf" ]; then
  chgrp -R transmission "$SAVEDIR"
  systemctl enable --now transmission-daemon.service
elif [ "$PKMGR" = "emerge" ]; then
  chgrp -R transmission "$SAVEDIR"
  systemctl enable --now transmission-daemon.service
elif [ "$PKMGR" = "eopkg" ]; then
  chgrp -R transmission "$SAVEDIR"
  systemctl enable --now transmission.service
elif [ "$PKMGR" = "pacman" ]; then
  chgrp -R transmission "$SAVEDIR"
  systemctl enable --now transmission.service
elif [ "$PKMGR" = "zypper" ]; then
  chgrp -R transmission "$SAVEDIR"
  systemctl enable --now transmission-daemon.service
fi

printf "\n"

MY_IP="$(ip addr | awk '/global/ {print $1,$2}' | cut -d'/' -f1 | cut -d' ' -f2 | head -n 1)"
echo -e "${Yellow}>>>Server will be hosted at ${Red}http://$MY_IP:9091${Color_Off}"
echo -e "${Purple}>>>Extra<<< Update IP Blocklist from the WEBUI and add rules to firewall/iptables if needed${Color_Off}"
