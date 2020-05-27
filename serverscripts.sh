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
  ${Green}1${Color_Off}   Setup UFW (Uncomplicated Firewall)
  ${Green}2${Color_Off}   Setup OpenSSH (SSH Secure Shell) [22]
  ${Green}2a${Color_Off}  -- Enable X11 Forwarding (Remote GUI Apps Over SSH)
  ${Green}2b${Color_Off}  -- Disable Password Authentication (Enable Passwordless Login First)
  ${Green}2c${Color_Off}  Setup OpenSSH Passwordless Login
  ${Green}3${Color_Off}   Setup Samba (File Server) [139,445]
  ${Green}3a${Color_Off}  -- Add New Samba User
  ${Green}4${Color_Off}   Setup Kiwix (Offline Wikipedia) [49849]
  ${Green}5${Color_Off}   Setup Syncthing (File Syncing) [8384]
  ${Green}6${Color_Off}   Setup Syncthing ${Red}{@}${Color_Off} [8384]
  ${Green}7${Color_Off}   Setup Ubooquity (Comic & Ebook Server) [2022,2203/admin]
  ${Green}8${Color_Off}   Setup Torsocks (Access Tor Network via CLI) [9051]
  ${Green}9${Color_Off}   Setup Transmission (Bit Torrent) [9091]
  ${Green}0${Color_Off}   Setup Calibre (Ebook Management) ${Red}{^%}${Color_Off} [57770]
  ${Green}0a${Color_Off}  -- Manage Calibre Users
  ${Green}11${Color_Off}  Setup Tiny Tiny RSS (RSS Reader) [3306]
  ${Green}i${Color_Off}   Show IP Address
  ${Green}r${Color_Off}   Refresh Repository
  ${Green}a${Color_Off}   About
  ${Green}q${Color_Off}   Quit

  ^ = Requires X Session
  % = No SSH, Physical Only
  @ = Desktop Only, Not for Server

"
# ,${Green}6${Color_Off}, Setup TT-RSS (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup Fail2Ban (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup miniflux rss (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup Daily Snapshot (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup nginx reverse proxy (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup FTP (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup Fgallery (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup Flexget (P2P File Syncing Server)
# ,${Green}6${Color_Off}, Setup NFS (P2P File Syncing Server)
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
          https://lbry.tv/@gotbletu
          https://github.com/gotbletu
          https://twitter.com/gotbletu
"

