run_socat () {
    local logfile
    if [ -n "$stdlog" ]; then
        logfile=/dev/stdout
    else
        logfile=/var/log/socat_$1_$2
    fi

    cmd="socat $1-listen:$2,reuseaddr,fork $1:$3"
    eval "$cmd &> $logfile &"
    echo -n "$! " >> /var/run/services
    echo "$1:$2--> $3"
}

for i in "${!tcp_@}"; do
    port=${i:4}
    if [ -n "$port" ]; then
        url=$(eval "echo \"\$$i\"")
        run_socat tcp $port $url
    fi
done

for i in "${!udp_@}"; do
    port=${i:4}
    if [ -n "$port" ]; then
        url=$(eval "echo \"\$$i\"")
        run_socat udp $port $url
    fi
done
