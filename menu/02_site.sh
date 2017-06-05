#!/bin/bash
# manage sites and site's options 
#set -x
PROGNAME=$(basename $0)
PROGPATH=$(dirname $0)
[[ -z $DEBUG ]] && DEBUG=0

BASE_DIR=/opt/drupalserver/bin
BIN_DIR=$BASE_DIR

. $BIN_DIR/drupal_utils.sh || exit 1

#. $PROGPATH/01_site/functions.sh || exit 1
sites_menu=$PROGPATH/02_site

logo=$(get_logo)

_create_site() {
  $sites_menu/01_create.sh
}

_delete_site() {
  $sites_menu/02_delete.sh
}


# print host menu
_menu_sites() {
  _menu_sites_00="0. Previous screen or exit"
  _menu_sites_01="1. Create site"
  _menu_sites_02="2. Delete site"

  _sites_logo="Manage sites on the server"

  SITE_MENU_SELECT=
  until [[ -n "$SITE_MENU_SELECT" ]]; do
    clear
    echo -e "\t\t\t" $logo
    echo -e "\t\t\t" $_sites_logo
    echo

    # menu
    python list_sites.py
    POOL_SITES_KERNEL_COUNT=$(python list_sites_count.py)

      # define menu points
      if [[ $POOL_SITES_KERNEL_COUNT -eq 1 ]]; then
        _menu_list="
	$_menu_sites_01
	$_menu_sites_00"
      else
        _menu_list="
	$_menu_sites_01
	$_menu_sites_02
	$_menu_sites_00"
      fi

    echo Available actions:
    while IFS= read -r _menu_name
    do
      echo -e "\t\t" $_menu_name
    done <<< "$_menu_list"

    print_message 'Enter selection: ' '' '' SITE_MENU_SELECT

    # process selection
    case "$SITE_MENU_SELECT" in
      "1") _create_site;;
      "2") _delete_site;;
      "0") exit;;
      *)   error_pick;;
    esac
    SITE_MENU_SELECT=
  done
}

_menu_sites

