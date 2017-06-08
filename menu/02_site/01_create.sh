#!/bin/bash
# manage sites and site's options 
#set -x
PROGNAME=$(basename $0)
PROGPATH=$(dirname $0)
[[ -z $DEBUG ]] && DEBUG=0

. $PROGPATH/functions.sh || exit 1
logo=$(get_logo)
# SITE_DB
# SITE_ROOT
# SITE_CHARSET
# SITE_PASSWORD
get_options() {
    local site_name=${1}

    # site charset
    SITE_CHARSET="utf8"
    print_message "Enter site encoding (UTF8|cp1251): " "" \
        "" site_charset "$SITE_CHARSET"
    SITE_CHARSET=$(echo "$SITE_CHARSET" | awk '{print tolower($0)}')
    if [[ ( "$SITE_CHARSET" != "utf8" ) && ( "$SITE_CHARSET" != "cp1251" ) ]]; then
        print_message "Press ENTER and try again" \
            "Charset for site can contain only 'utf8' or 'cp1251'" \
            "" any_key
        return 1
    fi


    # auto options
    SITE_ROOT=          # path to document root
    SITE_DB=            # database name
    SITE_USER=          # database user
    SITE_PASSWORD=      # database password
    manual_input=N
        local site_short=$(echo "$site_name" | awk -F'.' '{print $1}')
        SITE_ROOT="/home/webmaster/domains/$site_name"
        SITE_DB="db$site_short"
        SITE_USER="user$site_short"

    if [[ -n "$SITE_PASSWORD" ]]; then
        SITE_PASSWORD_FILE=$(mktemp $CACHE_DIR/.siteXXXXXXXX)
        echo "$SITE_PASSWORD" > $SITE_PASSWORD_FILE
    fi


    if [[ $DEBUG -gt 0 ]]; then
        if [[ -n $SITE_ROOT ]]; then
            echo "SITE_ROOT:            $SITE_ROOT"
            echo "SITE_DB:              $SITE_DB"
            echo "SITE_USER:            $SITE_USER"
            [[ -f $SITE_PASSWORD_FILE ]] && \
                echo "SITE_PASSWORD_FILE:   $SITE_PASSWORD_FILE"
            echo "SITE_PASSWORD:        $SITE_PASSWORD"
        fi
        echo "SITE_CHARSET:  $site_charset"
    fi
    return 0
}


# kernel site
create_site_process() {
    local site_name=$1

    create_site_mark=N
    create_site_exe=
    until [[ "$create_site_mark" == "Y" ]]; do
        get_options "$site_name"
        [[ $? -gt 0 ]] && continue

        create_site_exe="/usr/local/bin/ansible-playbook /etc/ansible/setup_site.yml -e site_status=present -e site_name=$site_name"
        create_site_exe=$create_site_exe" -e charset=$site_charset"
        if [[ -n "$SITE_ROOT" ]]; then
            create_site_exe=$create_site_exe" -e mysql_db=$SITE_DB -e mysql_user=$SITE_USER"
            create_site_exe=$create_site_exe" -e mysql_passwd=$SITE_PASSWORD"
            create_site_exe=$create_site_exe" -e site_path=$SITE_ROOT"
        fi
        create_site_mark=Y
    done
    echo "Please wait..."
    output_exe=$(eval $create_site_exe 2>&1)
    # test on error message
    error=$(echo "$output_exe" | grep "FIALED")
    any_key=
    if [[ -n "$error" ]]; then
        print_message "CREATE_SITE error: Press ENTER for exit: " "$error" '' 'any_key'
    else
        print_message "CREATE_SITE complete: Press ENTER for exit: " '' '' 'any_key'
    fi
    [[ $DEBUG -gt 0 ]] && echo "$create_site_exe"
}


# create site
# use SITES_LIST_WITH_NUMBER for check if site exist or not
create_site() {
  site_name=$1

  # test site name
  if [[ -z "$site_name" ]]; then
    print_message "Press ENTER for exit" "Site name can not be empty" \
     "" any_key
    exit
  fi

  ### 1. test if site with defined name exists in list
  #echo "$SITES_LIST_WITH_NUMBER"
  if [[ $(echo "$SITES_LIST_WITH_NUMBER" | grep -ci "$site_name") -gt 0 ]]; then
    print_message "Press ENTER for exit" "The site with name $site_name exist in the system" \
     "" any_key
    exit
  fi

  create_site_process "$site_name"
}

# print host menu
_menu_create() {
  _menu_create_00="0. Previous screen or exit"
  _menu_create_01="   Create new site "

  _sites_logo="Create new site"

  SITE_MENU_SELECT=
  until [[ -n "$SITE_MENU_SELECT" ]]; do
    clear
    echo -e "\t\t\t" $logo
    echo -e "\t\t\t" $_sites_logo
    echo


    # menu
  SITES_LIST_WITH_NUMBER=$(python $BASE_DIR/list_sites.py)
  echo "$SITES_LIST_WITH_NUMBER"
      _menu_list="
$_menu_create_01
$_menu_create_00"

    echo Available actions:
    while IFS= read -r _menu_name
    do
      echo -e "\t\t" $_menu_name
    done <<< "$_menu_list"

     print_message 'Enter site name (ex. example.org) or 0 for exit: ' '' '' SITE_MENU_SELECT

    # process selection
    case "$SITE_MENU_SELECT" in
      "0") exit ;;
      *)
        test_hostname $SITE_MENU_SELECT
        [[ $test_hostname -eq 1 ]] && create_site "$SITE_MENU_SELECT"
        ;;
    esac

    SITE_MENU_SELECT=
  done
}

_menu_create

