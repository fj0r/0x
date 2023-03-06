#!/usr/bin/env bash

set -e

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


gen-host-key() {
    if [ ! -f "$1" ]; then
        #ssh-keygen -t ed25519 -f /nebula/ssh_host_ed25519_key -N "" < /dev/null
        dropbearkey -t ed25519 -f $1-bin
        dropbearkey -y -f $1-bin | awk 'NR==2{print}' > $1.pub
        dropbearconvert dropbear openssh $1-bin $1
        rm -f $1-bin
    fi

}

trap stop SIGINT SIGTERM


BASEDIR=$(dirname "$0")
source $BASEDIR/env.sh


################################################################################
echo "[$(date -Is)] starting nebula"
################################################################################
cd /nebula
config=${NEBULA_CONFIG:-/nebula/config.yaml}
vcidr=${VCIDR:-16}
vgroup=${VGROUPS:-default}
port=${HOST_PORT:-51821}

echo config=$config groups="$vgroup"
echo network=${NETWORK} cidr=$VHOST/$vcidr endpoint=$HOST:$port

if [ -n "$NETWORK" ]; then
    if [ ! -f /nebula/ca.crt ]; then
        nebula-cert ca -name "${NETWORK}" -duration 876000h0m0s
    fi

    if [ ! -f /nebula/lighthouse.crt ]; then
        echo nebula-cert sign -name lighthouse -ip "${VHOST}/${vcidr}" -groups "${vgroup}"
        nebula-cert sign -name lighthouse -ip "${VHOST}/${vcidr}" -groups "${vgroup}"
    fi

    gen-host-key /nebula/ssh_host_ed25519_key

    if [ ! -f $config ]; then
        cat /nebula/config.yaml.tmpl | yq e "
            .listen.port = ${port}
            | .lighthouse.am_lighthouse = true
            | .lighthouse.hosts = []
            | .static_host_map = {}
            | .pki.ca = \"./ca.crt\"
            | .pki.cert = \"./lighthouse.crt\"
            | .pki.key = \"./lighthouse.key\"
            | .ciphers = \"chachapoly\"
            | .relay.am_relay = true
            | .relay.use_relays = false
            | .tun.dev = null
            | .tun.disabled = false
            | .firewall.inbound = [{\"port\": \"any\", \"proto\": \"any\", \"host\": \"any\"}]
            | .sshd = {\"enabled\": true, \"listen\": \"127.0.0.1:2222\", \"host_key\": \"/nebula/ssh_host_ed25519_key\", \"authorized_users\": [{\"user\": \"root\", \"keys\": [\"ssh-ed25519 ${VSSHKEY}\"]}]}
        " - > $config
    fi

    /usr/local/bin/nebula -config $config 2>&1 &
    echo -n "$! " >> /var/run/services

    source $BASEDIR/socat.sh
else
    /usr/local/bin/nebula -config $config 2>&1 &
    echo -n "$! " >> /var/run/services
fi




################################################################################
wait -n $(cat /var/run/services) && exit $?
