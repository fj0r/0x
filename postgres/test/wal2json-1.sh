pg_recvlogical -U foo -d foo --slot test_slot --create-slot -P wal2json
pg_recvlogical -U foo -d foo --slot test_slot --start -o pretty-print=1 -o format-version=2 -f -
