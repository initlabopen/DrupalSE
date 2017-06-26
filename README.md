# Drupal Server Environment

DrupalSE is a script for configuring Server Environment for Drupal using Ansible.

DrupalSE makes configuring server environments for Drupal quick and easy.

Supported operation systems:
- Debian 8 ( Wheezy )

DrupalSE will install:
- Nginx
- Php-fpm7.0
- Mysql
- Drush
- Composer

- Ntp
- Ferm
- Exim

It should take about 30 minutes to configure your virtual or dedicated server from scratch.

## Installation

Download and start DrupalSE.sh:
```bash
wget https://s3-eu-west-1.amazonaws.com/drupalse/drupalSE.sh
sh drupalSE.sh
```

Input password for user 'webmaster'

Press “1. Configure new server” for configure server

## Manage sites

### Add site

- DrupalSE menu is starting automatically when root connected to ssh. Also you can start DrupalSE menu from /root/DrupalSE_menu.sh:
```bash
sh drupalSE_menu.sh
```
- Press “2. Manage sites on the server”.
- Press “1. Create site”.
- Input site domain name.
- Input DB character set and press Enter.
  Script will display information:
  - site root folder;
  - user and password for database;
  - database name.
- Press “0. Exit” for exit.

Download drupal in _site root folder_ and install it or load dump to database.
