#!/usr/bin/env bash

addrs=""
for i in $(ls /etc/wireguard/ | grep '.*\.conf' | cut -d '.' -f 1); do
    wg-quick up $i
    addrs+="$(ip addr show $i | awk 'NR==3 {print $2}' | cut -d'/' -f 1) "
done

DAEMON=socat

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
echo "==> wg addr: ${addrs}"
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
