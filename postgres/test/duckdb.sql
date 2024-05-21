CREATE EXTENSION duckdb_fdw ;

CREATE SERVER duckdb_server
FOREIGN DATA WRAPPER duckdb_fdw
OPTIONS (
    database '/var/lib/postgresql/duckdb'
);

GRANT USAGE ON FOREIGN SERVER duckdb_server TO foo;

SELECT duckdb_execute('duckdb_server', 'COPY test FROM ''/tmp/test.csv'';');

CREATE FOREIGN TABLE t1(
    a integer OPTIONS (key 'true'),
    b text,
    c timestamp without time zone OPTIONS (column_type 'INT') default now()
)
SERVER duckdb_server
OPTIONS (
  table 't1_duckdb'
);

insert into t1 (a, b) values (1, 'asf'), (2, 'asff');


SELECT duckdb_execute('duckdb_server'
,'create or replace view iris_parquet  as select * from parquet_scan(''temp/iris.parquet'');');

create foreign TABLE duckdb.iris_parquet(
"Sepal.Length" float,
"Sepal.Width" float,
"Petal.Length" float,
"Petal.Width" float,
"Species" text)
      SERVER duckdb_server OPTIONS (table 'iris_parquet');

-- or an easy way

IMPORT FOREIGN SCHEMA public limit to (iris_parquet) FROM SERVER
duckdb_server INTO duckdb;
