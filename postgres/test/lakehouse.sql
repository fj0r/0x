CREATE EXTENSION pg_lakehouse;

CREATE FOREIGN DATA WRAPPER test_wrapper
HANDLER s3_fdw_handler
VALIDATOR s3_fdw_validator;

DROP SERVER test_server CASCADE;
CREATE SERVER test_server
FOREIGN DATA WRAPPER test_wrapper
OPTIONS (
    endpoint 'http://api.minio.s',
    region 'minio',
    allow_anonymous 'true'
);

CREATE FOREIGN TABLE trips (
    "VendorID"              INT,
    "tpep_pickup_datetime"  TIMESTAMP,
    "tpep_dropoff_datetime" TIMESTAMP,
    "passenger_count"       BIGINT,
    "trip_distance"         DOUBLE PRECISION,
    "RatecodeID"            DOUBLE PRECISION,
    "store_and_fwd_flag"    TEXT,
    "PULocationID"          REAL,
    "DOLocationID"          REAL,
    "payment_type"          DOUBLE PRECISION,
    "fare_amount"           DOUBLE PRECISION,
    "extra"                 DOUBLE PRECISION,
    "mta_tax"               DOUBLE PRECISION,
    "tip_amount"            DOUBLE PRECISION,
    "tolls_amount"          DOUBLE PRECISION,
    "improvement_surcharge" DOUBLE PRECISION,
    "total_amount"          DOUBLE PRECISION
)
SERVER test_server
OPTIONS (
    path 's3://test/yellow_tripdata_2024-01.parquet',
    extension 'parquet'
);

SELECT COUNT(*) FROM trips;

insert into trips values (123, now(), now(), 123, 123, 123, 'abc', 123, 123, 1, 2, 3, 4, 5, 6, 7, 8);
