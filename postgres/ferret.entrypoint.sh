start_ferretdb() {
	if [ -n "$FERRET_PORT" ]; then
		echo "## starting ferretdb"
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
