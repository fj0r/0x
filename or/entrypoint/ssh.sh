# Add users if $1=user:uid:gid set
if [ -e /bin/zsh ]; then
    __shell=/bin/zsh
elif [ -e /bin/bash ]; then
    __shell=/bin/bash
else
    __shell=/bin/sh
fi

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
        getent passwd ${_NAME} >/dev/null 2>&1 || useradd -m -u ${_UID} -g ${_GID} -G sudo -s ${__shell} -c "$2" ${_NAME}
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


__ssh=$(for i in "${!ed25519_@}"; do echo $i; done)
if [ -n "$__ssh" ] || [ -f /root/.ssh/authorized_keys ]; then
    init_ssh
    mkdir -p /etc/dropbear
    if [ -z "$SSH_TIMEOUT" ]; then
        echo "[$(date -Is)] starting ssh"
        /usr/bin/dropbear -REFems -p 22 &> /var/log/sshd &
    else
        echo "[$(date -Is)] starting ssh with a timeout of ${SSH_TIMEOUT} seconds"
        /usr/bin/dropbear -REFems -p 22 -K ${SSH_TIMEOUT} -I ${SSH_TIMEOUT} &> /var/log/sshd &
    fi
    echo -n "$! " >> /var/run/services
fi
