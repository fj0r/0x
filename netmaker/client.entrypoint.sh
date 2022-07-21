#!/usr/bin/env bash

/usr/local/bin/netclient join --name ${NM_NAME} --daemon off --network ${NM_NETWORK} -t ${NM_TOKEN}
addr=$(netclient list | jq -r '.networks[0].current_node.private_ipv4')
name=$(netclient list | jq -r '.networks[0].name')

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
touch /var/run/services
echo "==> nm addr: ${addr}"
for i in "${!_@}"; do
    port=${i:1}
    if [ ! -z "$port" ]; then
        url=$(eval "echo \"\$$i\"")
        cmd="socat tcp-listen:$port,reuseaddr,fork tcp:$url"
        eval "$cmd &"
        echo -n "$! " >> /var/run/services
        echo "tcp:$port --> $url"
    fi
done
for i in "${!udp@}"; do
    port=${i:3}
    if [ ! -z "$port" ]; then
        url=$(eval "echo \"\$$i\"")
        cmd="socat udp-listen:$port,reuseaddr,fork udp:$url"
        eval "$cmd &"
        echo -n "$! " >> /var/run/services
        echo "udp:$port --> $url"
    fi
done

################################################################################
wait -n $(cat /var/run/services) && exit $?
