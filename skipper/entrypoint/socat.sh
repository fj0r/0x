echo "[$(date -Is)] starting socat"

for i in "${!tcp_@}"; do
    port=${i:4}
    if [ ! -z "$port" ]; then
        url=$(eval "echo \"\$$i\"")
        cmd="socat tcp-listen:$port,reuseaddr,fork tcp:$url"
        eval "$cmd &"
        echo -n "$! " >> /var/run/services
        echo "tcp:$port --> $url"
    fi
done

for i in "${!udp_@}"; do
    port=${i:4}
    if [ ! -z "$port" ]; then
        url=$(eval "echo \"\$$i\"")
        cmd="socat udp-listen:$port,reuseaddr,fork udp:$url"
        eval "$cmd &"
        echo -n "$! " >> /var/run/services
        echo "udp:$port --> $url"
    fi
done
