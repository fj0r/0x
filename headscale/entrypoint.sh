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
echo "[$(date -Is)] starting headscale"
################################################################################
touch /var/lib/headscale/db.sqlite

if [ ! -z "$NAMESERVER" ]; then
   yq -i e ".dns_config.nameservers += \"${NAMESERVER:-8.8.8.8}\"" /headscale.config.yaml
fi

if [ ! -z "$DOMAIN" ]; then
   yq -i e ".dns_config.domains += \"${DOMAIN}\"" /headscale.config.yaml
fi

if [ ! -z "$BASE_DOMAIN" ]; then
   yq -i e ".dns_config.base_domains = \"${BASE_DOMAIN}\"" /headscale.config.yaml
fi

if [ ! -z "$GRPC_LISTEN_ADDR" ]; then
   yq -i e ".grpc_listen_addr = \"${GRPC_LISTEN_ADDR}\"" /headscale.config.yaml
fi

yq e "(.ip_prefixes += \"${IP_PREFIX:-10.10.0.0/16}\")
      |(.server_url = \"${SERVER_URL:-http://127.0.0.1:8080}\")
      " /headscale.config.yaml > /etc/headscale/config.yaml

if [ ! -f /var/lib/headscale/derp.yaml ]; then
   cp /derp-example.yaml /var/lib/headscale/derp.yaml
fi

headscale serve 2>&1 &
echo -n "$! " >> /var/run/services

headscale namespaces create $NAMESPACE

token=$(headscale --namespace $NAMESPACE preauthkeys create --reusable --expiration 24h)
echo "==> tailscale up --hostname <NAME> --login-server ${SERVER_URL:-<SERVER_URL>} --authkey $token"

################################################################################
wait -n $(cat /var/run/services) && exit $?
