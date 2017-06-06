export LANG=en_US.UTF-8
export TERM=linux

BASE_DIR=/opt/drupalserver/bin
LOGS_DIR=$BASE_DIR/logs
TEMP_DIR=$BASE_DIR/temp
CACHE_DIR=$BASE_DIR/tmp
BIN_DIR=$BASE_DIR/bin

LOGS_FILE=$LOGS_DIR/pool_menu.log
MENU_SPACER="------------------------------------------------------------------------------------"

[[ -z $LINK_STATUS  ]] && LINK_STATUS=1
[[ ! -d $CACHE_DIR  ]] && mkdir -m 700 $CACHE_DIR


print_color_text(){
  _color_text="$1"
  _color_name="$2"
  _echo_opt="$3"
  [[ -z "$_color_name" ]] && _color_name='green'
  _color_number=38

  case "$_color_name" in 
    green)    _color_number=32 ;;
    blue)     _color_number=34 ;;
    red)      _color_number=31 ;;
    cyan)     _color_number=36 ;;
    magenta)  _color_number=35 ;;
    *)        _color_number=39 ;;
  esac

  echo -en "\\033[1;${_color_number}m"
  echo $_echo_opt "$_color_text"
  echo -en "\\033[0;39m"
}

# save information in log file
print_log() {
  _log_message=$1
  _log_file=$2
  if [[ -n "$_log_file" ]]; then
    log_date=$(date +'%Y-%m-%dT%H:%M:%S')
    # exclude test domain
    printf "%-14s: %6d: %s\n" "$log_date" "$$" "$_log_message" >> $_log_file
  else
    printf "%-14s: %6d: %s\n" "$log_date" "$$" "$_log_message"
  fi
}

# set logo
get_logo(){
  logo="Drupal Server Environment"
  echo -e "\t\t" $logo
}

print_header(){
  _header_text=$1
  echo -e '\t\t\t' "$_header_text"
  echo
}

print_verbose(){
  _verbose_type=$1
  _verbose_message=$2
  [[ -z $VERBOSE ]] && VERBOSE=0
  if [[ $VERBOSE -gt 0 ]]; then
    print_color_text "$_verbose_type" green -n
    echo ": $_verbose_message"
  fi
}

# error message for all possible menus
error_pick(){
  notice_message="Misleading choice ... Please, try again" ;
}

# print error message
# as we use cycles, must make sure that the user sees an error
print_message(){
    _input_message=${1}       # prompt in read output
    _print_message=${2}       # colored text like a notice
    _input_format=${3}        # can add option to read 
    _input_key=${4}           # saved variable name
    _input_default=${5}       # default value for variable
    _read_input_key=
    _notset_input_key=0       # printf change empty string

    [[ -z "$_input_message" ]] && _input_message="Press ENTER for exit: "

    # print notice message
    [[ -n "$_print_message" ]] && print_color_text "$_print_message" blue -e
    echo

    # get variable value from user
    # -r If this option is given, backslash does not act as an escape character
    read $_input_format -r -p "$_input_message" _read_input_key
    if [[ -z "$_read_input_key" ]]; then
        _notset_input_key=1
        [[ -n "$_input_default" ]] && _notset_input_key=2
        [[ $DEBUG -gt 0 ]] && echo "Found empty input; _notset_input_key=$_notset_input_key"
    else
        # %q - print the associated argument shell-quoted, reusable as input
        _read_input_key=$(printf "%q" "$_read_input_key")
    fi

    # if empty set variable to default value
    if [[ $_notset_input_key -eq 2 ]]; then
        [[ $DEBUG -gt 0 ]] && echo "_input_key="$_input_default
        eval "$_input_key="$_input_default
    else
        eval "$_input_key="$_read_input_key
        [[ $DEBUG -gt 0 ]] && echo "_input_key="$_read_input_key
    fi
    echo
}

# password can't be empty
ask_password_info(){
  _password_key=$1
  _password_val=$2

  print_color_text "You must defined $_password_key password. It can't be empty!!!!" red
  echo
  _password_set=0
  _limit_request=3
  _current_tequest=0
  local _password_1=
  local _password_2=
  until [[ ( $_current_tequest -gt $_limit_request ) || ( $_password_set -eq 1 ) ]]; do
    _current_tequest=$(( $_current_tequest+1 ))

    print_message "Enter $_password_key password: " "" "-s" _password_1
    print_message "Re-enter $_password_key password: " "" "-s" _password_2
    echo
    [[  ( -n "$_password_1" )  &&  ( "$_password_1" = "$_password_2" ) ]] && _password_set=1
    if [[ "$_password_1" != "$_password_2" ]]; then
      print_color_text "Sorry, passwords do not match! Please try again." red
      _password_1=
      _password_2=
    fi
    if [[ -z "$_password_1" ]]; then
      print_color_text "Sorry, password can't be empty" red
    fi
  done

    if [[ $_password_set -eq 1 ]]; then
        _password_1=$(printf "%q" "$_password_1")
        eval "$_password_val="$_password_1
        return 0
    else
        print_message "Press ENTER for exit: " \
            "Have exhausted maximum number of retries for password set. Exit: " \
            "" any_key
        return 1
    fi

}


