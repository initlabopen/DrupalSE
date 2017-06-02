Dotdeb
========

Add the Dotdeb repository

Requirements
------------

Debian Wheezy/Jessie with the package python-pycurl and python-software-properties installed.

Example Playbook
-------------------------

You can add this role explicitly, but it's also depended upon by f500.nginx and f500.php

    - hosts: servers
      roles:
         - { role: f500.repo_dotdeb }

License
-------

LGPL

Author Information
------------------

Jasper N. Brouwer, jasper@nerdsweide.nl

Ramon de la Fuente, ramon@delafuente.nl
