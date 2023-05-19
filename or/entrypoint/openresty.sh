echo "[$(date -Is)] starting openresty"

if [ -n "${HTPASSWD}" ]; then
    IFS=':' read -ra HTP <<< "$HTPASSWD"
    printf "${HTP[0]}:$(openssl passwd -apr1 ${HTP[1]})\n" >> /etc/openresty/htpasswd
fi

if [ -n "${UPLOAD_ROOT}" ]; then
    UPLOADDIR=/srv/${UPLOAD_ROOT}
    mkdir -p $UPLOADDIR
    chown www-data:www-data $UPLOADDIR
fi

/usr/local/openresty/bin/openresty 2>&1 &
echo -n "$! " >> /var/run/services
