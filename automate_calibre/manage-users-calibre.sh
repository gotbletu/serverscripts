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

systemctl stop calibre-server.service

# create user and password for webui
printf "%b" "${Green}manage your calibre webui users:${Color_Off}"
calibre-server --userdb /srv/calibre/users.sqlite --manage-users

systemctl start calibre-server.service

printf "\n"

MY_IP="$(ip addr | awk '/global/ {print $1,$2}' | cut -d'/' -f1 | cut -d' ' -f2 | head -n 1)"
printf "%b\n" "${Yellow}>>>Server will be hosted at ${Red}http://$MY_IP:57770${Color_Off}"
