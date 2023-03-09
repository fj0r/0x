for i in "${!tcp_@}"; do
    port=${i:4}
    if [ -n "$port" ]; then
        url=$(eval "echo \"\$$i\"")
        cmd="socat tcp-listen:$port,reuseaddr,fork tcp:$url"
        eval "$cmd &> /var/log/socat &"
        echo -n "$! " >> /var/run/services
        echo "[$(date -Is)] tcp:$port --> $url"
    fi
done

for i in "${!udp_@}"; do
    port=${i:4}
    if [ -n "$port" ]; then
        url=$(eval "echo \"\$$i\"")
        cmd="socat udp-listen:$port,reuseaddr,fork udp:$url"
        eval "$cmd &> /var/log/socat &"
        echo -n "$! " >> /var/run/services
        echo "[$(date -Is)] udp:$port --> $url"
    fi
done
