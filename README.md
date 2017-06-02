## ANXS - generic-directories [![Build Status](https://travis-ci.org/ANXS/generic-directories.png)](https://travis-ci.org/ANXS/generic-directories)

Ansible role which manages directories


#### Requirements & Dependencies
- Tested on Ansible 1.4 or higher.


#### Variables

```yaml
genericdirectories_directories:
  - path: "/srv/www"
    owner: "www-data"
    group: "www-data"
    mode: "0644"
    recurse: "yes"

genericdirectories_directories_removed:
  - path: "/dir/to/be/removed"
```


#### Testing
This project comes with a VagrantFile, this is a fast and easy way to test changes to the role, fire it up with `vagrant up`

See [vagrant docs](https://docs.vagrantup.com/v2/) for getting setup with vagrant


#### License

Licensed under the MIT License. See the LICENSE file for details.


#### Feedback, bug-reports, requests, ...

Are [welcome](https://github.com/ANXS/generic-directories/issues)!
