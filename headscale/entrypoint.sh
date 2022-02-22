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

env | grep -E '_|HOME|ROOT|PATH|DIR|VERSION|LANG|TIME|MODULE|BUFFERED' \
    | grep -Ev '^(_|HOME|USER|LS_COLORS)=' \
   >> /etc/environment

trap stop SIGINT SIGTERM

################################################################################
echo "[$(date -Is)] starting coredns"
################################################################################
if [ ! -f /app/config/dnsconfig/Corefile ]; then
cat << EOF > /app/config/dnsconfig/Corefile
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

mkdir -p /app/config/dnsconfig/zones

if [ ! -f /app/config/dnsconfig/zones/example ]; then
cat << EOF >  /app/config/dnsconfig/zones/example
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

/app/coredns -conf /app/config/dnsconfig/Corefile 2>&1 &
echo -n "$! " >> /var/run/services

################################################################################
echo "[$(date -Is)] starting headscale"
################################################################################
touch /var/lib/headscale/db.sqlite

yq -i e "(.ip_prefixes += \"${IP_PREFIX:-10.10.0.0/16}\")
        |(.dns_config.nameservers += \"${NAMESERVER:-8.8.8.8}\")
        |(.dns_config.domains += \"${DOMAIN}\")
        |(.server_url = \"${SERVER_URL:-http://127.0.0.1:8080}\")" \
/etc/headscale/config.yaml

headscale serve
echo -n "$! " >> /var/run/services

headscale create $NAMESPACE
token=$(headscale --namespace $NAMESPACE preauthkeys create --reusable --expiration 24h)
echo "==> tailscale up --login-server ${SERVER_URL:-<SERVER_URL>} --authkey $token"

################################################################################
wait -n $(cat /var/run/services) && exit $?