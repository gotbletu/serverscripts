#!/usr/bin/env bash
# AUTHOR: gotbletu <gotbletu@gmail.com>
# SOCIAL: https://www.youtube.com/user/gotbletu|https://github.com/gotbletu|https://twitter.com/gotbletu
# DESC:   easy setup kiwix server for offline wikipedia
# DEMO:   https://youtu.be/1S6zUq2MwP0
# REFF:   https://wiki.kiwix.org/wiki/Content_in_all_languages
#         https://github.com/stardiviner/kiwix.el

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
  apt update
  apt install -y coreutils curl gawk sed tar
elif [ "$PKMGR" = "apt-get" ]; then
  apt-get update
  apt-get install --no-install-recommends -y coreutils curl gawk sed tar
elif [ "$PKMGR" = "aptitude" ]; then
  aptitude update
  aptitude install --without-recommends -y coreutils curl gawk sed tar
elif [ "$PKMGR" = "dnf" ]; then
  dnf check-update
  dnf install -y coreutils curl gawk sed tar
elif [ "$PKMGR" = "emerge" ]; then
  emerge --sync
  emerge coreutils curl gawk sed tar
elif [ "$PKMGR" = "eopkg" ]; then
  eopkg update-repo
  eopkg install coreutils curl gawk sed tar
elif [ "$PKMGR" = "pacman" ]; then
  pacman -Syy
  pacman --noconfirm -S coreutils curl gawk sed tar
elif [ "$PKMGR" = "zypper" ]; then
  zypper refresh
  zypper install -y coreutils curl gawk sed tar
fi

printf "\n"

# manual install
PACKAGE_URL="https://download.kiwix.org/release/kiwix-tools/kiwix-tools_linux-x86_64.tar.gz"
# PACKAGE_FILE="$(basename "$PACKAGE_URL")"
# PACKAGE_DIR="${PACKAGE_FILE%%.*}"
curl -kL "$PACKAGE_URL" | tar -xz && mv kiwix-tools*/kiwix-serve /usr/local/bin && rm -r kiwix-tools*
chown root:root -R /usr/local/bin/

printf "\n"

SERVICE_FILE="/etc/systemd/system/kiwix-serve.service"
cp kiwix-serve.service "$SERVICE_FILE"

echo -e "${Green}create save directory (e.g /media/data/kiwix, do not use home directory e.g /home/user/):${Color_Off}"
echo -e "${Green}>>>Note<<< directory path will auto be created if path does not exist${Color_Off}"
read -r -e SAVEDIR
SAVEDIR=$(echo "$SAVEDIR" | sed 's/\/*$//g') # remove trailing slashes in path
mkdir -p "$SAVEDIR"
sed -i 's@MYSAVEDIR@'"$SAVEDIR"'@g' "$SERVICE_FILE"

# copy sample zim file
cp ./*.zim "$SAVEDIR"

# set port
PORT=49849
sed -i 's@MYPORT@'"$PORT"'@g' "$SERVICE_FILE"

# enable services on boot
systemctl enable --now kiwix-serve.service

printf "\n"

MY_IP="$(ip addr | awk '/global/ {print $1,$2}' | cut -d'/' -f1 | cut -d' ' -f2 | head -n 1)"
echo -e "${Yellow}>>>Server will be hosted at ${Red}http://$MY_IP:$PORT${Color_Off}"
echo -e "${Purple}You might need to check your firewall/iptables configurations.${Color_Off}"
