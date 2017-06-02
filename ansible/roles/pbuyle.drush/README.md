ansible-drush
=============

Ansible role to install and configure [Drush](https://github.com/drush-ops/drush).

* Install Drush
* Configure Drush (`/etc/drush/drushrc.php`)
* Configure BASH completion

Role Variables
--------------

* **drushrc**: The content of the global Drush configuration file
  (`/etc/drush/drushrc.php`) as a dict.
* **drush_install_mode**: Install mode for, one of
    * ```composer``` (default): To install Drush for a single user using the
      Composer global require command.
    * ```git```: To install for all users on the server using a Git checkout
      and Composer.
    * ```none```: Do not install Drush.
* **drush_composer_bin**: Path the the composer binary.
* **drush_composer_version**: The version to install when using the
  ```composer``` installation mode, defaults to ```6.*```.
* **drush_composer_user**: The user to run Composer global require command as
  when using the ```composer``` installation mode, defaults to ```vagrant```.
* **drush_git_repo**: The URL of the Git repository to checkout Drush from when
  using the ```git``` installation method, defaults to
  https://github.com/drush-ops/drush.git
* **drush_git_version** The version of the repository to check out when using
  the ```git``` installation method. This can be the full 40-character SHA-1
  hash of a commit, the literal string HEAD, a branch name, or a tag name.
  Defaults to '6.2.0'.
* **drush_git_dest**: Path where to checkout Drush when using the ```git```
  installation method, default to ```/opt/drush```.
* **drush_git_bin**: The path for a symlink to the drush binary that will be
  created when using the ```git``` installation method. Make sure the directory
  containing the symlink is on the system PATH.

Example usage
-------------

    - role: drush
      drush_install_mode: git
      drushrc:
        root: /var/www
        uri: www.example.com


Requirements
------------

* Composer installed globally, if using the ```git``` or ```composer```
  installation mode.
* Make sure Composer's global bin directory is on the system PATH if using the
  ```composer``` installation mode.

TODOs
-----

* Configure Drush aliases (`/etc/drush/aliases.drushrc.php`)

License
-------

Apache v2

Author Information
------------------

Pierre Buyle <buyle@pheromone.ca>
