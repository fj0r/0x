echo "warpgate starting"

if [ ! -f '/data/warpgate.yaml' ]; then
    passwd=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 19)
    echo "${passwd}" > /data/passwd
    echo "setup warpgate with admin-password: ${passwd}"
    warpgate unattended-setup \
        --data-path /data \
        --database-url 'sqlite:/data/db' \
        --ssh-port 2222 \
        --http-port 8888 \
        --mysql-port 33306 \
        --record-sessions \
        --admin-password "${passwd}"

    mv /etc/warpgate.yaml /data/warpgate.yaml
fi

warpgate --config /data/warpgate.yaml run 2>&1 &

echo -n "$! " >> /var/run/services