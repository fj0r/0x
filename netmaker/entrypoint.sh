#!/usr/bin/env bash

set -e

stop() {
    echo "Received SIGINT or SIGTERM. Shutting down"
    # Get PID
    pid=$(cat /var/run/services)
    # Set TERM
    kill -SIGTERM ${pid}
    # Wait for exit
    wait ${pid}
    # All done.
    echo -n '' > /var/run/services
    echo "Done."
}

env | grep -E '_|HOME|ROOT|PATH|VERSION|LANG|TIME|MODULE|BUFFERED' \
    | grep -Ev '^(_|HOME|USER)=' \
   >> /etc/environment

trap stop SIGINT SIGTERM

################################################################################
echo "[$(date -Is)] starting coredns"
################################################################################
if [ ! -f /world/dnsconfig/Corefile ]; then
cat << EOF > /world/dnsconfig/Corefile
. {

    import zones/*

    forward . 8.8.8.8 8.8.4.4 {
        policy sequential
        prefer_udp
        expire 10s
    }

    reload 15s
    cache 120
    errors
    log
}
EOF
fi

mkdir -p /world/dnsconfig/zones

if [ ! -f /world/dnsconfig/zones/example ]; then
cat << EOF >  /world/dnsconfig/zones/example
template IN A self {
    answer "{{ .Name }} IN A 127.0.0.1"
    fallthrough
}

# 1-2-3-4.ip A 1.2.3.4
template IN A ip {
    match (^|[.])(?P<a>[0-9]*)-(?P<b>[0-9]*)-(?P<c>[0-9]*)-(?P<d>[0-9]*)[.]ip[.]$
    answer "{{ .Name }} 60 IN A {{ .Group.a }}.{{ .Group.b }}.{{ .Group.c }}.{{ .Group.d }}"
    fallthrough
}
EOF
fi

/usr/local/bin/coredns -conf /world/dnsconfig/Corefile 2>&1 &
echo -n "$! " >> /var/run/services

################################################################################
echo "[$(date -Is)] starting netmaker"
################################################################################
touch /app/data/netmaker.db

cd /app

./netmaker 2>&1 &
echo -n "$! " >> /var/run/services

################################################################################
echo "[$(date -Is)] starting nginx"
################################################################################
bash /generate_config_js.sh > /usr/share/nginx/html/config.js

echo ">>>> backend set to: $BACKEND_URL <<<<<"

sed -e 's!${WEB_PORT}!'"${WEB_PORT}"'!' \
    -e 's!${API_PORT}!'"${API_PORT}"'!' \
    /etc/nginx/nginx.conf.tmpl \
  > /etc/nginx/nginx.conf

/opt/nginx/sbin/nginx 2>&1 &
echo -n "$! " >> /var/run/services

################################################################################
wait -n $(cat /var/run/services) && exit $?
