#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x


print_fingerprints() {
    local BASE_DIR=${1-'/etc/ssh'}
    for item in rsa ecdsa ed25519; do
        echo ">>> Fingerprints for ${item} host key"
        ssh-keygen -E md5 -lf ${BASE_DIR}/ssh_host_${item}_key
        ssh-keygen -E sha256 -lf ${BASE_DIR}/ssh_host_${item}_key
        ssh-keygen -E sha512 -lf ${BASE_DIR}/ssh_host_${item}_key
    done
}

ssh_init() {
    env | grep _ >> /etc/environment

    if [[ "${SSH_OVERRIDE_HOST_KEYS}" == "true" ]]; then
        rm -rf /etc/ssh/ssh_host_*
    fi
    # Generate Host keys, if required
    if ls /etc/ssh/ssh_host_* 1> /dev/null 2>&1; then
        echo ">> Host keys exist in default location"
        # Don't do anything
        print_fingerprints
    else
        echo ">> Generating new host keys"
        ssh-keygen -A
        print_fingerprints /etc/ssh
    fi

    # Fix permissions, if writable
    if [ -w ~/.ssh ]; then
        chown root:root ~/.ssh && chmod 700 ~/.ssh/
    fi
    if [ -w ~/.ssh/authorized_keys ]; then
        chown root:root ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
    fi
    if [ -w /etc/authorized_keys ]; then
        chown root:root /etc/authorized_keys
        chmod 755 /etc/authorized_keys
        find /etc/authorized_keys/ -type f -exec chmod 644 {} \;
    fi

    # Add users if SSH_USERS=user:uid:gid set
    if [ -n "${SSH_USERS}" ]; then
        USERS=$(echo $SSH_USERS | tr "," "\n")
        for U in $USERS; do
            IFS=':' read -ra UA <<< "$U"
            _NAME=${UA[0]}
            _UID=${UA[1]}
            _GID=${UA[2]}

            echo ">> Adding user ${_NAME} with uid: ${_UID}, gid: ${_GID}."
            if [ ! -e "/etc/authorized_keys/${_NAME}" ]; then
                echo "WARNING: No SSH authorized_keys found for ${_NAME}!"
            fi
            getent group ${_NAME} >/dev/null 2>&1 || groupadd -g ${_GID} ${_NAME}
            getent passwd ${_NAME} >/dev/null 2>&1 || useradd -r -m -p '' -u ${_UID} -g ${_GID} -s '' -c 'SSHD User' ${_NAME}
        done
    else
        # Warn if no authorized_keys
        if [ ! -e ~/.ssh/authorized_keys ] && [ ! $(ls -A /etc/authorized_keys) ]; then
            echo "WARNING: No SSH authorized_keys found!"
        fi
    fi

    # Unlock root account, if enabled
    if [[ "${SSH_ENABLE_ROOT}" == "true" ]]; then
        usermod -p '' root
    else
        echo "WARNING: root account is now locked by default. Set SSH_ENABLE_ROOT=true to unlock the account."
    fi

    # Update MOTD
    if [ -v MOTD ]; then
        echo -e "$MOTD" > /etc/motd
    fi

}

stop() {
    echo "Received SIGINT or SIGTERM. Shutting down $DAEMON"
    # Set TERM
    kill -SIGTERM $(cat $piddir/$DAEMON.pid)
    # Wait for exit
    wait $(cat $piddir/$DAEMON.pid)
    # All done.
    echo "Done."
}

trap stop SIGINT SIGTERM

piddir=/var/run/$DAEMON
mkdir -p $piddir

###########################
ssh_init
/usr/sbin/sshd -D -e &
pid="$!"
echo -n "${pid}" >> $piddir/sshd.pid

###########################
/usr/local/bin/websocat -E -b ws-l:0.0.0.0:9999 tcp:127.0.0.1:22 &
pid="$!"
echo -n "${pid}" >> $piddir/websocat.pid

###########################
DAEMON=skipper

routes=""
for i in "${!R_@}"; do
    n=${i:2}
    r=$(eval "echo \"\$$i\"")
    routes="${routes}${n}: ${r};"
done

if [ ! -z "$routes" ]; then
    routes="-inline-routes '${routes}'"
fi

cmd="/usr/local/bin/skipper -address :80 -wait-for-healthcheck-interval 0 -routes-file /eskip ${routes}"

eval "$cmd &"
pid="$!"
echo -n "${pid}" >> $piddir/$DAEMON.pid
###########################

wait $(cat $piddir/$DAEMON.pid) && exit $?
