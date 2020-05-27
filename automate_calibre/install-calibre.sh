#!/usr/bin/env bash
# AUTHOR: gotbletu <gotbletu@gmail.com>
# SOCIAL: https://www.youtube.com/user/gotbletu|https://github.com/gotbletu|https://twitter.com/gotbletu
# REFF:   https://gist.github.com/plembo/337f323e53486cbdb03100692ae8c892
#         https://gist.github.com/tyru/da4b2bb5cecdcf8dce52
#         https://manual.calibre-ebook.com/server.html#managing-user-accounts-from-the-command-line-only

# requires root
[ "$(whoami)" != "root" ] && exec sudo -- "$0" "$@"

Color_Off='\e[0m'
Red='\e[0;31m'
Green='\e[0;32m'
Yellow='\e[0;33m'
Purple='\e[0;35m'

__desc="${Red}========== Calibre Ebook Management ==========${Color_Off}
Calibre is a powerful and easy to use e-book manager. Users say it's outstanding and a must-have. It'll allow you to do nearly everything and it takes things a step beyond normal e-book software. It's also completely free and open source and great for both casual users and computer experts.
https://calibre-ebook.com
"
printf "%b\n" "$__desc" | fold -s

# auto detect default package manager
find_pkm() { for i;do command -v "$i" > /dev/null 2>&1 && { printf "%s" "$i"; return 0;};done;return 1; }
PKMGR=$(find_pkm apt apt-get aptitude dnf emerge eopkg pacman zypper)

# ask to refresh repo
printf "%b" "${Yellow}Do you want to refresh system repository? [y/n] ${Color_Off}"
read -r REPLY
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
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
  apt install -y coreutils sed gawk calibre
elif [ "$PKMGR" = "apt-get" ]; then
  apt-get install --no-install-recommends -y coreutils sed gawk calibre
elif [ "$PKMGR" = "aptitude" ]; then
  aptitude install --without-recommends -y coreutils sed gawk calibre
elif [ "$PKMGR" = "dnf" ]; then
  dnf install -y coreutils sed gawk calibre
elif [ "$PKMGR" = "emerge" ]; then
  emerge coreutils sed gawk calibre
elif [ "$PKMGR" = "eopkg" ]; then
  eopkg install coreutils sed gawk calibre
elif [ "$PKMGR" = "pacman" ]; then
  pacman --noconfirm -S coreutils sed gawk calibre
elif [ "$PKMGR" = "zypper" ]; then
  zypper install -y coreutils sed gawk calibre
else
  printf "%b\n" "${Red}Sorry your package manager is not supported. Exiting setup.${Color_Off}"
  exit 1
fi

printf "\n"

# copy service file
SERVICE_FILE="/etc/systemd/system/calibre-server.service"
cp calibre-server.service "$SERVICE_FILE"

# create save and watch directory
printf "%b\n" "${Green}create save directory (e.g /media/data/calibre, do not use home directory /home/user/):${Color_Off}"
printf "%b\n" "${Green}>>>Note<<< directory path will auto be created if path does not exist${Color_Off}"
read -rep "Save Directory: " SAVEDIR
SAVEDIR=$(printf "%s" "$SAVEDIR" | sed 's/\/*$//g') # remove trailing slashes in path
mkdir -vp "$SAVEDIR"/library/ebook
# mkdir -vp "$SAVEDIR"/watchdir/{ebook,book,textbook,comic,dojinshi,legend,manga,super}
mkdir -vp "$SAVEDIR"/watchdir/incoming_ebook
chmod ugo+rw "$SAVEDIR/watchdir"
printf "\n"

# create user and password for webui
printf "%b" "${Green}create username for the webui (e.g godmode):${Color_Off}"
mkdir -p /srv/calibre
calibre-server --userdb /srv/calibre/users.sqlite --manage-users
printf "\n"

# GUI calibre wizard to setup default device and library location
printf "%b\n" "${Yellow}GUI Calibre Wizard will ask for your default device (used for conversion format) ${Color_Off}"
printf "%b\n" "${Yellow}and your default library, you can use existing one or use the default ($SAVEDIR/library/ebook) ${Color_Off}"
sleep 5
calibre

# enable services on boot
systemctl enable --now calibre-server.service

printf "\n"

MY_IP="$(ip addr | awk '/global/ {print $1,$2}' | cut -d'/' -f1 | cut -d' ' -f2 | head -n 1)"
printf "%b\n" "${Yellow}>>>Server will be hosted at ${Red}http://$MY_IP:57770${Color_Off}"
