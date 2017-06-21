

output_text(){
  DEBUG=1
    input_text=${1}
    input_color_text=${2}
    variable_name=${3}
    variable_name_default=${4}
    read_text=
    set_variable_default=0

    [[ -z "$input_text" ]] && input_text="Press ENTER for exit: "

    [[ -n "$input_color_text" ]] && echo -e "\033[0;34m$input_color_text\033[0m"
    echo

    read -r -p "$input_text" read_text
    if [[ -z "$read_text" ]]; then
        set_variable_default=1
        [[ -n "$variable_name_default" ]] && set_variable_default=2
        [[ $DEBUG -gt 0 ]] && echo "Empty input; set_variable_default=$set_variable_default"
    else
        read_text=$(printf "%q" "$read_text")
    fi

    if [[ $set_variable_default -eq 2 ]]; then
        [[ $DEBUG -gt 0 ]] && echo "variable_name="$variable_name_default
        eval "$variable_name="$variable_name_default
    else
        eval "$variable_name="$read_text
        [[ $DEBUG -gt 0 ]] && echo "variable_name="$read_text
    fi
    echo
}

# create random string
create_random_string() {
  randLength=8
  rndStr=</dev/urandom tr -dc A-Za-z0-9 | head -c $randLength
  echo $rndStr
}

# test password on localhost and start change process
test_user_localhost() {
  test_pwd=$(chage -l webmaster 2>&1)
  _test_exist_user_webmaster=$(echo "$test_pwd" |grep -e "does not exist in" -e " не существует в")
  if [[ -n "$_test_exist_user_webmaster" ]]; then
    clear
    print_color_text "You create user webmaster" red
    output_text 'Enter password for user webmaster: ' ""  PASSWD_WEBMASTER
  if [[ -z "$PASSWD_WEBMASTER" ]]; then
    output_text "Press ENTER for exit" \
    "Password user webmaster can not be empty" any_key
    exit
  fi
    HASH_PASSWD_WEBMASTER=`mkpasswd --method=SHA-512 "$PASSWD_WEBMASTER"`
    echo "Please wait..."
    output_exe=$(ansible-playbook /etc/ansible/setup_user.yml -e password_user_webmaster="$HASH_PASSWD_WEBMASTER")
    # test on error message
    error=$(echo "$output_exe" | grep "FAILED")
    any_key=
    if [[ -n "$error" ]]; then
        output_text "CREATE_USER error: Press ENTER for exit: " "$error" any_key
	exit 1
    else
        output_text "CREATE_USER complete: Press ENTER for exit: " "" any_key
    fi
  fi

}


test_hostname() {
    q_host="${1}"
    # now we forget about  63 octets long
    hostname_regexp='^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$'
    test_hostname=0
    localhost_names='^(localhost|localhost.localdom|ip6-localhost|ip6-loopback)$'
    number_names='^[0-9]+$'
    # test hostname
    if [[ -z "${q_host}" ]]; then
        output_text "Please enter any key" "Hostname cannot be empty" any_key
    else
        # test initial host name regexp
        if [[ $(echo "${q_host}" | egrep -c "$hostname_regexp" ) -gt 0 ]]; then
            # test localhost aliases
            if [[ $(echo "${q_host}" | egrep -c "$localhost_names") -gt 0 ]]; then
                output_text "Please enter any key" \
                    "Hostname='$q_host' contains alias on localhost" any_key
            # test names cannot consist entirely of numbers.
            elif [[ $(echo "${q_host}" | egrep -c "$number_names") -gt 0 ]]; then
                output_text "Please enter any key" \
                    "Hostname='$q_host' consist entirely of numbers" any_key
            # all test passed
            else
                # all ok
                test_hostname=1
            fi
        else
            echo -e  "\033[0;32mThe DNS or hostname characters are: \033[0m"
            echo " -- the numbers from 0 through 9"
            echo " -- letters from a through z"
            echo " -- the hyphen (-) character"
            echo " -- the dot (.) character"
            echo
            output_text "Please enter any key" \
                "Hostname='$q_host' contains invalid characters" any_key
        fi
    fi
}
