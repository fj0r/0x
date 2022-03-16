#!/bin/bash
if [ ! -z "${STARTUP_SCRIPT}" ]; then
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
################################################################################
__ssh=$(for i in "${!ed25519_@}"; do echo $i; done)
if [ ! -z "$__ssh" ]; then
    echo "[$(date -Is)] starting ssh"
    init_ssh
    /usr/bin/dropbear -REFms -p 22 2>&1 &
    echo -n "$! " >> /var/run/services
fi

################################################################################
################################################################################
if [ ! -z "$S3SECRET_KEY" ]; then
    echo "[$(date -Is)] starting s3fs"

    s3opt=""
    for i in "${!s3_@}"; do
        _key=${i:3}
        _value=$(eval "echo \$$i")
        if [ -z "$_value" ]; then
            s3opt+="-o $_key "
        else
            s3opt+="-o $_key=$_value "
        fi
    done

    echo "${S3ACCESS_KEY}:${S3SECRET_KEY}" > /.passwd-s3fs
    chmod go-rwx /.passwd-s3fs

    if [ ! -z "${S3REGION}" ]; then
        _region="-o endpoint=$S3REGION"
    else
        _region="-o use_path_request_style"
    fi
    mkdir -p $S3MOUNTPOINT
    cmd="s3fs -f $s3opt -o bucket=$S3BUCKET -o passwd_file=/.passwd-s3fs -o url=$S3ENDPOINT $_region $S3MOUNTPOINT"
    echo $cmd
    eval $cmd 2>&1 &
    echo -n "$! " >> /var/run/services
fi

wait -n $(cat /var/run/services) && exit $?

