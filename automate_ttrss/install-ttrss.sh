#!/usr/bin/env bash
# AUTHOR: gotbletu <gotbletu@gmail.com>
# SOCIAL: https://www.youtube.com/user/gotbletu|https://github.com/gotbletu|https://twitter.com/gotbletu
# DESC:   easy transmission server setup with webui login and ipblocklist
# DEMO:   https://youtu.be/EN0ycEqg8Iw
# REFF:   https://www.smarthomebeginner.com/install-transmission-web-interface-on-ubuntu-1204/
#         https://linuxconfig.org/how-to-set-up-transmission-daemon-on-a-raspberry-pi-and-control-it-via-web-interface
#         https://askubuntu.com/a/738118
#         https://www.linuxtrainingacademy.com/all-umasks/

# requires root
[ "$(whoami)" != "root" ] && exec sudo -- "$0" "$@"

# auto detect default package manager
find_pkm() { for i;do command -v "$i" > /dev/null 2>&1 && { printf "%s" "$i"; return 0;};done;return 1; }
PKMGR=$(find_pkm apt apt-get aptitude dnf emerge eopkg pacman zypper)

Color_Off='\e[0m'
Black='\e[0;30m'
Red='\e[0;31m'
Green='\e[0;32m'
Yellow='\e[0;33m'
Blue='\e[0;34m'
Purple='\e[0;35m'
Cyan='\e[0;36m'
White='\e[0;37m'

package_description()
{
__desc="${Red}========== Tiny Tiny RSS ==========${Color_Off}
Tiny Tiny RSS is a free and open source web-based news feed (RSS/Atom) reader and aggregator
https://tt-rss.org/
"
printf "%b\n" "$__desc" | fold -s
}

user_input()
{
  [ -z "${MYSQL_PASSWD}" ] && read -rsp "New MySQL Password: " MYSQL_PASSWD
  printf "\n"
  [ -z "${MYSQL_PASSWD_RETYPE}" ] && read -rsp "Retype new MySQL Password: " MYSQL_PASSWD_RETYPE
  printf "\n"
  while [[ "$MYSQL_PASSWD" != "$MYSQL_PASSWD_RETYPE" ]]; do
    printf "%b\n" "${Red}try again, password did not match${Color_Off}"
    read -rsp "New MySQL Password: " MYSQL_PASSWD
    printf "\n"
    read -rsp "Retype new MySQL Password: " MYSQL_PASSWD_RETYPE
    printf "\n"
  done

  [ -z "${TT_RSS_PASSWD}" ] && read -rsp "New TTRSS Password: " TT_RSS_PASSWD
  printf "\n"
  [ -z "${TT_RSS_PASSWD_RETYPE}" ] && read -rsp "Retype new TTRSS Password: " TT_RSS_PASSWD_RETYPE
  printf "\n"
  while [[ "$TT_RSS_PASSWD" != "$TT_RSS_PASSWD_RETYPE" ]]; do
    printf "%b\n" "${Red}try again, password did not match${Color_Off}"
    read -rsp "New TTRSS Password: " TT_RSS_PASSWD
    printf "\n"
    read -rsp "Retype new TTRSS Password: " TT_RSS_PASSWD_RETYPE
    printf "\n"
  done
}

mysql_install()
{
  # Install database.
  mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

  # systemd enable and start service
  systemctl enable --now mariadb

  # Password configuration.
  cat <<EOF | mysql_secure_installation

n
y
${MYSQL_PASSWD}
${MYSQL_PASSWD}
y
y
y
y
EOF

  # Create user and database for tt-rss.
  cat <<EOF | mysql -u root -p${MYSQL_PASSWD}
CREATE USER 'ttrss'@'localhost' IDENTIFIED BY '${TT_RSS_PASSWD}';
CREATE DATABASE ttrss;
GRANT ALL PRIVILEGES ON ttrss.* TO "ttrss"@"localhost" IDENTIFIED BY '${TT_RSS_PASSWD}';
EOF
}

php_install()
{
  # Enable PHP extension.
  sed -i /etc/php/php.ini \
      -e 's/^;extension=curl/extension=curl/g' \
      -e 's/^;extension=iconv/extension=iconv/g' \
      -e 's/^;extension=intl/extension=intl/g' \
      -e 's/^;extension=mysqli/extension=mysqli/g' \
      -e 's/^;extension=pdo_mysql/extension=pdo_mysql/g' \
      -e 's/^;extension=soap/extension=soap/g'
}

