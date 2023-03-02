#!/usr/bin/env bash

stop() {
    echo "Received SIGINT or SIGTERM. Shutting down"
    # Get PID
    pid=$(cat /var/run/services)
    # Set TERM
    kill -SIGTERM ${pid}
    # Wait for exit
    wait ${pid}
    # All done.
    echo -n '' > /var/run/services
    echo "Done."
}

trap stop SIGINT SIGTERM


BASEDIR=$(dirname "$0")

source $BASEDIR/env.sh
source $BASEDIR/ssh.sh
source $BASEDIR/socat.sh

################################################################################
echo "[$(date -Is)] starting wireguard"
################################################################################
addrs=""
mkdir -p /app/wireguard/
rsync -a /app/wireguard/wg0.conf /etc/wireguard/wg0.conf

for i in $(ls /etc/wireguard/ | grep '.*\.conf' | cut -d '.' -f 1); do
    wg-quick up $i
    addrs+="$(ip addr show $i | awk 'NR==3 {print $2}' | cut -d'/' -f 1) "
done

echo "==> wg addr: ${addrs}"

################################################################################
echo "[$(date -Is)] starting wg-gen-web"
################################################################################
cd /app
./wg-gen-web-linux 2>&1 &
echo -n "$! " >> /var/run/services

################################################################################
echo "[$(date -Is)] starting coredns"
################################################################################
if [ ! -f /app/wireguard/Corefile ]; then
    cat <<- EOF > /app/wireguard/Corefile
. {

    import /app/wireguard/zones/*

    #forward . 1.1.1.1 8.8.8.8 {
    #    policy sequential
    #    prefer_udp
    #    expire 10s
    #}

    reload 15s
    cache 120
    log
}
EOF
fi

mkdir -p /app/wireguard/zones

if [ ! -f /app/wireguard/zones/example ]; then
    cat <<- EOF >  /app/wireguard/zones/example
template IN A self {
    answer "{{ .Name }} IN A 127.0.0.1"
    fallthrough
}

# 1-2-3-4.ip A 1.2.3.4
template IN A ip {
    match (^|[.])(?P<a>[0-9]*)-(?P<b>[0-9]*)-(?P<c>[0-9]*)-(?P<d>[0-9]*)[.]ip[.]$
    answer "{{ .Name }} 60 IN A {{ .Group.a }}.{{ .Group.b }}.{{ .Group.c }}.{{ .Group.d }}"
    fallthrough
}
EOF
fi

/usr/local/bin/coredns -conf /app/wireguard/Corefile 2>&1 &
echo -n "$! " >> /var/run/services


################################################################################
wait -n $(cat /var/run/services) && exit $?
