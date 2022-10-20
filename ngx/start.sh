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

__ssh=$(for i in "${!ed25519_@}"; do echo $i; done)
if [ ! -z "$__ssh" ] || [ -f /root/.ssh/authorized_keys ]; then
    echo "[$(date -Is)] starting ssh"
    init_ssh
    /usr/bin/dropbear -REFems -p 22 -K 300 -I 600 2>&1 &
    sshd="$!"
fi



#############################################
if [ ! -z "${POSTBOOT}" ]; then
  bash $POSTBOOT
fi
wait -n $ngx $sshd && exit $?
