pg_recvlogical -U foo -d foo --fsSLot test_slot --create-fsSLot -P wal2json
pg_recvlogical -U foo -d foo --fsSLot test_slot --start -o pretty-print=1 -o format-version=2 -f -
