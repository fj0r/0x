#!/usr/bin/env bash

tailscaled 2>&1 &
echo -n '' > /var/run/services

tailscale up --login-server ${HOST} --authkey ${TOKEN}

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
echo "==> nm addr: ${addr}"
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
