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

source $BASEDIR/env.sh
source $BASEDIR/git.sh
source $BASEDIR/ssh.sh
source $BASEDIR/s3fs.sh
source $BASEDIR/socat.sh
source $BASEDIR/vector.sh
source $BASEDIR/cron.sh

if [ -n "${POSTBOOT}" ]; then
  bash $POSTBOOT
fi


wait -n $(cat /var/run/services) && exit $?
