#!/usr/bin/env bash
# AUTHOR: gotbletu <gotbletu@gmail.com>
# SOCIAL: https://www.youtube.com/user/gotbletu|https://github.com/gotbletu|https://twitter.com/gotbletu
# DESC:   easy samba server setup
# DEMO:   https://youtu.be/HGO4lqh0LN8
# REFF:   https://www.digitalocean.com/community/tutorials/how-to-set-up-a-samba-share-for-a-small-organization-on-ubuntu-16-04
#         https://askubuntu.com/questions/88108/samba-share-read-only-for-guests-read-write-for-authenticated-users
#         https://getsol.us/articles/software/samba/en/


# Check for sudo access

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

SMB_CONFIG="/etc/samba/smb.conf"

echo -e "${Green}path of save directory? (e.g /media/data/samba, do not use home directory e.g /home/user/):${Color_Off}"
echo -e "${Green}>>>Note<<< directory path will auto be created if path does not exist${Color_Off}"
read -e SAVEDIR
SAVEDIR=$(echo $SAVEDIR | sed 's/\/*$//g') # remove trailing slashes in path
mkdir -p "$SAVEDIR"
cat <<EOF | tee -a "$SMB_CONFIG" > /dev/null

[MYUSERNAME]
  path = MYSAVEDIR/MYUSERNAME
  browseable = yes
  read only = no
  force create mode = 0660
  force directory mode = 2770
  valid users = MYUSERNAME @smbadmins

EOF
sed -i 's@MYSAVEDIR@'$SAVEDIR'@g' "$SMB_CONFIG"

# create group has all users including guest users
GROUPNAME=sambashare
chown :"$GROUPNAME" "$SAVEDIR"

# create group has all normal users but not including guest users
GROUPNAME_USERS=smbusers


# create normal user, add user to config, add user to groups, set inherit permissions, create samba password
echo -e "${Green}create normal user (e.g thomas) [read/write access]:${Color_Off}"
read USERNAME
sed -i "s/MYUSERNAME/$USERNAME/g" "$SMB_CONFIG"
mkdir "$SAVEDIR/$USERNAME"
useradd -d "$SAVEDIR/$USERNAME" -M -s /usr/sbin/nologin -G "$GROUPNAME","$GROUPNAME_USERS" "$USERNAME"
chown "$USERNAME":"$GROUPNAME" "$SAVEDIR/$USERNAME"
chmod 2770 "$SAVEDIR/$USERNAME"
smbpasswd -a "$USERNAME"
smbpasswd -e "$USERNAME"

# restart service
find_pkm() { for i;do which "$i" > /dev/null 2>&1 && { echo "$i"; return 0;};done;return 1; }
PKMGR=$(find_pkm apt aptitude apt-get dnf emerge pacman zypper eopkg)
if [ "$PKMGR" = "apt" ]; then
  systemctl restart nmbd.service smbd.service
elif [ "$PKMGR" = "apt-get" ]; then
  systemctl restart nmbd.service smbd.service
elif [ "$PKMGR" = "aptitude" ]; then
  systemctl restart nmbd.service smbd.service
elif [ "$PKMGR" = "emerge" ]; then
  systemctl restart nmbd.service smbd.service
elif [ "$PKMGR" = "dnf" ]; then
  systemctl restart nmb.service smb.service
elif [ "$PKMGR" = "pacman" ]; then
  systemctl restart nmb.service smb.service
elif [ "$PKMGR" = "zypper" ]; then
  systemctl restart nmb.service smb.service
elif [ "$PKMGR" = "eopkg" ]; then
  systemctl restart nmb.service smb.service
fi


printf "%s\n"

MY_IP="$(ip addr | awk '/global/ {print $1,$2}' | cut -d\/ -f1 | cut -d' ' -f2 | head -n 1)"
echo -e "${Yellow}>>>Server will be hosted at ${Red}smb://$MY_IP${Color_Off}"
