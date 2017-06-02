Ansible Role: PHP-FPM-POOLS
=========

Ansible role for PHP-FPM pools configuration.

Requirements
------------

Must be running PHP-FPM
A restart php-fpm handler is used to restart PHP-FPM after configuration changes and must be defined in your playbook

Role Variables
--------------

- php_fpm_pools: List of php-fpm pools
  - **name**: Name of php-fpm pool file
  - **user**: User for pool's processes
  - **group**: Group for pool's processes
  - **listen**: Port for php-fpm
  - Othen directives - List of pool directives http://php.net/manual/en/install.fpm.configuration.php


- **php_fpm_pool_defaults**: List of default pool directives applied for every php-fpm pool
  - **pm**: dynamic
  - **pm.max_children**: 5
  - **pm.start_servers**: 2
  - **pm.min_spare_servers**: 1
  - **pm.max_spare_servers**: 3
  - **pm.status_path**: /status

- **php_fpm_default_pool**:
  - **delete**: yes - Delete default php-fpm pool.
  - **name**: www.conf - Default name for php-fpm pool.

**php_fpm_pools_directory**: "/etc/php5/fpm/pool.d" - php-fpm pool directory path

Dependencies
------------

None

Example Playbook
----------------

Example you can see in **example** folder

    - hosts: localhost
      vars_files:
        - vars/main.yml
      roles:
        - geerlingguy.php
        - initlabopen.php-fpm-pools

*Inside `vars/main.yml`*:

    php_fpm_pools:
     - name: testsite
       user: www-data
       group: www-data
       listen: 8000
       chdir: /

    php_fpm_pool_defaults:
      pm: dynamic
      pm.max_children: 150
      pm.start_servers: 20
      pm.min_spare_servers: 1
      pm.max_spare_servers: 30
      pm.status_path: /status

License
-------

BSD

Author Information
------------------

Roman Agabekov <r.agabekov@gmail.com>

# ansible-role-php-fpm-pools
