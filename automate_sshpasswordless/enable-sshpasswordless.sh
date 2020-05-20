#!/usr/bin/env bash
# AUTHOR: gotbletu <gotbletu@gmail.com>
# SOCIAL: https://www.youtube.com/user/gotbletu|https://github.com/gotbletu|https://twitter.com/gotbletu
# REFF:   https://github.com/gotbletu/shownotes/blob/master/ssh_passwordlesskey.txt
#         https://www.cyberciti.biz/faq/how-to-disable-ssh-password-login-on-linux/

Color_Off='\e[0m'
Red='\e[0;31m'
Green='\e[0;32m'
Yellow='\e[0;33m'

__desc="${Red}========== SSH Passwordless Login ==========${Color_Off}
Auto Login Using Generated Public Keys Over SSH
https://www.openssh.com
"
printf "%b\n" "$__desc" | fold -s

printf "%b\n" "${Green}enter your remote server address (e.g username@192.168.1.122):${Color_Off}"
read -rp "Remote Server: " REMOTE_SERVER
IP_ADDR=$(printf "%s" "$REMOTE_SERVER" | cut -d '@' -f2 | cut -d ':' -f1)
printf "\n"

printf "%b\n" "${Green}removes all keys belonging to the specified hostname/ipaddress${Color_Off}"
ssh-keygen -R "$IP_ADDR"
printf "\n"

# printf "%b\n" "${Green}generating public keys (no passphrase)${Color_Off}"
# generating public keys (no passphrase) if it does not exist
if [ ! -f ~/.ssh/id_rsa.pub ]; then
  printf "\n\n" | ssh-keygen -t rsa
  printf "\n"
fi

printf "%b\n" "${Yellow}connect to remote server to create ~/.ssh directory${Color_Off}"
ssh "$REMOTE_SERVER" "mkdir -p ~/.ssh"
printf "\n"

printf "%b\n" "${Yellow}sending public key to remote server ~/.ssh/id_rsa.pub ${Color_Off}"
ssh-copy-id -i ~/.ssh/id_rsa.pub "$REMOTE_SERVER"
printf "\n"

printf "%b\n" "${Red}>>>Reminder: you might have to restart your remote server ssh daemon to apply changes${Color_Off}"
