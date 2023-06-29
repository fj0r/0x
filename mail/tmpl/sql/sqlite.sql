CREATE TABLE alias (
    address varchar(255) NOT NULL,
    goto text NOT NULL,
    domain varchar(255) NOT NULL,
    created datetime NOT NULL default '0000-00-00 00:00:00',
    modified datetime NOT NULL default '0000-00-00 00:00:00',
    active tinyint(1) NOT NULL default '1');

CREATE TABLE domain (
    domain varchar(255) NOT NULL,
    description varchar(255) NOT NULL,
    aliases int(10) NOT NULL default '0',
    mailboxes int(10) NOT NULL default '0',
    maxquota bigint(20) NOT NULL default '0',
    quota bigint(20) NOT NULL default '0',
    transport varchar(255) NOT NULL,
    backupmx tinyint(1) NOT NULL default '0',
    created datetime NOT NULL default '0000-00-00 00:00:00',
    modified datetime NOT NULL default '0000-00-00 00:00:00',
    active tinyint(1) NOT NULL default '1' );

CREATE TABLE mailbox (
    username varchar(255) NOT NULL,
    password varchar(255) NOT NULL,
    name varchar(255) NOT NULL,
    maildir varchar(255) NOT NULL,
    quota bigint(20) NOT NULL default '0',
    domain varchar(255) NOT NULL,
    created datetime NOT NULL default '0000-00-00 00:00:00',
    modified datetime NOT NULL default '0000-00-00 00:00:00',
    local_part varchar(255) NOT NULL,
    active tinyint(1) NOT NULL default '1');

INSERT INTO domain ( domain, description, transport )
	VALUES ( '{{ HOST }}', '', 'virtual' );

INSERT INTO mailbox ( username, password, name, maildir, domain, local_part )
	VALUES ( '{{ MASTER }}@{{ HOST }}', '{{ PASSWD_DIGEST }}', '{{ MASTER }}', '{{ HOST }}/{{ MASTER }}@{{ HOST }}/', '{{ HOST }}', '{{ MASTER }}' );

INSERT INTO alias ( address, goto, domain )
	VALUES ( '{{ MASTER }}@{{ HOST }}', '{{ MASTER }}@{{ HOST }}', '{{ HOST }}' );
