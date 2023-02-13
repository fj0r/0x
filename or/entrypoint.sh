#!/usr/bin/env bash

set -e

if [ ! -z "$PREBOOT" ]; then
  bash $PREBOOT
fi

# Add users if $1=user:uid:gid set
set_user () {
    IFS=':' read -ra UA <<< "$1"
    _NAME=${UA[0]}
    if [ ${_NAME} == "root" ]; then
        _UID=0
        _GID=0
    else
        _UID=${UA[1]:-1000}
        _GID=${UA[2]:-1000}

        getent group ${_NAME} >/dev/null 2>&1 || groupadd -g ${_GID} ${_NAME}
        getent passwd ${_NAME} >/dev/null 2>&1 || useradd -m -u ${_UID} -g ${_GID} -G sudo -s /bin/bash -c "$2" ${_NAME}
    fi

    _HOME_DIR=$(getent passwd ${_AU} | cut -d: -f6)

    _PROFILE="${_HOME_DIR}/.profile"
    echo "" >> ${_PROFILE}
    echo "PATH=$PATH" >> ${_PROFILE}

    mkdir -p ${_HOME_DIR}/.ssh
    echo "ssh-ed25519 $3" >> ${_HOME_DIR}/.ssh/authorized_keys
    chown ${_NAME} -R ${_HOME_DIR}/.ssh
    chmod go-rwx -R ${_HOME_DIR}/.ssh
}

init_ssh () {
    for i in "${!ed25519_@}"; do
        _AU=${i:8}
        _KEY=$(eval "echo \$$i")
        set_user ${_AU} 'SSH User' ${_KEY}
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

trap stop SIGINT SIGTERM #ERR EXIT

__ssh=$(for i in "${!ed25519_@}"; do echo $i; done)
if [ ! -z "$__ssh" ] || [ -f /root/.ssh/authorized_keys ]; then
    echo "[$(date -Is)] starting ssh"
    init_ssh
    mkdir -p /etc/dropbear
    /usr/bin/dropbear -REFems -p 22 -K 300 -I 600 2>&1 &
    echo -n "$! " >> /var/run/services
fi

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

