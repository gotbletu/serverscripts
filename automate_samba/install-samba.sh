#!/usr/bin/env bash
# AUTHOR: gotbletu <gotbletu@gmail.com>
# SOCIAL: https://www.youtube.com/user/gotbletu|https://github.com/gotbletu|https://twitter.com/gotbletu
# DESC:   easy samba server setup
# DEMO:   https://youtu.be/HGO4lqh0LN8
# CTR:    Abhinav Kulshreshtha (https://github.com/Abhinav1217)
#         Damian Rath (https://github.com/damianrath)
# REFF:   https://www.digitalocean.com/community/tutorials/how-to-set-up-a-samba-share-for-a-small-organization-on-ubuntu-16-04
#         https://askubuntu.com/questions/88108/samba-share-read-only-for-guests-read-write-for-authenticated-users
#         https://getsol.us/articles/software/samba/en/

# requires root
[ "$(whoami)" != "root" ] && exec sudo -- "$0" "$@"

Color_Off='\e[0m'
Red='\e[0;31m'
Green='\e[0;32m'
Yellow='\e[0;33m'
Purple='\e[0;35m'

__desc="${Red}========== Samba ==========${Color_Off}
Samba is a free software re-implementation of the SMB networking protocol.
Samba provides file and print services for various Microsoft Windows clients and can integrate with a Microsoft Windows Server domain, either as a Domain Controller (DC) or as a domain member.
As of version 4, it supports Active Directory and Microsoft Windows NT domains.
https://www.samba.org
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
  SERVICE_NMBD="nmbd.service"
  SERVICE_SMBD="smbd.service"
  apt install -y samba coreutils sed gawk
elif [ "$PKMGR" = "apt-get" ]; then
  SERVICE_NMBD="nmbd.service"
  SERVICE_SMBD="smbd.service"
  apt-get install --no-install-recommends -y samba coreutils sed gawk
elif [ "$PKMGR" = "aptitude" ]; then
  SERVICE_NMBD="nmbd.service"
  SERVICE_SMBD="smbd.service"
  aptitude install --without-recommends -y samba coreutils sed gawk
elif [ "$PKMGR" = "dnf" ]; then
  SERVICE_NMBD="nmb.service"
  SERVICE_SMBD="smb.service"
  dnf install -y samba coreutils sed gawk
elif [ "$PKMGR" = "emerge" ]; then
  SERVICE_NMBD="nmbd.service"
  SERVICE_SMBD="smbd.service"
  emerge samba coreutils sed gawk
elif [ "$PKMGR" = "eopkg" ]; then
  SERVICE_NMBD="nmb.service"
  SERVICE_SMBD="smb.service"
  eopkg it samba sed gawk coreutils
elif [ "$PKMGR" = "pacman" ]; then
  SERVICE_NMBD="nmb.service"
  SERVICE_SMBD="smb.service"
  pacman --noconfirm -S samba coreutils sed gawk
elif [ "$PKMGR" = "zypper" ]; then
  SERVICE_NMBD="nmb.service"
  SERVICE_SMBD="smb.service"
  zypper install -y samba coreutils sed gawk
else
  printf "%b\n" "${Red}Sorry your package manager is not supported. Exiting setup.${Color_Off}"
  exit 1
fi

printf "\n"

PATH_CONFIG="/etc/samba/smb.conf"
cp smb.conf "$PATH_CONFIG"

printf "%b\n" "${Green}create save directory (e.g /media/data/samba, do not use home directory /home/user/):${Color_Off}"
printf "%b\n" "${Green}>>>Note<<< directory path will auto be created if path does not exist${Color_Off}"
read -rep "Save Directory: " SAVEDIR
SAVEDIR=$(printf "%s" "$SAVEDIR" | sed 's/\/*$//g') # remove trailing slashes in path
mkdir -p "$SAVEDIR"
sed -i 's@MYSAVEDIR@'"$SAVEDIR"'@g' "$PATH_CONFIG"
printf "\n"

printf "%b\n" "${Green}create name for your samba server share (e.g batmansmb):${Color_Off}"
read -rp "New samba share name: " SERVERNAME
sed -i "s/MYSERVERNAME/$SERVERNAME/g" "$PATH_CONFIG"
printf "\n"

# create group has all users including guest users
GROUPNAME=sambashare
groupadd "$GROUPNAME"
chown :"$GROUPNAME" "$SAVEDIR"

# create group has all normal users but not including guest users
GROUPNAME_USERS=smbusers
groupadd "$GROUPNAME_USERS"

# create admins group
GROUPNAME_ADMINS=smbadmins
groupadd "$GROUPNAME_ADMINS"

# create guest user
printf "%b\n" "${Green}create guest user (e.g visitor) [read only access]:${Color_Off}"
read -rp "New guest user: " GUEST_USER
sed -i "s/MYGUESTUSER/$GUEST_USER/g" "$PATH_CONFIG"
mkdir "$SAVEDIR/everyone"
useradd -d "$SAVEDIR/everyone" -M -s /usr/sbin/nologin -G "$GROUPNAME" "$GUEST_USER"
chown "$GUEST_USER":"$GROUPNAME" "$SAVEDIR/everyone"
chmod 2770 "$SAVEDIR/everyone"
smbpasswd -a "$GUEST_USER"
smbpasswd -e "$GUEST_USER"
printf "\n"

# create normal user, add user to config, add user to groups, set inherit permissions, create samba password
printf "%b\n" "${Green}create normal user (e.g bruce) [read/write access]:${Color_Off}"
read -rp "New normal user: " NORMAL_USER
sed -i "s/MYUSERNAME/$NORMAL_USER/g" "$PATH_CONFIG"
mkdir "$SAVEDIR/$NORMAL_USER"
useradd -d "$SAVEDIR/$NORMAL_USER" -M -s /usr/sbin/nologin -G "$GROUPNAME","$GROUPNAME_USERS" "$NORMAL_USER"
chown "$NORMAL_USER":"$GROUPNAME" "$SAVEDIR/$NORMAL_USER"
chmod 2770 "$SAVEDIR/$NORMAL_USER"
smbpasswd -a "$NORMAL_USER"
smbpasswd -e "$NORMAL_USER"
printf "\n"

# create admin user
printf "%b\n" "${Green}create administrator user (e.g godmode):${Color_Off}"
read -rp "New admin user: " ADMIN_USER
sed -i "s/MYADMIN/$ADMIN_USER/g" "$PATH_CONFIG"
mkdir "$SAVEDIR/$ADMIN_USER"
useradd -d "$SAVEDIR/$ADMIN_USER" -M -s /usr/sbin/nologin -G "$GROUPNAME","$GROUPNAME_ADMINS" "$ADMIN_USER"
chown "$ADMIN_USER":"$GROUPNAME" "$SAVEDIR/$ADMIN_USER"
chmod 2770 "$SAVEDIR/$ADMIN_USER"
smbpasswd -a "$ADMIN_USER"
smbpasswd -e "$ADMIN_USER"
printf "\n"

# enable and start service on boot
systemctl enable --now "$SERVICE_NMBD" "$SERVICE_SMBD"
printf "\n"

MY_IP="$(ip addr | awk '/global/ {print $1,$2}' | cut -d'/' -f1 | cut -d' ' -f2 | head -n 1)"
printf "%b\n" "${Yellow}>>>Server will be hosted at ${Red}smb://$MY_IP ${Yellow}or ${Red}smb://$SERVERNAME${Color_Off}"
printf "%b\n" "${Purple}You might need to check your firewall/iptables configurations.${Color_Off}"
