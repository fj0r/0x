pg_recvlogical -U postgres -d postgres --slot test_slot --create-slot -P wal2json
pg_recvlogical -U postgres -d postgres --slot test_slot --start -o pretty-print=1 -o format-version=2 -f -
