#!/usr/bin/env bash

set -e

if [ ! -z "$PREBOOT" ]; then
  bash $PREBOOT
fi

if [ -e /bin/zsh ]; then
    __shell=/bin/zsh
elif [ -e /bin/bash ]; then
    __shell=/bin/bash
else
    __shell=/bin/sh
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

trap stop SIGINT SIGTERM #ERR EXIT

BASEDIR=$(dirname "$0")
source $BASEDIR/ssh.sh

if [ ! -z "${HTPASSWD}" ]; then
    IFS=':' read -ra HTP <<< "$HTPASSWD"
    printf "${HTP[0]}:$(openssl passwd -apr1 ${HTP[1]})\n" >> /etc/openresty/htpasswd
fi

echo 'starting openresty'
/opt/openresty/bin/openresty 2>&1 &
echo -n "$! " >> /var/run/services

if [ ! -z "$POSTBOOT" ]; then
  bash $POSTBOOT
fi

wait -n $(cat /var/run/services) && exit $?

