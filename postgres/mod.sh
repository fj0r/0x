FNF="$(mktemp)"
cat <<- EOF > $FNF
pg_setup_conf() {
    echo "## Setup \"$PGDATA/usr.conf\""
    echo "" > $PGDATA/usr.conf

    for i in "${!PGCONF_@}"; do
        local k=$(echo ${i:7} | tr '[:upper:]' '[:lower:]' | sed 's!__!.!g')
        local v=$(eval "echo \"\$$i\"")
        if [ -n "$v" ]; then
            echo "$k = $v" >> $PGDATA/usr.conf
        fi
    done
    echo "pg_stat_statements.max = 10000" >> $PGDATA/usr.conf
    echo "pg_stat_statements.track = all" >> $PGDATA/usr.conf
}

initialize_password() {
    if [ -z "$POSTGRES_PASSWORD" ]; then
        export POSTGRES_PASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 19)
        echo
        echo "export \$POSTGRES_PASSWORD=${POSTGRES_PASSWORD}"
        echo
    fi
}

start_ferretdb() {
    if [ -n "$FERRET_PORT" ]; then
        echo "## Setup FERRETDB"
        local FERRET_DATA=$(dirname $PGDATA)/ferretdb
        if [ ! -d "${FERRET_DATA:-}" ]; then
            mkdir -p "${FERRET_DATA}"
            if [ "$user" = '0' ]; then
                find "$FERRET_DATA" \! -user postgres -exec chown postgres '{}' +
            fi
            chmod 700 "$FERRET_DATA"
        fi
        ferretdb \
            --state-dir="${FERRET_DATA}" \
            --postgresql-url=postgres://${POSTGRES_USER:-postgres}@localhost:5432/${POSTGRES_DB:-postgres} \
            --listen-addr=0.0.0.0:${FERRET_PORT} \
            &> /var/log/postgresql/ferretdb.log &
    fi
}
EOF

sed -e "/docker_verify_minimum_env$/i initialize_password" \
    -e "/pg_setup_hba_conf \"\$@\"$/a echo \"include_if_exists = 'usr.conf'\">> \$PGDATA/postgresql.conf" \
    -e "/exec \"\$@\"$/i pg_setup_conf" \
    -e '/^_main/i cat $FNF' \
    docker-entrypoint.sh.origin

rm -f $FNF
