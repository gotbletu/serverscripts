#!/usr/bin/env bash
# AUTHOR: gotbletu <gotbletu@gmail.com>
# SOCIAL: https://www.youtube.com/user/gotbletu|https://github.com/gotbletu|https://twitter.com/gotbletu
# DESC:   simple menu to semi automate setting up common server services
# DEPEND: coreutils gawk sed ncurses iproute2 curl sudo
# DEMO:

Color_Off='\e[0m'
Black='\e[0;30m'
Red='\e[0;31m'
Green='\e[0;32m'
Yellow='\e[0;33m'
Blue='\e[0;34m'
Purple='\e[0;35m'
Cyan='\e[0;36m'
White='\e[0;37m'

MAIN_DIR="$(pwd)"
MAIN_MENU="
  ${Green}1${Color_Off}   Setup OpenSSH (SSH Secure Shell) [21]
  ${Green}1a${Color_Off}  -- Enable X11 Forwarding (Remote GUI Apps Over SSH)
  ${Green}2${Color_Off}   Setup Samba (File Server)
  ${Green}2a${Color_Off}  -- Add New Samba User
  ${Green}3${Color_Off}   Setup Transmission (Bit Torrent) [9091]
  ${Green}4${Color_Off}   Setup Kiwix (Offline Wikipedia) [49849]
  ${Green}i${Color_Off}   Show IP Address
  ${Green}r${Color_Off}   Refresh Repository
  ${Green}a${Color_Off}   About
  ${Green}q${Color_Off}   Quit
"
  # ${Green}5${Color_Off}   Setup Syncthing (File Syncing)
  # ${Green}6${Color_Off}   Setup Ubooquity (Comic & Ebook Server)
  # ${Green}7${Color_Off}   Setup Torsocks (Access Tor Network via CLI)
# ,${Green}6${Color_Off}, Setup FTP (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup Flexget (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup NFS (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup Calibre (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup Ubooquity (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup TT-RSS (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup Plex (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup miniDLNA (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup Emby (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup Seafile (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup Owncloud (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup Subsonic (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup Lychee (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup Firewall (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup ClamAV (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup VNC (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup RDP (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup TeamViewer (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup Virtualbox (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup Qemu (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup Newsboat (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup Mutt (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup Weechat (P2P File Syncing Server)
ABOUT="
  ${Green}serverscripts${Color_Off}: simple menu to semi automate setting up common server
      services. Will auto install required packages and configuration files

  AUTHOR: gotbletu (gotbletu@gmail.com)
  SOCIAL: https://www.youtube.com/user/gotbletu
          https://github.com/gotbletu
          https://twitter.com/gotbletu
"

while true; do
  clear
  echo '======================= Server Scripts ==============================='
  echo -e "$MAIN_MENU"
  echo -ne "${Green}  >>> Please make your choice: ${Color_Off}"
  read -r INPUT

  case $INPUT in
    1) # setup openssh
      clear
      cd "$MAIN_DIR" || exit
      cd automate_openssh && chmod +x install-openssh.sh && sudo ./install-openssh.sh
      read -rsp $'Press any key to return to main menu\n' -n1
    ;;
    1a) # enable X11 forwarding on openssh
      clear
      cd "$MAIN_DIR" || exit
      cd automate_openssh && chmod +x enable-openssh-x11forwarding.sh && sudo ./enable-openssh-x11forwarding.sh
      read -rsp $'Press any key to return to main menu\n' -n1
    ;;
    2) # setup samba
      clear
      cd "$MAIN_DIR" || exit
      cd automate_samba && chmod +x install-samba.sh && sudo ./install-samba.sh
      read -rsp $'Press any key to return to main menu\n' -n1
    ;;
    2a) # add new samba user
      clear
      cd "$MAIN_DIR" || exit
      cd automate_samba && chmod +x addnew-sambauser.sh && sudo ./addnew-sambauser.sh
      read -rsp $'Press any key to return to main menu\n' -n1
    ;;
    3) # setup transmission
      clear
      cd "$MAIN_DIR" || exit
      cd automate_transmission && chmod +x install-transmission.sh && sudo ./install-transmission.sh
      read -rsp $'Press any key to return to main menu\n' -n1
    ;;
    4) # setup kiwix
      clear
      cd "$MAIN_DIR" || exit
      cd automate_kiwix && chmod +x install-kiwix.sh && sudo ./install-kiwix.sh
      read -rsp $'Press any key to return to main menu\n' -n1
    ;;
    5) # setup syncthing
      clear
      cd "$MAIN_DIR" || exit
      cd automate_syncthing && chmod +x install-syncthing.sh && sudo ./install-syncthing.sh
      read -rsp $'Press any key to return to main menu\n' -n1
    ;;
    6) # setup ubooquity
      clear
      cd "$MAIN_DIR" || exit
      cd automate_ubooquity && chmod +x install-ubooquity.sh && sudo ./install-ubooquity.sh
      read -rsp $'Press any key to return to main menu\n' -n1
    ;;
    7) # setup torsocks
      clear
      cd "$MAIN_DIR" || exit
      cd automate_torsocks && chmod +x install-torsocks.sh && sudo ./install-torsocks.sh
      read -rsp $'Press any key to return to main menu\n' -n1
    ;;
    r|R) # refresh repo and install common depends
      find_pkm() { for i;do command -v "$i" > /dev/null 2>&1 && { echo "$i"; return 0;};done;return 1; }
      PKMGR=$(find_pkm apt apt-get aptitude dnf emerge eopkg pacman zypper)
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
      fi
      read -rsp $'Press any key to return to main menu\n' -n1
    ;;
    i|I)
      echo "  Username: $(whoami)"
      echo "  Local IP: $(ip addr | awk '/global/ {print $1,$2}' | cut -d'/' -f1 | cut -d' ' -f2 | head -n 1)"
      echo "  External IP: $(curl -s https://ifconfig.co/)"
      echo
      read -rsp $'  Press any key to return to main menu\n' -n1
    ;;
    q|Q)
      clear
      exit 0
    ;;
    \?|a|A)
      clear
      echo '============================ About ==================================='
      echo -e "$ABOUT"
      echo
      read -rsp $'  Press any key to return to main menu\n' -n1
    ;;
    *)
      clear
      echo "Please choose again"
      sleep 2
    ;;
  esac
done
