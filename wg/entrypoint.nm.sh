#!/usr/bin/env bash

/usr/local/bin/netclient join --daemon off -t ${NM_TOKEN}
addr=$(netclient list | jq -r '.networks[0].current_node.private_ipv4')
name=$(netclient list | jq -r '.networks[0].name')

DAEMON=socat

piddir=/var/run/$DAEMON
mkdir -p $piddir
touch $piddir/$DAEMON.pid

stop() {
    echo "Received SIGINT or SIGTERM. Shutting down $DAEMON"
    /usr/local/bin/netclient leave -n ${name}
    # Set TERM
    kill -SIGTERM $(cat $piddir/$DAEMON.pid)
    # Wait for exit
    wait $(cat $piddir/$DAEMON.pid)
    # All done.
    echo "Done."
}

trap stop SIGINT SIGTERM
for i in "${!_@}"; do
    port=${i:1}
    if [ ! -z "$port" ]; then
        url=$(eval "echo \"\$$i\"")
        cmd="socat tcp-listen:$port,reuseaddr,fork tcp:$url"
        eval "$cmd &"
        pid="$!"
        echo "$addr:$port --> $url"
        echo -n "${pid} " >> $piddir/$DAEMON.pid
    fi
done

wait $(cat $piddir/$DAEMON.pid) && exit $?
