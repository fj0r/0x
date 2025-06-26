if [ -n "${HTPASSWORD}" ]; then
    IFS=':' read -ra HTP <<< "$HTPASSWORD"
    printf "${HTP[0]}:$(openssl passwd -apr1 ${HTP[1]})\n" | sudo tee -a /etc/openresty/htpasswd > /dev/null
fi

if [ -n "${UPLOAD_ROOT}" ]; then
    UPLOADDIR=${WEB_ROOT:-/srv}/${UPLOAD_ROOT}
    sudo mkdir -p $UPLOADDIR
    sudo chown www-data:www-data $UPLOADDIR
fi


if [ -n "${QNGCONFIG}" ]; then
    if [ ! -e "${QNGCONFIG}" ]; then
        echo "{}" | sudo tee ${QNGCONFIG} > /dev/null
    fi
    qjs --std /etc/openresty/qng.js | sudo tee /etc/openresty/nginx.conf > /dev/null
    cat /etc/openresty/nginx.conf
fi

sudo /opt/openresty/bin/openresty 2>&1 &
echo -n "$! " | sudo tee -a /var/run/services > /dev/null
