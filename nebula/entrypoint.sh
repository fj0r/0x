#!/usr/bin/env bash

/usr/local/bin/nebula -config ${NEBULA_CONFIG:-/config.yaml}
addr=$(ip addr show nebula1 | awk 'NR==3 {print $2}' | cut -d'/' -f 1)

DAEMON=socat

piddir=/var/run/$DAEMON
mkdir -p $piddir
touch $piddir/$DAEMON.pid

stop() {
    echo "Received SIGINT or SIGTERM. Shutting down $DAEMON"
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
        echo "tcp:$addr:$port --> $url"
        echo -n "${pid} " >> $piddir/$DAEMON.pid
    fi
done
for i in "${!udp@}"; do
    port=${i:3}
    if [ ! -z "$port" ]; then
        url=$(eval "echo \"\$$i\"")
        cmd="socat udp-listen:$port,reuseaddr,fork udp:$url"
        eval "$cmd &"
        echo -n "$! " >> /var/run/services
        echo "udp:$addr:$port --> $url"
    fi
done

wait $(cat $piddir/$DAEMON.pid) && exit $?
