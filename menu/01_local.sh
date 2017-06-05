#!/bin/bash
# manage localhost - network settings, reboot
#set -x
export LANG=en_US.UTF-8
export TERM=linux
PROGNAME=$(basename $0)
PROGPATH=$PWD
VERBOSE=1
BASE_DIR=$PWD
LOGS_DIR=$BASE_DIR/logs
TEMP_DIR=$BASE_DIR/temp
LOGS_FILE=$LOGS_DIR/local_menu.log

. $PROGPATH/drupal_utils.sh || exit 1
logo=$(get_logo)


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

  print_color_text "Current hostname is $_current_hostname"
  print_message "Would you like to configure hostname? $_default_note: " \
   "" "" _user_answer $_default_answ
  if [[ $(echo "$_user_answer" | grep -wci 'y') -gt 0  ]]; then
     print_message "Input hostname (ex. server1) and press ENTER: " "" "" _hostname
     if [[ -n "$_hostname" ]]; then
	sed -i 's/$_current_hostname/$_hostname/g' $config_network
        echo "Config file $config_network is updated"

        echo $_hostname > $etc_hostname
        echo "Config file $etc_hostname is updated"

        hostname $_hostname
        service networking restart
     else
       print_color_text "Hostname can't be empty string" red
     fi

  fi
  print_message "Press ENTER for exit: " "" "" any_key

}


_reboot_server(){
  print_message "Please confirm reboot of the server (N|y): " \
   "" "" _reboot_ans n
  [[ $(echo "$_reboot_ans" | grep -iwc 'y') -gt 0 ]] && reboot
}

_halt_server(){
  print_message "Please confirm shutdown of the server (N|y): " \
   "" "" _halt_ans n
  [[ $(echo "$_halt_ans" | grep -iwc 'y') -gt 0 ]] && halt
}

_update_server(){
  print_message "Please confirm security update of the server (N|y): " \
   "" "" _update_ans n
  if [[ $(echo "$_update_ans" | grep -iwc 'y') -gt 0 ]]; then
	aptitude update 2> /dev/null | apt-get upgrade -s | grep Security | grep Inst| awk -F " " {'print $2'} |xargs aptitude upgrade -y
  fi
}

# print local menu
_menu_local() {
  _menu_local_01="1. Configure hostname"
  _menu_local_02="2. Reboot server"
  _menu_local_03="3. Shutdown server"
  _menu_local_04="4. Update security server"

  _menu_local_00="0. Previous screen or exit"
  _menu_list="
$_menu_local_01
$_menu_local_02
$_menu_local_03
$_menu_local_04
$_menu_local_00
"
  _local_logo="Configure local server"

  MENU_LOCAL_SELECT=
  until [[ -n "$MENU_LOCAL_SELECT" ]]; do
    clear;
    echo -e "\t\t\t" $logo
    echo -e "\t\t\t" $_local_logo
    echo

    echo Available actions:
    while IFS= read -r _menu_name
    do
      echo -e "\t\t" $_menu_name
    done <<< "$_menu_list"

    print_message 'Enter selection: ' '' '' MENU_LOCAL_SELECT
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
