#!/bin/bash
# manage sites and site's options 
#set -x
PROGNAME=$(basename $0)
PROGPATH=$(dirname $0)
[[ -z $DEBUG ]] && DEBUG=0

BASE_DIR=/opt/drupalserver/bin
[[ -z $DEBUG ]] && DEBUG=0

. $BASE_DIR/drupal_utils.sh || exit 1

delete_site() {
    site_dir=$1

    if [[ ! -d "$site_dir"  ]]; then
        print_message "Press ENTER and exit" \
            "Directory $site_dir doesn't exist in the system" \
            "" any_key
        exit 1
    fi

    delete_site_exe=
    [[ $DEBUG -gt 0 ]] && echo "$POOL_SITES_LIST"


    # try found site in menu
    is_site=$(echo "$POOL_SITES_LIST" | grep -c "$site_dir")

    # site not found, try test option site with directory
    if [[ ( $is_site -eq 0 ) ]]; then
        print_message "Press ENTER and exit" \
               "Not found site directory $site_dir" \
               "" any_key
        exit

    # site found in the list
    else
         site_name=$(basename $site_dir)
         site_short=$(echo "$site_name" | awk -F'.' '{print $1}')
         site_mysql_database="db$site_short"
         site_mysql_user="user$site_short"
	 delete_site_exe="ansible-playbook /etc/ansible/setup_site.yml -e site_status=absent -e site_name=$site_name -e site_path=$site_dir -e mysql_db=$site_mysql_database -e mysql_user=$site_mysql_user"
    fi
    echo "Please wait..."
    output_exe=$(eval $delete_site_exe 2>&1)
    # test on error message
    error=$(echo "$output_exe" | grep "FIALED")
    any_key=
    if [[ -n "$error" ]]; then
        print_message "DELETE_SITE error: Press ENTER for exit: " "$error" '' 'any_key'
    else
        print_message "DELETE_SITE complete: Press ENTER for exit: " '' '' 'any_key'
    fi

    [[ $DEBUG -gt 0 ]] && echo "$delete_site_exe"

}

# print host menu
_menu_delete() {

  SITE_MENU_SELECT=
  until [[ -n "$SITE_MENU_SELECT" ]]; do
    clear
    echo -e "\t\t\t\t\t Drupal Server Environment"
    echo -e "\t\t\t\t\t Delete site"
    echo

    # menu
    POOL_SITES_LIST=$(python $BASE_DIR/list_sites.py)
    echo "$POOL_SITES_LIST"
    echo Available actions:
    echo -e "\t\t Delete site"
    echo -e "\t\t 0. Previous screen or exit"

    print_message 'Enter site directory (ex. /home/webmaster/domains/example.com) or 0 for exit: ' '' '' SITE_MENU_SELECT

    # process selection
    case "$SITE_MENU_SELECT" in
      "0") exit ;;
      *)   delete_site "$SITE_MENU_SELECT";;
    esac
    
    SITE_MENU_SELECT=
  done
}

_menu_delete

