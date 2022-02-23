#!/usr/bin/env bash

stop() {
    echo "Received SIGINT or SIGTERM. Shutting down"
    /usr/local/bin/netclient leave -n ${name}
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
echo "[$(date -Is)] starting tailscaled"
################################################################################
tailscaled 2>&1 &
echo -n "$! " > /var/run/services

if [ ! -z "$TOKEN" ]; then
    ARG_AUTH="--authkey ${TOKEN}"
fi

################################################################################
echo "[$(date -Is)] tailscale up"
################################################################################
tailscale up --hostname ${NAME} --login-server ${HOST} ${ARG_AUTH}

################################################################################
echo "[$(date -Is)] starting derper"
################################################################################
if [ -z "$DERP_NO_VERIFY_CLIENTS" ]; then
    ARG_VERIFY="-verify-clients"
fi

if [ ! -z "$DERP_HOST" ]; then
    derper -a :10001 -stun -hostname=${DERP_HOST} ${ARG_VERIFY} 2>&1 &
    echo -n "$! " > /var/run/services
fi

################################################################################
echo "[$(date -Is)] starting coredns"
################################################################################
if [ ! -z "$COREDNS" ]; then
    if [ ! -f /var/lib/tailscale/Corefile ]; then
        cat <<- EOF > /var/lib/tailscale/Corefile
. {

    import zones/*

    #forward . 8.8.8.8 8.8.4.4 {
    #    policy sequential
    #    prefer_udp
    #    expire 10s
    #}

    reload 15s
    cache 120
    errors
    log
}
EOF
    fi

    mkdir -p /var/lib/tailscale/zones

    if [ ! -f /var/lib/tailscale/zones/example ]; then
        cat <<- EOF >  /var/lib/tailscale/zones/example
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

    /usr/local/bin/coredns -conf /var/lib/tailscale/Corefile 2>&1 &
    echo -n "$! " >> /var/run/services
fi

################################################################################
echo "[$(date -Is)] starting socat"
################################################################################

echo "==> tailscale addr: ${addr}"
for i in "${!_@}"; do
    port=${i:1}
    if [ ! -z "$port" ]; then
        url=$(eval "echo \"\$$i\"")
        cmd="socat tcp-listen:$port,reuseaddr,fork tcp:$url"
        eval "$cmd &"
        echo -n "$! " >> /var/run/services
        echo ":$port --> $url"
    fi
done

wait -n $(cat /var/run/services) && exit $?