ttrss_install()
{
  # allow apache (httpd) to access tt-rss files
  ln -s /usr/share/webapps/tt-rss /srv/http/tt-rss
  chown -R http:http /usr/share/webapps/tt-rss

  # change config with user account
  sed -i /etc/webapps/tt-rss/config.php \
      -e "s;define('DB_TYPE', .*);define('DB_TYPE', \"mysql\");g" \
      -e "s;define('DB_USER', .*);define('DB_USER', \"ttrss\");g" \
      -e "s;define('DB_NAME', .*);define('DB_NAME', \"ttrss\");g" \
      -e "s;define('DB_PASS', .*);define('DB_PASS', \"${TT_RSS_PASSWD}\");g" \
      -e "s;define('SELF_URL_PATH', .*);define('SELF_URL_PATH', 'http://${MY_IP}/tt-rss');g"

  # update config
  mysql -u ttrss -p"${TT_RSS_PASSWD}" ttrss < /usr/share/webapps/tt-rss/schema/ttrss_schema_mysql.sql

  # enable tt-rss update feeds daemon
  sudo systemctl enable --now tt-rss.service
}


apache_install()
{
  # PHP configuration.
  sed -i /etc/httpd/conf/httpd.conf \
      -e 's/^LoadModule mpm_event_module/#LoadModule mpm_event_module/g' \
      -e 's/^#LoadModule mpm_prefork_module/LoadModule mpm_prefork_module/g'
  cat <<EOF | tee -a /etc/httpd/conf/httpd.conf
LoadModule php7_module modules/libphp7.so
AddHandler php7-script php
Include conf/extra/php7_module.conf
EOF
  systemctl enable --now httpd
}


package_refresh()
{
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
}

package_install()
{
  if [ "$PKMGR" = "apt" ]; then
    apt install -y coreutils gawk sed iproute2 tt-rss php mariadb apache php-apache
  elif [ "$PKMGR" = "apt-get" ]; then
    apt-get install --no-install-recommends -y coreutils gawk sed iproute2 tt-rss php mariadb apache php-apache
  elif [ "$PKMGR" = "aptitude" ]; then
    aptitude install --without-recommends -y coreutils gawk sed iproute2 tt-rss php mariadb apache php-apache
  elif [ "$PKMGR" = "dnf" ]; then
    dnf install -y coreutils gawk sed iproute2 tt-rss php mariadb apache php-apache
  elif [ "$PKMGR" = "emerge" ]; then
    emerge coreutils gawk sed iproute2 tt-rss php mariadb apache php-apache
  elif [ "$PKMGR" = "eopkg" ]; then
    eopkg install coreutils gawk sed iproute2 tt-rss php mariadb apache php-apache
  elif [ "$PKMGR" = "pacman" ]; then
    pacman --noconfirm -S coreutils gawk sed iproute2 tt-rss php mariadb apache php-apache
  elif [ "$PKMGR" = "zypper" ]; then
    zypper install -y coreutils gawk sed iproute2 tt-rss php mariadb apache php-apache
  else
    printf "%b\n" "${Red}Sorry your package manager is not supported. Exiting setup.${Color_Off}"
    exit 1
  fi
}

pacman_hooks()
{
  mkdir -p /etc/pacman.d/hooks

  cat <<EOF > /etc/pacman.d/hooks/tt-rss.hook
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = tt-rss

[Action]
Description = Updating TT-RSS Database
When = PostTransaction
Exec = /usr/bin/runuser -u http -- /usr/bin/php /usr/share/webapps/tt-rss/update.php --update-schema
EOF
}


ttrss_main()
{
  package_description
  user_input
  package_refresh
  package_install
  MY_IP="$(ip addr | awk '/global/ {print $1,$2}' | cut -d'/' -f1 | cut -d' ' -f2 | head -n 1)"
  mysql_install
  php_install
  if [ "$PKMGR" = "pacman" ]; then pacman_hooks ; fi
  ttrss_install
  apache_install
}

ttrss_main
# MY_IP="$(ip addr | awk '/global/ {print $1,$2}' | cut -d'/' -f1 | cut -d' ' -f2 | head -n 1)"
printf "%b\n" "${Yellow}>>>Server will be hosted at ${Red}http://$MY_IP/tt-rss${Color_Off}"
printf "%b\n" "${Purple}>>> Change Default Password: WEBUI > admin:password > Preferences > Users > Admin > New Password > Save ${Color_Off}"
printf "%b\n" "${Purple}>>> Allow Android Client: WEBUI > Preferences > Enable API [X] > Save Configuration ${Color_Off}"
