#!/bin/bash

# variables
LOG=$(mktemp /tmp/drupal-XXXXX.log)
RELEASE_FILE=/etc/debian_version
DEFAULT_SITE=/home/bitrix/www
[[ -z $SILENT ]] && SILENT=0
[[ -z $TEST_REPOSITORY ]] && TEST_REPOSITORY=0

# common subs
print(){
    msg=$1
    notice=${2:-0}
    [[ ( $SILENT -eq 0 ) && ( $notice -eq 1 ) ]] && echo -e "${msg}"
    [[ ( $SILENT -eq 0 ) && ( $notice -eq 2 ) ]] && echo -e "\e[1;31m${msg}\e[0m"
    echo "$(date +"%FT%H:%M:%S"): $$ : $msg" >> $LOG
}

print_e(){
    msg_e=$1
    print "$msg_e" 2
    print "Installation logfile - $LOG" 1
    exit 1
}

disable_selinux(){
    sestatus_cmd=$(which sestatus 2>/dev/null)
    [[ -z $sestatus_cmd ]] && return 0

    sestatus=$($sestatus_cmd | awk -F':' '/SELinux status:/{print $2}' | sed -e "s/\s\+//g")
    seconfigs="/etc/selinux/config /etc/sysconfig/selinux"
    if [[ $sestatus != "disabled" ]]; then
        print "You must disable SElinux before installing the Bitrix Environment." 1
        print "You need to reboot the server to disable SELinux"
        read -r -p "Do you want disable SELinux?(Y|n)" DISABLE
        [[ -z $DISABLE ]] && DISABLE=y
        [[ $(echo $DISABLE | grep -wci "y") -eq 0 ]] && print_e "Exit."
        for seconfig in $seconfigs; do
            [[ -f $seconfig ]] && \
                sed -i "s/SELINUX=\(enforcing\|permissive\)/SELINUX=disabled/" $seconfig && \
                print "Change SELinux state to disabled in $seconfig" 1
        done
        print "Please reboot the system! (cmd: reboot)" 1
        exit
    fi
}


apt_update(){
	print "Update system. Please wait." 1
	apt-get  update >> $LOG
}
utilit_install(){
	print "Installation utils. Please wait." 1
	apt-get -y install aptitude >> $LOG 2>&1
	aptitude -y install wget  python python-dev libssl-dev build-essential libffi-dev git >> $LOG 2>&1
}
ansible_install(){
        print "Installation ansible. Please wait." 1
	wget -O /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py >> $LOG 2>&1
	python /tmp/get-pip.py >> $LOG 2>&1
	pip install ansible >> $LOG 2>&1
}

# generate random password
randpw(){
    local len="${1:-20}"
    if [[ $DEBUG -eq 0 ]]; then
        </dev/urandom tr -dc '?!@&\-_+@%\(\)\{\}\[\]=0-9a-zA-Z' | head -c20; echo ""
    else
        </dev/urandom tr -dc '?!@&\-_+@%\(\)\{\}\[\]=' | head -c20; echo ""
    fi

}



# testing effective UID
[[ $EUID -ne 0 ]] && \
    print_e "This script must be run as root or it will fail" 

# testing OS name
[[ ! -f $RELEASE_FILE ]] && \
    print_e "This script is designed for use in OS DebianOS Linux"

# Notification
if [[ $SILENT -eq 0 ]]; then
    print "====================================================================" 2
    print "Drupal-Server-Environment for Linux installation script." 2
    print "Yes will be assumed to answers, and will be defaulted." 2
    print "'n' or 'no' will result in a No answer, anything else will be a yes." 2
    print "This script MUST be run as root or it will fail" 2
    print "====================================================================" 2
fi

disable_selinux

# update all packages
apt_update
utilit_install
ansible_install

print "Configure drupal-env.Please wait." 1
mkdir -p /opt/drupalserver/bin
cd /opt/drupalserver/bin
git clone https://github.com/kochetovd/Drupal-Server-Environment.git /opt/drupalserver/bin
mv ansible /etc/

print "Drupal Environment installation is completed." 1
rm -f $LOG
