#!/bin/bash
RED='\033[0;41;30m'
STD='\033[0;0;39m'
PROGNAME=$(basename $0)
PROGPATH=$(dirname $0)
BASE_DIR=/opt/drupalserver/bin
[[ -z $DEBUG ]] && DEBUG=0

. $PROGPATH/drupal_utils.sh || exit 1

# cconfigure server
configure_server_1() {
    clear
    SERVER_HOSTNAME=
    until [[ ( -n "$SERVER_HOSTNAME" )  ]]; do
        clear;
        # print header
        echo -e "\t\t\t Drupal Server Environment"
        echo -e "\t\t\t" "Create initial config for server"
        echo

        # SERVER_HOSTNAME
        # hostname, may be user want to change it
        _hostname=$(hostname)
        print_message "Enter new name for server (default=$_hostname): " "" "" _hostname $_hostname
        # test hostname
        if [[ -n "$_hostname" ]]; then
            SERVER_HOSTNAME=$_hostname
        else
            print_message "Want to try again(Y|n) " "Cannot use empty hostname" "" _host_user
            [[ $(echo "$_user" | grep -wci 'y') -eq 0 ]] && exit 1
        fi
    done
    PASSWD_MYSQL_ROOT=$(create_random_string)
    PASSWD_MYSQL_DEFAULT=$(create_random_string)

    prepare_pool_exe="ansible-playbook /etc/ansible/prepare.yml -e _hostname=$SERVER_HOSTNAME -e mysql_passwd_root=$PASSWD_MYSQL_ROOT -e mysql_passwd_default=$PASSWD_MYSQL_DEFAULT"
    create_pool_exe="ansible-playbook /etc/ansible/setup.yml -e _hostname=$SERVER_HOSTNAME"
    [[ $DEBUG -gt 0 ]] && \
    echo "$prepare_pool_exe $create_pool_exe"

    echo "Please wait..."
    output_exe=$(eval $prepare_pool_exe 2>&1)
    output_exe1=$(eval $create_pool_exe 2>&1)
    # test on error message
    error=$(echo "$output_exe $output_exe1" | grep "FIALED")
    any_key=
    if [[ -n "$error" ]]; then
        print_message "SERVER_CONFIGURE error: Press ENTER for exit: " "$error" '' 'any_key'
    else
        print_message "SERVER_CONFIGURE complete: Press ENTER for exit: " '' '' 'any_key'
    fi

}

# manage localhost settings
localhost_manage(){
  $PROGPATH/menu/01_local.sh
}

# manage sites on server
sites_manage(){
  $PROGPATH/menu/02_site.sh
}


# main menu for pool manage
main_menu_server(){

  logo_msg="Configuration manager on this host"
  test_user_localhost

  MENU_SELECTION=
  MAIN_CONFIG=/etc/ansible/vars/drupal-hosts.yml
  until [[ "$MENU_SELECTION" == "0" ]]; do
#    clear;
    echo -e "\t\t\t\t\t Drupal Server Environment"
    echo -e "\t\t\t\t\t Configuration manager on this server"
    echo
    # not found pool configuation
    if [[ ! -f $POOL_MAIN_CONFIG ]]; then
      echo -e "\t\t\t This server not configure!"
      echo
      echo "Available actions:"
      echo -e "\t\t 1. Configure new server"
      echo -e "\t\t 0. Exit"
      read -p 'Enter choice: ' MENU_SELECTION

      case "$MENU_SELECTION" in
        1|a) configure_server_1;;
        0|z) exit;;
          *) echo -e "${RED}Error...${STD}" && sleep 2;;
      esac
      MENU_SELECTION=
    else
      echo Available actions:
      echo -e "\t\t 1. Manage localhost"
      echo -e "\t\t 2. Manage sites on the server"
      echo -e "\t\t 0. Exit"
      read -p 'Enter choice: '  MENU_SELECTION
      case "$MENU_SELECTION" in
        1|a)  localhost_manage;;
        2|b)  sites_manage;;
        0|z)  exit;;
          *)  echo -e "${RED}Error...${STD}" && sleep 2;;
      esac
      MENU_SELECTION=
 
    fi
 done
}


# action part
main_menu_server
