create extension clickhouse_fdw;
create server clickhouse_srv foreign data wrapper clickhouse_fdw options (
    dbname 'default',
    driver 'binary',
    host '172.17.0.1',
    port '9000'
    );
CREATE USER MAPPING FOR CURRENT_USER SERVER clickhouse_srv OPTIONS (user 'default', password '');

create schema ch;
IMPORT FOREIGN SCHEMA "default" FROM SERVER clickhouse_srv INTO ch;
