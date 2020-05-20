#!/usr/bin/env bash
# AUTHOR: gotbletu <gotbletu@gmail.com>
# SOCIAL: https://www.youtube.com/user/gotbletu|https://github.com/gotbletu|https://twitter.com/gotbletu
# DESC:   easy disable openssh password login
# DEMO:   https://youtu.be/fn8bDwfmM3c

# requires root
[ "$(whoami)" != "root" ] && exec sudo -- "$0" "$@"

Color_Off='\e[0m'
Red='\e[0;31m'
Yellow='\e[0;33m'

__desc="${Red}========== Disable OpenSSH Password Authentication ==========${Color_Off}
Make Sure To Have Passwordless Login Setup Before Disabling SSH Password Authentication
https://www.openssh.com
"
printf "%b\n" "$__desc" | fold -s

printf "%b" "${Yellow}Disable SSH Password Authentication? [y/n] ${Color_Off}"
read -r REPLY
if ! [[ $REPLY =~ ^[Yy]$ ]]; then
  exit 1
fi

printf "\n"

# enable x11 forwarding in config file
PATH_CONFIG="/etc/ssh/sshd_config"
sed -i 's:#PasswordAuthentication.*:PasswordAuthentication no:g' "$PATH_CONFIG"

# restart service
systemctl restart sshd.service

MY_IP="$(ip addr | awk '/global/ {print $1,$2}' | cut -d'/' -f1 | cut -d' ' -f2 | head -n 1)"
printf "%b\n" "${Yellow}>>>Usage: ${Red}ssh username@$MY_IP:22${Color_Off}"
