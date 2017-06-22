#!/bin/bash

wget --no-check-certificate https://github.com/initlabopen/DrupalSE/archive/master.tar.gz -O /tmp/master.tar.gz >/dev/null 2>&1
cd /tmp/ >/dev/null 2>&1
tar xvf master.tar.gz >/dev/null 2>&1
/tmp/DrupalSE-master/install.sh
