#!/bin/bash

# variables
LOG=$(mktemp /tmp/drupal-XXXXX.log)
RELEASE_FILE=/etc/debian_version
DEFAULT_SITE=/home/webmaster/domains/www/html

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


apt_update(){
	print "Update system. Please wait." 1
	apt-get  update >> $LOG
}
utilit_install(){
	print "Installation utils. Please wait." 1
	apt-get -y install aptitude >> $LOG 2>&1
	aptitude -y install wget  python python-dev libssl-dev build-essential libffi-dev git whois >> $LOG 2>&1
}
ansible_install(){
        print "Installation ansible. Please wait." 1
	wget -O /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py >> $LOG 2>&1
	python /tmp/get-pip.py >> $LOG 2>&1
	pip install ansible >> $LOG 2>&1
}

# testing effective UID
[[ $EUID -ne 0 ]] && \
    print_e "This script must be run as root or it will fail"

# testing OS name
[[ ! -f $RELEASE_FILE ]] && \
    print_e "This script is designed for use in OS Debian Linux"

# Notification
if [[ $SILENT -eq 0 ]]; then
    print "====================================================================" 2
    print "Drupal-Server-Environment for Linux installation script." 2
    print "Yes will be assumed to answers, and will be defaulted." 2
    print "'n' or 'no' will result in a No answer, anything else will be a yes." 2
    print "This script MUST be run as root or it will fail" 2
    print "====================================================================" 2
fi


# update all packages
apt_update
utilit_install
ansible_install

print "Configure drupal-env.Please wait." 1
wget --no-check-certificate https://github.com/initlabopen/DrupalSE/archive/master.tar.gz -O /tmp/master.tar.gz >> $LOG 2>&1
cd /tmp/
tar xvf master.tar.gz >> $LOG 2>&1
mkdir -p /opt/drupalserver/bin
rsync -av /tmp/DrupalSE-master/ansible /etc/ >> $LOG 2>&1
rm -rf /tmp/DrupalSE-master/ansible
rsync -av /tmp/DrupalSE-master/ /opt/drupalserver/bin/ >> $LOG 2>&1
mv /opt/drupalserver/bin/drupalSE_menu.sh /root/
chmod +x /root/drupalSE_menu.sh
touch /root/.bash_profile
if [[ $(cat /root/.bash_profile |grep -wci 'drupalSE_menu.sh') -eq "0" ]]; then
	echo -e "#menu\n~/drupalSE_menu.sh" >> /root/.bash_profile
fi
print "Drupal Environment installation is completed." 1
rm -f $LOG
sleep 5
/root/drupalSE_menu.sh
