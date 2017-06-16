#!/bin/bash
# manage sites and site's options 
#set -x
PROGNAME=$(basename $0)
PROGPATH=$(dirname $0)
[[ -z $DEBUG ]] && DEBUG=0

BASE_DIR=/opt/drupalserver/bin
BIN_DIR=$BASE_DIR

. $BIN_DIR/drupal_utils.sh || exit 1

sites_menu=$PROGPATH/02_site

_create_site() {
  $sites_menu/01_create.sh
}

_delete_site() {
  $sites_menu/02_delete.sh
}


# print host menu
_menu_sites() {
  SITE_MENU_SELECT=
  until [[ -n "$SITE_MENU_SELECT" ]]; do
    clear
    echo -e "\t\t\t\t\t Drupal Server Environment"
    echo -e "\t\t\t\t\t Manage sites on the server"
    echo

    # menu
    python $BASE_DIR/list_sites.py
    SITES_COUNT=$(python $BASE_DIR/list_sites_count.py)

      # define menu points
      if [[ $SITES_COUNT -eq 1 ]]; then
	echo "Available actions:"
 	echo -e "\t\t 1. Create site"
	echo -e "\t\t 0. Previous screen or exit"
	print_message 'Enter selection: ' '' '' SITE_MENU_SELECT

	# process selection
	case "$SITE_MENU_SELECT" in
	  "1") _create_site;;
	  "0") exit;;
	  *)   echo -e "${RED}Error...${STD}" && sleep 2;;
	esac
	SITE_MENU_SELECT=

      else
        echo "Available actions:"
        echo -e "\t\t 1. Create site"
        echo -e "\t\t 2. Delete site"
        echo -e "\t\t 0. Previous screen or exit"
	print_message 'Enter selection: ' '' '' SITE_MENU_SELECT

	# process selection
	case "$SITE_MENU_SELECT" in
	"1") _create_site;;
	"2") _delete_site;;
	"0") exit;;
	  *)   echo -e "${RED}Error...${STD}" && sleep 2;;
	esac
	SITE_MENU_SELECT=
      fi
  done
}

_menu_sites

