#!/bin/bash
DAEMON=skipper

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

routes=""
for i in "${!R_@}"; do
    n=${i:2}
    r=$(eval "echo \"\$$i\"")
    routes="${routes}${n}: ${r};"
done

cmd="/usr/local/bin/skipper -address :80 -wait-for-healthcheck-interval 0 -inline-routes '${routes}'"

eval "$cmd &"
pid="$!"
echo -n "${pid} " >> $piddir/$DAEMON.pid

wait $(cat $piddir/$DAEMON.pid) && exit $?
