/usr/local/bin/surreal start -A ${SURREAL_STORE:-rocksdb}:///var/lib/surrealdb 2>&1 &
echo -n "$! " >> /var/run/services
