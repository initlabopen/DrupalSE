#!/bin/bash
export LANG=en_US.UTF-8
export TERM=linux
PROGNAME=$(basename $0)
PROGPATH=$(dirname $0)
BASE_DIR=/opt/drupalserver/bin
[[ -z $DEBUG ]] && DEBUG=0

. $PROGPATH/drupal_utils.sh || exit 1

logo=$(get_logo)


# empty pool menu
menu_create_pool_1="1. Create Management pool of server";  # create_pool_1

# manage localhost settings
menu_local_1="1. Manage localhost"

menu_sites_2="2. Manage sites in the server"                 # manage sites on the server

# default exit menu for all screens
menu_default_exit="0. Exit"

# create configuration environment
# CREATE_POOL
create_pool_1() {
    clear
  
    POOL_CREATE_OPTION_HOST=
    until [[ ( -n "$POOL_CREATE_OPTION_HOST" )  ]]; do
        clear;
        # print header
        echo -e "\t\t\t" $logo
        echo -e "\t\t\t" "Create initial config for server"
        echo

        # POOL_CREATE_OPTION_HOST
        # hostname, may be user want to change it
        _hostname=$(hostname)
        print_message "Enter new name for master (default=$_hostname): " "" \
            "" _hostname $_hostname
        # test hostname
        if [[ -n "$_hostname" ]]; then
            POOL_CREATE_OPTION_HOST=$_hostname
        else
            print_message "Want to try again(Y|n) " "Cannot use empty hostname" "" _host_user
            [[ $(echo "$_user" | grep -wci 'y') -eq 0 ]] && exit 1
        fi
    done
    PASSWD_MYSQL_ROOT=$(create_random_string)
    PASSWD_MYSQL_DEFAULT=$(create_random_string)



    [[ $DEBUG -gt 0 ]] && \
    echo "cmd=$ansible_wrapper -a create -H $POOL_CREATE_OPTION_HOST -I $POOL_CREATE_OPTION_INT"
    prepare_pool_exe="ansible-playbook /etc/ansible/prepare.yml -e _hostname=$POOL_CREATE_OPTION_HOST -e mysql_passwd_root=$PASSWD_MYSQL_ROOT -e mysql_passwd_default=$PASSWD_MYSQL_DEFAULT"
    create_pool_exe="ansible-playbook /etc/ansible/setup.yml -e _hostname=$POOL_CREATE_OPTION_HOST"
    # test on error message
    output_exe=$(eval $prepare_pool_exe 2>&1)
    output_exe1=$(eval $create_pool_exe 2>&1)
    # test on error message
    error=$(  echo "$output_exe $output_exe1" | grep 'FIALED')
    any_key=
    if [[ -n "$error" ]]; then
        print_message "POOL_CREATE error: Press ENTER for exit: " "$error" '' 'any_key'
    else
        print_message "POOL_CREATE complete: Press ENTER for exit: " '' '' 'any_key'
    fi

}

# manage localhost settings
localhost_manage(){
  $PROGPATH/menu/01_local.sh
}

# manage sites on the pool
sites_manage(){
  $PROGPATH/menu/02_site.sh
}


# main menu for pool manage
menu_server_list(){
  
  logo_msg="Configuration manager on this host"
  test_passwd_localhost

  POOL_SELECTION=
  POOL_MAIN_CONFIG=/etc/ansible/vars/drupal-hosts.yml
  until [[ "$POOL_SELECTION" == "0" ]]; do
    clear;
    # print header
    echo -e "\t\t\t" $logo
    echo -e "\t\t\t" $logo_msg
    echo
    # not found pool configuation
    if [[ ! -f $POOL_MAIN_CONFIG ]]; then
      print_header "Not found configured server's! May be You want to add new."
#      print_color_text "If you want to add the server to an existing cluster" red
#      print_color_text "Use one of the addresses listed above on master server" red
      echo Available actions:
      echo -e "\t\t " $menu_create_pool_1
      echo -e "\t\t " $menu_default_exit
      print_message 'Enter selection: ' '' '' POOL_SELECTION

      case "$POOL_SELECTION" in
        "1") create_pool_1;;
        "0") exit;;
        *)   error_pick;;
      esac
      POOL_SELECTION=
    else

      echo Available actions:
      echo -e "\t\t" $menu_local_1
      echo -e "\t\t" $menu_sites_2
      echo -e "\t\t" $menu_default_exit
      print_message 'Enter selection: ' '' '' POOL_SELECTION
      case "$POOL_SELECTION" in
        1|a)  localhost_manage;;
        2|b)  sites_manage;;
        0|z)  exit;;
        *)    error_pick;;
      esac
      POOL_SELECTION=
 
    fi
 done
}


# action part
menu_server_list