while true; do
  printf "\033c"
  printf "%s\n" '======================= Server Scripts ==============================='
  printf "%b" "$MAIN_MENU"
  printf "%b" "${Green}  >>> Please make your choice: ${Color_Off}"
  read -r INPUT

  case $INPUT in
    1) # setup ufw firewall
      printf "\033c"
      cd "$MAIN_DIR" || exit
      cd automate_ufw && chmod +x install-ufw.sh && ./install-ufw.sh
      read -rsn1 -p "Press any key to return to main menu"
    ;;
    2) # setup openssh
      printf "\033c"
      cd "$MAIN_DIR" || exit
      cd automate_openssh && chmod +x install-openssh.sh && ./install-openssh.sh
      read -rsn1 -p "Press any key to return to main menu"
    ;;
    2a) # enable X11 forwarding on openssh
      printf "\033c"
      cd "$MAIN_DIR" || exit
      cd automate_openssh && chmod +x enable-openssh-x11forwarding.sh && ./enable-openssh-x11forwarding.sh
      read -rsn1 -p "Press any key to return to main menu"
    ;;
    2b) # disble openssh password authentication
      printf "\033c"
      cd "$MAIN_DIR" || exit
      cd automate_openssh && chmod +x disable-openssh-passwordauthentication.sh && ./disable-openssh-passwordauthentication.sh
      read -rsn1 -p "Press any key to return to main menu"
    ;;
    2c) # openssh passwordless login
      printf "\033c"
      cd "$MAIN_DIR" || exit
      cd automate_sshpasswordless && chmod +x enable-sshpasswordless.sh && ./enable-sshpasswordless.sh
      read -rsn1 -p "Press any key to return to main menu"
    ;;
    3) # setup samba
      printf "\033c"
      cd "$MAIN_DIR" || exit
      cd automate_samba && chmod +x install-samba.sh && ./install-samba.sh
      read -rsn1 -p "Press any key to return to main menu"
    ;;
    3a) # add new samba user
      printf "\033c"
      cd "$MAIN_DIR" || exit
      cd automate_samba && chmod +x addnew-sambauser.sh && ./addnew-sambauser.sh
      read -rsn1 -p "Press any key to return to main menu"
    ;;
    4) # setup kiwix
      printf "\033c"
      cd "$MAIN_DIR" || exit
      cd automate_kiwix && chmod +x install-kiwix.sh && ./install-kiwix.sh
      read -rsn1 -p "Press any key to return to main menu"
    ;;
    5) # setup syncthing
      printf "\033c"
      cd "$MAIN_DIR" || exit
      cd automate_syncthing && chmod +x install-syncthing-server.sh && ./install-syncthing-server.sh
      read -rsn1 -p "Press any key to return to main menu"
    ;;
    6) # setup syncthing for desktop user only
      printf "\033c"
      cd "$MAIN_DIR" || exit
      cd automate_syncthing && chmod +x install-syncthing-desktop.sh && ./install-syncthing-desktop.sh
      read -rsn1 -p "Press any key to return to main menu"
    ;;
    7) # setup ubooquity
      printf "\033c"
      cd "$MAIN_DIR" || exit
      cd automate_ubooquity && chmod +x install-ubooquity.sh && ./install-ubooquity.sh
      read -rsn1 -p "Press any key to return to main menu"
    ;;
    8) # setup torsocks
      printf "\033c"
      cd "$MAIN_DIR" || exit
      cd automate_torsocks && chmod +x install-torsocks.sh && ./install-torsocks.sh
      read -rsn1 -p "Press any key to return to main menu"
    ;;
    9) # setup transmission
      printf "\033c"
      cd "$MAIN_DIR" || exit
      cd automate_transmission && chmod +x install-transmission.sh && ./install-transmission.sh
      read -rsn1 -p "Press any key to return to main menu"
    ;;
    0) # setup calibre
      printf "\033c"
      cd "$MAIN_DIR" || exit
      cd automate_calibre && chmod +x install-calibre.sh && ./install-calibre.sh
      read -rsn1 -p "Press any key to return to main menu"
    ;;
    0a) # manage users calibre
      printf "\033c"
      cd "$MAIN_DIR" || exit
      cd automate_calibre && chmod +x manage-users-calibre.sh && ./manage-users-calibre.sh
      read -rsn1 -p "Press any key to return to main menu"
    ;;
    11) # setup tiny tiny rss (tt-rss)
      printf "\033c"
      cd "$MAIN_DIR" || exit
      cd automate_ttrss && chmod +x install-ttrss.sh && ./install-ttrss.sh
      read -rsn1 -p "Press any key to return to main menu"
    ;;
    r|R) # refresh repo and install common depends
      find_pkm() { for i;do command -v "$i" > /dev/null 2>&1 && { printf "%s" "$i"; return 0;};done;return 1; }
      PKMGR=$(find_pkm apt apt-get aptitude dnf emerge eopkg pacman zypper)
      if [ "$PKMGR" = "apt" ]; then
        sudo apt update
      elif [ "$PKMGR" = "apt-get" ]; then
        sudo apt-get update
      elif [ "$PKMGR" = "aptitude" ]; then
        sudo aptitude update
      elif [ "$PKMGR" = "dnf" ]; then
        sudo dnf check-update
      elif [ "$PKMGR" = "emerge" ]; then
        sudo emerge --sync
      elif [ "$PKMGR" = "eopkg" ]; then
        sudo eopkg update-repo
      elif [ "$PKMGR" = "pacman" ]; then
        sudo pacman -Syy
      elif [ "$PKMGR" = "zypper" ]; then
        sudo zypper refresh
      fi
      printf "\n"
      read -rsn1 -p "Press any key to return to main menu"
    ;;
    i)
      printf "%s\n" "  Username: $(whoami)"
      printf "%s\n" "  Local IP: $(ip addr | awk '/global/ {print $1,$2}' | cut -d'/' -f1 | cut -d' ' -f2 | head -n 1)"
      printf "%s\n" "  External IP: $(curl -s https://ifconfig.co/)"
      printf "\n"
      read -rsn1 -p "Press any key to return to main menu"
    ;;
    q)
      printf "\033c"
      exit 0
    ;;
    a)
      printf "\033c"
      printf "%s\n" '============================ About ==================================='
      printf "%b" "$ABOUT"
      printf "\n"
      read -rsn1 -p "Press any key to return to main menu"
    ;;
    *)
      printf "\033c"
      printf "%s" "Please choose again"
      sleep 2
    ;;
  esac
done
