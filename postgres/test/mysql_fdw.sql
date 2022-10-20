-- load extension first time after install
CREATE EXTENSION mysql_fdw;
-- create server object
CREATE SERVER mysql_server
    FOREIGN DATA WRAPPER mysql_fdw
    OPTIONS (host '******', port '3306');
-- create user mapping
CREATE USER MAPPING FOR postgres
	SERVER mysql_server
	OPTIONS (username 'foo', password 'bar');

CREATE SCHEMA my_prod_wms;
IMPORT FOREIGN SCHEMA "xmh_wms" FROM SERVER mysql_server INTO my_prod_wms;

