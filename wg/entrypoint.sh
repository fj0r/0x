#!/usr/bin/env bash

addrs=""
for i in $(ls /etc/wireguard/ | grep '.*\.conf' | cut -d '.' -f 1); do
    wg-quick up $i
    addrs+="$(ip addr show $i | awk 'NR==3 {print $2}' | cut -d'/' -f 1) "
done

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
echo "==> wg addr: ${addrs}"
for i in "${!_@}"; do
    port=${i:1}
    if [ ! -z "$port" ]; then
        url=$(eval "echo \"\$$i\"")
        cmd="socat tcp-listen:$port,reuseaddr,fork tcp:$url"
        eval "$cmd &"
        pid="$!"
        echo ":$port --> $url"
        echo -n "${pid} " >> $piddir/$DAEMON.pid
    fi
done

wait $(cat $piddir/$DAEMON.pid) && exit $?
