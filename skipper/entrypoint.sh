#!/bin/bash
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

if [ -e /usr/local/bin/nu ]; then
    __shell=/usr/local/bin/nu
elif [ -e /bin/zsh ]; then
    __shell=/bin/zsh
elif [ -e /bin/bash ]; then
    __shell=/bin/bash
else
    __shell=/bin/sh
fi


set_user () {
    IFS=':' read -ra UA <<< "$1"
    _NAME=${UA[0]}
    _UID=${UA[1]:-1000}
    _GID=${UA[2]:-1000}

    getent group ${_NAME} >/dev/null 2>&1 || groupadd -g ${_GID} ${_NAME}
    getent passwd ${_NAME} >/dev/null 2>&1 || useradd -m -u ${_UID} -g ${_GID} -G sudo -s ${__shell} -c "$2" ${_NAME}
}

init_ssh () {
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

__ssh=$(for i in "${!ed25519_@}"; do echo $i; done)
if [ ! -z "$__ssh" ] || [ -f /root/.ssh/authorized_keys ]; then
    init_ssh
    mkdir -p /etc/dropbear
    /usr/bin/dropbear -REFems -p 22 -K 300 -I 600 2>&1 &
    echo -n "$! " >> /var/run/services
fi


routes=""
for i in "${!R_@}"; do
    n=${i:2}
    r=$(eval "echo \"\$$i\"")
    routes="${routes}${n}: ${r};"
done

if [ ! -z "$routes" ]; then
    routes="-inline-routes '${routes}'"
fi

routefile=""
if [ ! -z "$ROUTEFILE" ]; then
    routefile="-routes-file ${ROUTEFILE}"
fi

cmd="/usr/local/bin/skipper -address :80 -wait-for-healthcheck-interval 0 ${routefile} ${routes}"

eval "$cmd &"
echo -n "$! " >> /var/run/services

if [ ! -z "${POSTBOOT}" ]; then
  bash $POSTBOOT
fi
wait -n $(cat /var/run/services) && exit $?
