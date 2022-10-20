## ENV

### POSTGRES_PASSWORD
This environment variable is recommended for you to use the PostgreSQL image. This environment variable sets the superuser password for PostgreSQL. The default superuser is defined by the POSTGRES_USER environment variable.

Note 1: The PostgreSQL image sets up trust authentication locally so you may notice a password is not required when connecting from localhost (inside the same container). However, a password will be required if connecting from a different host/container.

Note 2: This variable defines the superuser password in the PostgreSQL instance, as set by the initdb script during inital container startup. It has no effect on the PGPASSWORD environment variable that may be used by the psql client at runtime, as described at https://www.postgresql.org/docs/10/static/libpq-envars.html. PGPASSWORD, if used, will be specified as a separate environment variable.

### POSTGRES_USER
This optional environment variable is used in conjunction with POSTGRES_PASSWORD to set a user and its password. This variable will create the specified user with superuser power and a database with the same name. If it is not specified, then the default user of postgres will be used.

### POSTGRES_DB
This optional environment variable can be used to define a different name for the default database that is created when the image is first started. If it is not specified, then the value of POSTGRES_USER will be used.

### POSTGRES_INITDB_ARGS
This optional environment variable can be used to send arguments to postgres initdb. The value is a space separated string of arguments as postgres initdb would expect them. This is useful for adding functionality like data page checksums: -e POSTGRES_INITDB_ARGS="--data-checksums".

### POSTGRES_INITDB_WALDIR
This optional environment variable can be used to define another location for the Postgres transaction log. By default the transaction log is stored in a subdirectory of the main Postgres data folder (PGDATA). Sometimes it can be desireable to store the transaction log in a different directory which may be backed by storage with different performance or reliability characteristics.

Note: on PostgreSQL 9.x, this variable is POSTGRES_INITDB_XLOGDIR (reflecting the changed name of the --xlogdir flag to --waldir in PostgreSQL 10+).

### postgresql.conf
- PGC_SHARED_BUFFERS
- PGC_SHARED_PRELOAD_LIBRARIES
- PGC_WAL_LEVEL
- PGC_MAX_REPLICATION_SLOTS

## PGDATA
This optional variable can be used to define another location - like a subdirectory - for the database files. The default is /var/lib/postgresql/data, but if the data volume you're using is a filesystem mountpoint (like with GCE persistent disks), Postgres initdb recommends a subdirectory (for example /var/lib/postgresql/data/pgdata ) be created to contain the data.

This is an environment variable that is not Docker specific. Because the variable is used by the postgres server binary (see the PostgreSQL docs), the entrypoint script takes it into account.

# start
```bash
# 999 is uid of `postgres` in container. connecting to
docker run --rm -u 999 \
    --name pg-test \
    -p 5532:5432 \
    -e POSTGRES_PASSWORD=123456 \
    -e PGCONF_SHARED_BUFFERS=512MB \
    -v $PWD/user.dict:/usr/share/postgresql/12/tsearch_data/jieba_user.dict \
    fj0rd/pg
```