# create random string
create_random_string() {
  randLength=8
  rndStr=</dev/urandom tr -dc A-Za-z0-9 | head -c $randLength
  echo $rndStr
}

# test password on localhost and start change process
test_passwd_localhost() {
  test_pwd=$(chage -l webmaster 2>&1)
  _test_exist_user_webmaster=$(echo "$test_pwd" |grep 'does not exist in')
  if [[ -n "$_test_exist_user_webmaster" ]]; then
    clear
    print_color_text "You create user webmaster" red
    print_message 'Enter password for user webmaster: ' '' '' PASSWD_WEBMASTER
  # test site name
  if [[ -z "$PASSWD_WEBMASTER" ]]; then
    print_message "Press ENTER for exit" "Password user webmaster can not be empty" \
     "" any_key
    exit
  fi
    HASH_PASSWD_WEBMASTER=`mkpasswd --method=SHA-512 "$PASSWD_WEBMASTER"`
    echo "Please wait..."
#    ansible-playbook /etc/ansible/setup_user.yml -e password_user_webmaster=HASH_PASSWD_WEBMASTER
    output_exe=$(ansible-playbook /etc/ansible/setup_user.yml -e password_user_webmaster="$HASH_PASSWD_WEBMASTER")
    # test on error message
    error=$(  echo "$output_exe" | grep 'FIALED')
    any_key=
    if [[ -n "$error" ]]; then
        print_message "CREATE_USER error: Press ENTER for exit: " "$error" '' 'any_key'
	exit 1
    else
        print_message "CREATE_USER complete: Press ENTER for exit: " '' '' 'any_key'
    fi
  fi

  _test_Last_password_change=$(echo "$test_pwd" | \
    awk -F':' '/Last password change/{print $2}' | \
    sed 's/^\s\+//;s/\s\+$//;')

  if [[ $(echo "$_test_Last_password_change" | grep -ic 'password must be changed') -gt 0 ]]; then
    clear
    print_color_text "You must change password for bitrix user" red
    passwd bitrix
    if [[ $? -gt 0 ]]; then
      print_message "Press ENTER for exit" "You must changed password for user" \
       "" any_key
      exit 1
    fi
  fi
}

# https://tools.ietf.org/html/rfc1034
# http://tools.ietf.org/html/rfc1123
# http://en.wikipedia.org/wiki/Hostname
# The standard characters are: 
#   the numbers from 0 through 9, 
#   uppercase and lowercase letters from A through Z, 
#   and the hyphen (-) character. 
# Computer names cannot consist entirely of numbers.
# Preferred name syntax
# 1. test for accepted chars
# 2. test string length (for netbios name)
# IP: egrep '([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}'
test_hostname() {
    q_host="${1}"
    q_size="${2}"

    # now we forget about  63 octets long
    hostname_regexp='^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$'
    test_hostname=0
    localhost_names='^(localhost|localhost.localdom|ip6-localhost|ip6-loopback)$'
    number_names='^[0-9]+$'

    # test hostname 
    if [[ -z "${q_host}" ]]; then
        print_message "Please enter any key" \
            "Hostname cannot be empty" \
            "" any_key
    else
        # test initial host name regexp
        if [[ $(echo "${q_host}" | egrep -c "$hostname_regexp" ) -gt 0 ]]; then
            # test localhost aliases
            if [[ $(echo "${q_host}" | egrep -c "$localhost_names") -gt 0 ]]; then
                print_message "Please enter any key" \
                    "Hostname='$q_host' contains alias on localhost" \
                    "" any_key
                    
            # test names cannot consist entirely of numbers.
            elif [[ $(echo "${q_host}" | egrep -c "$number_names") -gt 0 ]]; then
                print_message "Please enter any key" \
                    "Hostname='$q_host' consist entirely of numbers" \
                    "" any_key

            # all test passed
            else
                # if limit size defined, check it
                if [[ ${q_size} -gt 0 ]] 2>/dev/null; then
                    len_hostname=$(echo "${q_host}" | wc -c)
                    # all ok
                    if [[ ${len_hostname} -le ${q_size} ]]; then
                        test_hostname=1
                    else
                        print_message "Please enter any key" \
                            "Hostname='$q_host' contains more than $q_size chars" \
                            "" any_key
                    fi
                # all ok
                else
                    test_hostname=1
                fi
            fi
        else
            print_color_text "The DNS or hostname characters are: "
            echo " -- the numbers from 0 through 9"
            echo " -- letters from a through z"
            echo " -- the hyphen (-) character"
            echo " -- the dot (.) character"
            echo 
            print_message "Please enter any key" \
                "Hostname='$q_host' contains invalid characters" \
                "" any_key
        fi
    fi
}

