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

genericdirectories_directories_removed:
  - path: "/dir/to/be/removed"
```


#### License

Licensed under the MIT License. See the LICENSE file for details.


#### Feedback, bug-reports, requests, ...

Are [welcome](https://github.com/ANXS/generic-directories/issues)!
