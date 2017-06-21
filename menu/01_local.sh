#!/bin/bash
# manage localhost - network settings, reboot
#set -x
PROGNAME=$(basename $0)
PROGPATH=/opt/drupalserver/bin
BASE_DIR=/opt/drupalserver/bin

[[ -z $DEBUG ]] && DEBUG=0

. $PROGPATH/drupal_utils.sh || exit 1


# change current hostname for host
_configure_hostname(){
  _current_hostname=$(hostname)
  _is_localhost=$(echo "$_current_hostname" | grep -c 'localhost')
  _default_note='(N|y)'
  _default_answ='n'
  config_network=/etc/hosts
  etc_hostname=/etc/hostname

  if [[ $_is_localhost -gt 0 ]]; then
    _default_note='(Y|n)'
    _default_answ='y'
  fi

  echo -e  "\033[0;32mCurrent hostname is $_current_hostname \033[0m"
  output_text "Would you like to configure hostname? $_default_note: " "" _user_answer $_default_answ
  if [[ $(echo "$_user_answer" | grep -wci 'y') -gt 0  ]]; then
     output_text "Input hostname (ex. server1) and press ENTER: " ""  _hostname
     if [[ -n "$_hostname" ]]; then
	sed -i "s/$_current_hostname/$_hostname/g" "$config_network"
        echo "Config file $config_network is updated"

        echo $_hostname > $etc_hostname
        echo "Config file $etc_hostname is updated"

        hostname $_hostname
        service networking restart
     else
       echo -e "\033[0;31mHostname can't be empty string\033[0m"
     fi

  fi
  output_text "Press ENTER for exit: " ""  any_key

}


_reboot_server(){
  output_text "Please confirm reboot of the server (N|y): " "" _reboot_ans n
  [[ $(echo "$_reboot_ans" | grep -iwc 'y') -gt 0 ]] && reboot
}

_halt_server(){
  output_text "Please confirm shutdown of the server (N|y): " "" _halt_ans n
  [[ $(echo "$_halt_ans" | grep -iwc 'y') -gt 0 ]] && halt
}

_update_server(){
  output_text "Please confirm security update of the server (N|y): " ""  _update_ans n
  if [[ $(echo "$_update_ans" | grep -iwc 'y') -gt 0 ]]; then
	if [[ -n $(aptitude update 2> /dev/null | apt-get upgrade -s | grep Security | grep Inst| awk -F " " '{print $2;}') ]]; then
		aptitude update 2> /dev/null | apt-get upgrade -s | grep Security | grep Inst| awk -F " " '{print $2;}' |xargs aptitude upgrade -y
	fi
  fi
}

# print local menu
_menu_local() {
  MENU_LOCAL_SELECT=
  until [[ -n "$MENU_LOCAL_SELECT" ]]; do
    clear;
    echo -e "\t\t\t\t\t Drupal Server Environment"
    echo -e "\t\t\t\t\t Configure local server"
    echo
    echo Available actions:
    echo -e "\t\t 1. Configure hostname"
    echo -e "\t\t 2. Reboot server"
    echo -e "\t\t 3. Shutdown server"
    echo -e "\t\t 4. Update security server"
    echo -e "\t\t 0. Previous screen or exit"

    output_text 'Enter selection: ' '' MENU_LOCAL_SELECT
    case "$MENU_LOCAL_SELECT" in
      "1") _configure_hostname; MENU_LOCAL_SELECT= ;;
      "2") _reboot_server ;;
      "3") _halt_server ;;
      "4") _update_server ;;
      "0") exit ;;
      *) error_pick;;
    esac
  done
}

_menu_local
