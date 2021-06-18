#!/usr/bin/env bash

set -Eeuo pipefail

stop () {
    echo "exit"
    pid=$(cat /var/run/sleep)
    kill -SIGTERM "${pid}"
    wait "${pid}"
}

trap stop SIGINT SIGTERM
wg-quick up wg0 &
pid="$!"
echo "${pid}" > /var/run/wg0

sleep infinity &
pid="$!"
echo "${pid}" > /var/run/sleep
wait "${pid}"

