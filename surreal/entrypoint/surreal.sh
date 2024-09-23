/usr/local/bin/surreal start -A surrealkv:///var/lib/surrealdb 2>&1 &
echo -n "$! " >> /var/run/services
