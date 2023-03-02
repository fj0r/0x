#!/bin/bash
if [ ! -z "${PREBOOT}" ]; then
  bash $PREBOOT
fi


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

BASEDIR=$(dirname "$0")

source $BASEDIR/env.sh
source $BASEDIR/git.sh
source $BASEDIR/ssh.sh

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

if [ ! -z "${POSTBOOT}" ]; then
  bash $POSTBOOT
fi
wait -n $(cat /var/run/services) && exit $?
