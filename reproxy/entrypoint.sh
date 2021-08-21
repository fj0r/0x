#!/bin/bash
DAEMON=reproxy

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

cmd="/usr/local/bin/reproxy --listen=0.0.0.0:80 --gzip --max=0 --assets.location=/srv --static.enabled"
#--static.rule='*,^/api/(.*),http://${UPSTREAM_API}/api/$1'
for i in "${!RP_@}"; do
    url=${i:3}
    rule=$(eval "echo \"\$$i\"")
    cmd="${cmd} --static.rule='${rule}'"
done

eval "$cmd &"
pid="$!"
echo -n "${pid} " >> $piddir/$DAEMON.pid

wait $(cat $piddir/$DAEMON.pid) && exit $?
