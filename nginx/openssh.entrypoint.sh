#!/usr/bin/env bash

set -e

################################################################################
echo "[$(date -Is)] starting sshd"
################################################################################
if [[ "$DEBUG" == 'true' ]]; then
    set -x
    sed -i /etc/ssh/sshd_config \
        -e 's!.*\(LogLevel\).*!\1 DEBUG!'
fi

DAEMON=sshd

print_fingerprints() {
    local BASE_DIR=${1-'/etc/ssh'}
    for item in rsa ecdsa ed25519; do
        echo ">>> Fingerprints for ${item} host key"
        ssh-keygen -E md5 -lf ${BASE_DIR}/ssh_host_${item}_key
        ssh-keygen -E sha256 -lf ${BASE_DIR}/ssh_host_${item}_key
        ssh-keygen -E sha512 -lf ${BASE_DIR}/ssh_host_${item}_key
    done
}

# Add users if $1=user:uid:gid set
set_user () {
    IFS=':' read -ra UA <<< "$1"
    _NAME=${UA[0]}
    _UID=${UA[1]:-1000}
    _GID=${UA[2]:-1000}

    getent group ${_NAME} >/dev/null 2>&1 || groupadd -g ${_GID} ${_NAME}
    getent passwd ${_NAME} >/dev/null 2>&1 || useradd -m -u ${_UID} -g ${_GID} -G sudo -s /bin/bash -c "$2" ${_NAME}
}

init_ssh () {
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

    if [ -n "$user" ]; then
        for u in $(echo $user | tr "," "\n"); do
            set_user ${u} 'SSH User'
        done
    fi

    for i in "${!ed25519_@}"; do
        _AU=${i:8}
        _HOME_DIR=$(getent passwd ${_AU} | cut -d: -f6)
        mkdir -p ${_HOME_DIR}/.ssh
        eval "echo \"ssh-ed25519 \$$i\" >> ${_HOME_DIR}/.ssh/authorized_keys"
        chown ${_AU} -R ${_HOME_DIR}/.ssh
        chmod go-rwx -R ${_HOME_DIR}/.ssh
    done

    # Lock root account, if Disabled
    if [[ "${SSH_DISABLE_ROOT}" == "true" ]]; then
        echo "WARNING: root account is now locked. Unset SSH_DISABLE_ROOT to unlock the account."
    else
        usermod -p '' root
    fi

    # Update MOTD
    if [ -v MOTD ]; then
        echo -e "$MOTD" > /etc/motd
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

trap stop SIGINT SIGTERM #ERR EXIT
init_ssh
/usr/sbin/sshd -D -e 2>&1 &
echo -n "$! " >> /var/run/services

################################################################################
echo "[$(date -Is)] starting nginx"
################################################################################
if [ -n "$WEB_ROOT" ]; then
    sed -i 's!\(set $root\).*$!\1 '"\'$WEB_ROOT\'"';!' /etc/nginx/nginx.conf
fi

if grep -q '$ngx_resolver' /etc/nginx/nginx.conf; then
    sed -i 's/$ngx_resolver/'"${NGX_RESOLVER:-1.1.1.1}"'/' /etc/nginx/nginx.conf
fi

/opt/nginx/sbin/nginx 2>&1 &
echo -n "$! " >> /var/run/services

################################################################################

wait -n $(cat /var/run/services) && exit $?
