#!/usr/bin/env bash

set -e

if [[ "$DEBUG" == 'true' ]]; then
    set -x
fi

if [ -n "${PREBOOT}" ]; then
    echo "[$(date -Is)] preboot ${PREBOOT}"
    bash $PREBOOT
fi


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


trap stop SIGINT SIGTERM

BASEDIR=$(dirname "$0")

for x in $(find $BASEDIR -name '*.sh' -not -path '*/init.sh'); do
    echo "[$(date -Is)] source $x"
    source $x
done

if [ -n "${POSTBOOT}" ]; then
    echo "[$(date -Is)] postboot ${POSTBOOT}"
    bash $POSTBOOT
fi


echo "[$(date -Is)] boot completed."

if [ -z $1 ]; then
    echo "[$(date -Is)] enter interactive mode"
    if [ -e /usr/local/bin/nu ]; then
        __shell=/usr/local/bin/nu
    elif [ -e /bin/bash ]; then
        __shell=/bin/bash
    fi
    exec ${__shell}
elif [[ $1 == "srv" ]]; then
    echo "[$(date -Is)] enter srv mode"
    sleep infinity &
    echo -n "$! " >> /var/run/services
    wait -n $(cat /var/run/services) && exit $?
else
    echo "[$(date -Is)] enter batch mode"
    exec $@
fi
