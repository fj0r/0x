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

forward-ports() {
    ################################################################################
    echo "[$(date -Is)] starting socat"
    ################################################################################
    addr=$VHOST
    #addr=$(ip addr show nebula1 | awk 'NR==3 {print $2}' | cut -d'/' -f 1)
    
    for i in "${!_@}"; do
        port=${i:1}
        if [ ! -z "$port" ]; then
            url=$(eval "echo \"\$$i\"")
            cmd="socat tcp-listen:$port,reuseaddr,fork tcp:$url"
            eval "$cmd &"
            echo -n "$! " >> /var/run/services
            echo "tcp:$addr:$port --> $url"
        fi
    done
    for i in "${!udp@}"; do
        port=${i:3}
        if [ ! -z "$port" ]; then
            url=$(eval "echo \"\$$i\"")
            cmd="socat udp-listen:$port,reuseaddr,fork udp:$url"
            eval "$cmd &"
            echo -n "$! " >> /var/run/services
            echo "udp:$addr:$port --> $url"
        fi
    done
}

env | grep -E '_|HOME|ROOT|PATH|DIR|VERSION|LANG|TIME|MODULE|BUFFERED' \
    | grep -Ev '^(_|HOME|USER|LS_COLORS)=' \
   >> /etc/environment

trap stop SIGINT SIGTERM


################################################################################
echo "[$(date -Is)] starting nebula"
################################################################################
cd /nebula
config=${NEBULA_CONFIG:-/nebula/config.yaml}
vcidr=${VCIDR:-16}
vgroup=${VGROUPS:-default}
port=${HOST_PORT:-51821}

echo config=$config groups="$vgroup"
echo network=${NETWORK} cidr=$VHOST/$vcidr endpoint=$HOST_IP:$HOST_PORT

if [ ! -z "$NETWORK" ]; then
    if [ ! -f /nebula/ca.crt ]; then
        nebula-cert ca -name "${NETWORK}" -duration 876000h0m0s
    fi
    
    if [ ! -f /nebula/lighthouse.crt ]; then
        echo nebula-cert sign -name lighthouse -ip "${VHOST}/${vcidr}" -groups "${vgroup}"
        nebula-cert sign -name lighthouse -ip "${VHOST}/${vcidr}" -groups "${vgroup}"
    fi
    
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
            | .relay.use_relays= false
            | .firewall.inbound = [{\"port\": \"any\", \"proto\": \"any\", \"host\": \"any\"}]
        " - > $config
    fi

    /usr/local/bin/nebula -config $config 2>&1 &
    echo -n "$! " >> /var/run/services
   
    forward-ports
else
    /usr/local/bin/nebula -config $config 2>&1 &
    echo -n "$! " >> /var/run/services
fi




################################################################################
wait -n $(cat /var/run/services) && exit $?
