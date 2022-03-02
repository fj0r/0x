#!/bin/bash
if [ ! -z $STARTUP_SCRIPT ]; then
  bash $STARTUP_SCRIPT
fi

init_ssh () {
    for i in "${!ed25519_@}"; do
        _AU=${i:8}
        _HOME_DIR=$(getent passwd ${_AU} | cut -d: -f6)
        mkdir -p ${_HOME_DIR}/.ssh
        eval "echo \"ssh-ed25519 \$$i\" >> ${_HOME_DIR}/.ssh/authorized_keys"
        chown ${_AU} -R ${_HOME_DIR}/.ssh
        chmod go-rwx -R ${_HOME_DIR}/.ssh
    done

    # Fix permissions, if writable
    if [ -w ~/.ssh ]; then
        chown root:root ~/.ssh && chmod 700 ~/.ssh/
    fi
    if [ -w ~/.ssh/authorized_keys ]; then
        chown root:root ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
    fi
}

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

env | grep -E '_|HOME|ROOT|PATH|DIR|VERSION|LANG|TIME|MODULE|BUFFERED' \
    | grep -Ev '^(_|HOME|USER|LS_COLORS)=' \
   >> /etc/environment

trap stop SIGINT SIGTERM

################################################################################
echo "[$(date -Is)] starting sshd"
################################################################################
init_ssh
/usr/bin/dropbear -REFms -p 22 2>&1 &
echo -n "$! " >> /var/run/services

################################################################################
echo "[$(date -Is)] starting s3fs"
################################################################################

echo "${ACCESS_KEY}:${SECRET_KEY}" > /.passwd-s3fs
s3fs $BUCKET /data \
    -o passwd_file=/.passwd-s3fs \
    -o url=$URL \
    -o endpoint=$ENDPOINT 2>&1 &

echo -n "$! " >> /var/run/services

wait -n $(cat /var/run/services) && exit $?
