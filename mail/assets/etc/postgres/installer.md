# Postfix Installer #

Following script may be used for configuring complete and secure email server on fresh install of Ubuntu 18.04 LTS. It will probably work on other distributions using apt-get. After minor changes you'll be able to use it on other Linux distros.

## What it does? ##
### 02_postfix.sh: ###
- Install Postfix and configure it with TLS support.
- Install Dovecot and configure it's transport on Postfix.
- Download, extract and correct permissions for Postfixadmin.
- Download, extract and correct permissions for Roundcube. 

## 03_nginx.sh
This script is optional. It's intended to use only for nginx (I did not review this one from the fork).

### 04_opendkim.conf:
- Install opendkim packages.
- Configure opendkim for the given domain (prompt at the script).
- Set directories tree and files for the domain key at "/etc/opendkim/".
- The script can be used more than once, to configure new domains (warns will appear when needed).

## What it doesn't? ##
- It does not configure automatically postfixadmin, neither virtualhosts on apache.
- It does not configure automatically roundcube, neither virtualhosts on apache.
- It does not set anything related to DNS, those must be set manually (but it warns about).
- It does not configure Apache in no way whatsoever. 
- It does not mess or set anything related with DNS server configuration.


## Usage ##

1. Run `postfix.sh` script.
2. Configure postgres to allow connections.
3. Configure postfix admin. Remember to set these:
```
$CONF['configured'] = true;
$CONF['domain_path'] = 'YES';
$CONF['domain_in_mailbox'] = 'YES';
$CONF['database_type'] = 'pgsql';
$CONF['database_host'] = 'localhost';
$CONF['database_user'] = 'postfix_user';
$CONF['database_password'] = 'PASSWORD FROM INSTALLER SCRIPT';
$CONF['database_name'] = 'postfix_db';
```
4. Create domain and at least one user.
5. Configure roundcube. Set imap to port `993`, host to: ssl://localhost. Set smtp to port `587`, host to tls://localhost.
6. Ran and configure opendkim.sh to install opendkim and generate new keys for the given domain.

This is just a draft right now, it will be updated.
