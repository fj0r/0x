CREATE EXTENSION parquet_s3_fdw;
CREATE SERVER parquet_s3_srv FOREIGN DATA WRAPPER parquet_s3_fdw;
CREATE SERVER parquet_s3_srv FOREIGN DATA WRAPPER parquet_s3_fdw OPTIONS (use_minio 'true');
CREATE USER MAPPING FOR public SERVER parquet_s3_srv OPTIONS (user '6', password 'B');
CREATE FOREIGN TABLE example_insert (
    c1 INT2 OPTIONS (key 'true'),
    c2 TEXT,
    c3 BOOLEAN
) SERVER parquet_s3_srv OPTIONS (filename 's3://test/example_insert.parquet');

INSERT INTO example_insert VALUES (1, 'text1', true), (2, DEFAULT, false), ((select 3), (select i from (values('values are fun!')) as foo (i)), true);
