# Add users if $1=user:uid:gid set
if [ -e /bin/zsh ]; then
    __shell=/bin/zsh
elif [ -e /bin/bash ]; then
    __shell=/bin/bash
else
    __shell=/bin/sh
fi

set_user () {
    IFS=':' read -ra ARR <<< "$1"
    _NAME=${ARR[0]}
    if [ ${_NAME} == "root" ]; then
        _UID=0
        _GID=0
    else
        _UID=${ARR[1]:-1000}
        _GID=${ARR[2]:-1000}

        getent group ${_NAME} >/dev/null 2>&1 || groupadd -g ${_GID} ${_NAME}
        getent passwd ${_NAME} >/dev/null 2>&1 || useradd -m -u ${_UID} -g ${_GID} -G sudo -s ${__shell} -c "$2" ${_NAME}
    fi

    _HOME_DIR=$(getent passwd $1 | cut -d: -f6)

    _PROFILE="${_HOME_DIR}/.profile"
    { \
        echo "" ;\
        echo "PATH=$PATH" ;\
    } >> ${_PROFILE}

    mkdir -p ${_HOME_DIR}/.ssh
    echo "ssh-ed25519 $3" >> ${_HOME_DIR}/.ssh/authorized_keys
    chown ${_NAME} -R ${_HOME_DIR}/.ssh
    chmod go-rwx -R ${_HOME_DIR}/.ssh
}

init_ssh () {
    if [ -n "$SSH_HOSTKEY_ED25519" ]; then
        echo "$SSH_HOSTKEY_ED25519" | base64 -d > /etc/dropbear/dropbear_ed25519_host_key
    fi

    for i in "${!ed25519_@}"; do
        _USER=${i:8}
        _KEY=$(eval "echo \$$i")
        set_user ${_USER} 'SSH User' ${_KEY}
    done
}

run_ssh () {
    local logfile
    if [ -n "$stdlog" ]; then
        logfile=/dev/stdout
    else
        logfile=/var/log/sshd
    fi

    if [ -z "$SSH_TIMEOUT" ]; then
        echo "starting dropbear"
        /usr/bin/dropbear -REFems -p 22 &> $logfile &
    else
        echo "starting dropbear with a timeout of ${SSH_TIMEOUT} seconds"
        /usr/bin/dropbear -REFems -p 22 -K ${SSH_TIMEOUT} -I ${SSH_TIMEOUT} &> $logfile &
    fi
    echo -n "$! " >> /var/run/services
}

__ssh=$(for i in "${!ed25519_@}"; do echo $i; done)
if [ -n "$__ssh" ] || [ -f /root/.ssh/authorized_keys ]; then
    mkdir -p /etc/dropbear
    init_ssh
    run_ssh
fi
