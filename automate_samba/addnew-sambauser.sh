#!/usr/bin/env bash
# AUTHOR: gotbletu <gotbletu@gmail.com>
# SOCIAL: https://www.youtube.com/user/gotbletu|https://github.com/gotbletu|https://twitter.com/gotbletu
# DESC:   easy add new samba normal user
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

__desc="${Red}========== Add New Samba User ==========${Color_Off}
Adding A Normal Samba User To The Existing Samba Share Group
https://www.samba.org
"
printf "%b\n" "$__desc" | fold -s

PATH_CONFIG="/etc/samba/smb.conf"

printf "%b\n" "${Green}path of save directory? (e.g /media/data/samba, do not use home directory /home/user/):${Color_Off}"
printf "%b\n" "${Green}>>>Note<<< directory path will auto be created if path does not exist${Color_Off}"
read -rep "Save Directory: " SAVEDIR
SAVEDIR=$(printf "%s" "$SAVEDIR" | sed 's/\/*$//g') # remove trailing slashes in path
mkdir -p "$SAVEDIR"
cat <<EOF | tee -a "$PATH_CONFIG" > /dev/null

[MYUSERNAME]
  path = MYSAVEDIR/MYUSERNAME
  browseable = yes
  read only = no
  force create mode = 0660
  force directory mode = 2770
  valid users = MYUSERNAME @smbadmins

EOF
sed -i 's@MYSAVEDIR@'"$SAVEDIR"'@g' "$PATH_CONFIG"

# create group has all users including guest users
GROUPNAME=sambashare
chown :"$GROUPNAME" "$SAVEDIR"

# create group has all normal users but not including guest users
GROUPNAME_USERS=smbusers

# create normal user, add user to config, add user to groups, set inherit permissions, create samba password
printf "%b\n" "${Green}create normal user (e.g thomas) [read/write access]:${Color_Off}"
read -rp "New normal user: " NORMAL_USER
sed -i "s/MYUSERNAME/$NORMAL_USER/g" "$PATH_CONFIG"
mkdir "$SAVEDIR/$NORMAL_USER"
useradd -d "$SAVEDIR/$NORMAL_USER" -M -s /usr/sbin/nologin -G "$GROUPNAME","$GROUPNAME_USERS" "$NORMAL_USER"
chown "$NORMAL_USER":"$GROUPNAME" "$SAVEDIR/$NORMAL_USER"
chmod 2770 "$SAVEDIR/$NORMAL_USER"
smbpasswd -a "$NORMAL_USER"
smbpasswd -e "$NORMAL_USER"

# restart service
find_pkm() { for i;do command -v "$i" > /dev/null 2>&1 && { printf "%s" "$i"; return 0;};done;return 1; }
PKMGR=$(find_pkm apt aptitude apt-get dnf emerge pacman zypper eopkg)
if [ "$PKMGR" = "apt" ]; then
  systemctl restart nmbd.service smbd.service
elif [ "$PKMGR" = "apt-get" ]; then
  systemctl restart nmbd.service smbd.service
elif [ "$PKMGR" = "aptitude" ]; then
  systemctl restart nmbd.service smbd.service
elif [ "$PKMGR" = "dnf" ]; then
  systemctl restart nmb.service smb.service
elif [ "$PKMGR" = "emerge" ]; then
  systemctl restart nmbd.service smbd.service
elif [ "$PKMGR" = "eopkg" ]; then
  systemctl restart nmb.service smb.service
elif [ "$PKMGR" = "pacman" ]; then
  systemctl restart nmb.service smb.service
elif [ "$PKMGR" = "zypper" ]; then
  systemctl restart nmb.service smb.service
fi

printf "\n"

MY_IP="$(ip addr | awk '/global/ {print $1,$2}' | cut -d'/' -f1 | cut -d' ' -f2 | head -n 1)"
printf "%b\n" "${Yellow}>>>Server will be hosted at ${Red}smb://$MY_IP${Color_Off}"
