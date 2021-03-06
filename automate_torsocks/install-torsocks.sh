#!/usr/bin/env bash
# AUTHOR: gotbletu <gotbletu@gmail.com>
# SOCIAL: https://www.youtube.com/user/gotbletu|https://github.com/gotbletu|https://twitter.com/gotbletu
# DESC:   easy samba server setup
# DEMO:   https://youtu.be/HGO4lqh0LN8
# REFF:   https://docs.syncthing.net/users/faq.html#how-do-i-access-the-web-gui-from-another-computer

# requires root
[ "$(whoami)" != "root" ] && exec sudo -- "$0" "$@"

Color_Off='\e[0m'
Red='\e[0;31m'
Yellow='\e[0;33m'
Purple='\e[0;35m'

__desc="${Red}========== Torsocks ==========${Color_Off}
Torsocks allows you to use most applications in a safe way with Tor.
It ensures that DNS requests are handled safely and explicitly rejects any traffic other than TCP from the application you're using.
https://www.torproject.org
https://gitweb.torproject.org/torsocks.git
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
  apt install -y torsocks coreutils sed gawk
elif [ "$PKMGR" = "apt-get" ]; then
  apt-get install --no-install-recommends -y torsocks coreutils sed gawk
elif [ "$PKMGR" = "aptitude" ]; then
  aptitude install --without-recommends -y torsocks coreutils sed gawk
elif [ "$PKMGR" = "dnf" ]; then
  dnf install -y torsocks coreutils sed gawk
elif [ "$PKMGR" = "emerge" ]; then
  emerge torsocks coreutils sed gawk
elif [ "$PKMGR" = "eopkg" ]; then
  eopkg install torsocks coreutils sed gawk
elif [ "$PKMGR" = "pacman" ]; then
  pacman --noconfirm -S torsocks coreutils sed gawk
elif [ "$PKMGR" = "zypper" ]; then
  zypper install -y torsocks coreutils sed gawk
else
  printf "%b\n" "${Red}Sorry your package manager is not supported. Exiting setup.${Color_Off}"
  exit 1
fi

printf "\n"

# enable torsocks port and cookies
PATH_CONFIG="/etc/tor/torrc"
sed -i 's:.*#ControlPort.*:ControlPort 9051:g' "$PATH_CONFIG"
sed -i 's:.*#CookieAuthentication.*:CookieAuthentication 0:g' "$PATH_CONFIG"

# enable services on boot
systemctl enable --now tor.service

printf "\n"

printf "%b\n" "${Yellow}>>>Usage: ${Red}torsocks wget ...; torsocks curl ...; torsocks apt install ...; ...etc${Color_Off}"
printf "%b\n" "${Yellow}>>>Check Tor Status: ${Red}torsocks w3m 'https://check.torproject.org'${Color_Off}"
printf "%b\n" "${Purple}You might need to check your firewall/iptables configurations.${Color_Off}"
