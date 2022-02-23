#!/usr/bin/env bash

tailscaled 2>&1 &
echo -n "$! " > /var/run/services

if [ ! -z "$TOKEN" ]; then
    ARG_AUTH="--authkey ${TOKEN}"
fi

tailscale up --hostname ${NAME} --login-server ${HOST} ${ARG_AUTH}

if [ -z "$DERP_NO_VERIFY_CLIENTS" ]; then
    ARG_VERIFY="-verify-clients"
fi

if [ ! -z "$DERP_HOST" ]; then
    derper -a :10001 -stun -hostname=${DERP_HOST} ${ARG_VERIFY} 2>&1 &
    echo -n "$! " > /var/run/services
fi


DAEMON=socat

stop() {
    echo "Received SIGINT or SIGTERM. Shutting down $DAEMON"
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
