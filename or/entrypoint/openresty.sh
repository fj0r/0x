if [ -n "${HTPASSWORD}" ]; then
    IFS=':' read -ra HTP <<< "$HTPASSWORD"
    printf "${HTP[0]}:$(openssl passwd -apr1 ${HTP[1]})\n" >> /etc/openresty/htpasswd
fi

if [ -n "${UPLOAD_ROOT}" ]; then
    UPLOADDIR=${WEB_ROOT:-/srv}/${UPLOAD_ROOT}
    mkdir -p $UPLOADDIR
    chown www-data:www-data $UPLOADDIR
fi

if [ -n "${QNGCONFIG}" ]; then
    if [ ! -e "${QNGCONFIG}" ]; then
        echo "{}" > ${QNGCONFIG}
    fi
    qjs --std /etc/openresty/qng.js > /etc/openresty/nginx.conf
fi

/usr/local/openresty/bin/openresty 2>&1 &
echo -n "$! " >> /var/run/services
