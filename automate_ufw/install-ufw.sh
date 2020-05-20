#!/usr/bin/env bash
# AUTHOR: gotbletu <gotbletu@gmail.com>
# SOCIAL: https://www.youtube.com/user/gotbletu|https://github.com/gotbletu|https://twitter.com/gotbletu
# REFF:   https://www.linode.com/docs/security/firewalls/configure-firewall-with-ufw/

# requires root
[ "$(whoami)" != "root" ] && exec sudo -- "$0" "$@"

Color_Off='\e[0m'
Red='\e[0;31m'
Yellow='\e[0;33m'

__desc="${Red}========== UFW Uncomplicated Firewall ==========${Color_Off}
Uncomplicated Firewall (UFW) is a program for managing a netfilter firewall designed to be easy to use. It uses a command-line interface consisting of a small number of simple commands, and uses iptables for configuration.
https://launchpad.net/ufw
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
  apt install -y coreutils ufw
elif [ "$PKMGR" = "apt-get" ]; then
  apt-get install --no-install-recommends -y coreutils ufw
elif [ "$PKMGR" = "aptitude" ]; then
  aptitude install --without-recommends -y coreutils ufw
elif [ "$PKMGR" = "dnf" ]; then
  dnf install -y coreutils ufw
elif [ "$PKMGR" = "emerge" ]; then
  emerge coreutils ufw
elif [ "$PKMGR" = "eopkg" ]; then
  eopkg install coreutils ufw
elif [ "$PKMGR" = "pacman" ]; then
  pacman --noconfirm -S coreutils ufw
elif [ "$PKMGR" = "zypper" ]; then
  zypper install -y coreutils ufw
else
  printf "%b\n" "${Red}Sorry your package manager is not supported. Exiting setup.${Color_Off}"
  exit 1
fi

printf "\n"

# enable services on boot
systemctl enable --now ufw

printf "\n"

printf "%b\n" "${Yellow}Allow Common Firewall Rules for SSH (22), HTTP (80), HTTPS (443).${Color_Off}"
ufw allow ssh
ufw allow http
ufw allow https
ufw enable
ufw status
