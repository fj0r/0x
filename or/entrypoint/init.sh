#!/usr/bin/env bash

set -e

if [[ "$DEBUG" == 'true' ]]; then
    set -x
fi

if [ -n "${PREBOOT}" ]; then
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
    source $x
done

if [ -n "${POSTBOOT}" ]; then
  bash $POSTBOOT
fi


if [ -z $1 ]; then
    if [ -e /usr/local/bin/nu ]; then
        __shell=/usr/local/bin/nu
    fi
    exec ${__shell}
elif [[ $1 == "srv" ]]; then
    sleep infinity &
    echo -n "$! " >> /var/run/services
    wait -n $(cat /var/run/services) && exit $?
else
    exec $@
fi
