#!/bin/bash
if [ ! -z "${PREBOOT}" ]; then
  bash $PREBOOT
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
touch /var/run/services

################################################################################
################################################################################
__ssh=$(for i in "${!ed25519_@}"; do echo $i; done)
if [ ! -z "$__ssh" ] || [ -f /root/.ssh/authorized_keys ]; then
    echo "[$(date -Is)] starting ssh"
    init_ssh
    /usr/bin/dropbear -REFems -p 22 2>&1 &
    echo -n "$! " >> /var/run/services
fi

################################################################################
################################################################################
s3opt=""
for i in "${!s3_@}"; do
    _key=${i:3}
    _value=$(eval "echo \$$i")
    if [ -z "$_value" ]; then
        s3opt+="--$_key "
    else
        s3opt+="--$_key $_value "
    fi
done
# $AWS_ACCESS_KEY_ID
if [ ! -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "[$(date -Is)] starting goofys"
    cmd="/usr/local/bin/goofys -f $s3opt --endpoint $S3ENDPOINT $S3BUCKET $S3MOUNTPOINT"
    echo $cmd
    eval $cmd 2>&1 &
    echo -n "$! " >> /var/run/services
fi

if [ ! -z "${POSTBOOT}" ]; then
  bash $POSTBOOT
fi
################################################################################
wait -n $(cat /var/run/services) && exit $?

