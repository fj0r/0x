#!/bin/bash
if [ ! -z $STARTUP_SCRIPT ]; then
  bash $STARTUP_SCRIPT
fi

DAEMON=skipper

stop() {
    # Get PID
    pid=$(cat /var/run/services)
    echo "Received SIGINT or SIGTERM. Shutting down"
    # Set TERM
    kill -SIGTERM ${pid}
    # Wait for exit
    wait ${pid}
    # All done.
    echo -n '' > /var/run/services
    echo "Done."
}

trap stop SIGINT SIGTERM

routes=""
for i in "${!R_@}"; do
    n=${i:2}
    r=$(eval "echo \"\$$i\"")
    routes="${routes}${n}: ${r};"
done

if [ ! -z "$routes" ]; then
    routes="-inline-routes '${routes}'"
fi

routefile=""
if [ ! -z "$ROUTEFILE" ]; then
    routefile="-routes-file ${ROUTEFILE}"
fi

cmd="/usr/local/bin/skipper -address :80 -wait-for-healthcheck-interval 0 ${routefile} ${routes}"

eval "$cmd &"
echo -n "$! " >> /var/run/services

wait -n $(cat /var/run/services) && exit $?
