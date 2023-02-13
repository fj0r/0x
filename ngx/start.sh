#!/usr/bin/env bash
if [ ! -z "${PREBOOT}" ]; then
  bash $PREBOOT
fi

################################################################################
if [ -n "\$git_pull" ]; then
bash <<- EOF &
    for dir in \$(echo \$git_pull| tr "," "\n"); do
        cd \$dir
        echo "git pull in \$dir"
        git pull
    done
EOF
fi

################################################################################
#sed -i 's/$ngx_resolver/'"${NGX_RESOLVER:-1.1.1.1}"'/' /etc/nginx/nginx.conf

stop () {
    kill -s QUIT $ngx
}

trap stop SIGINT SIGTERM SIGQUIT

nginx &
ngx="$!"


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

__ssh=$(for i in "${!ed25519_@}"; do echo $i; done)
if [ ! -z "$__ssh" ] || [ -f /root/.ssh/authorized_keys ]; then
    echo "[$(date -Is)] starting ssh"
    init_ssh
    mkdir -p /etc/dropbear
    /usr/bin/dropbear -REFems -p 22 -K 300 -I 600 2>&1 &
    sshd="$!"
fi



#############################################
if [ ! -z "${POSTBOOT}" ]; then
  bash $POSTBOOT
fi
wait -n $ngx $sshd && exit $?
