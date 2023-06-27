if [ -n "${HTPASSWORD}" ]; then
    IFS=':' read -ra HTP <<< "$HTPASSWORD"
    printf "${HTP[0]}:$(openssl passwd -apr1 ${HTP[1]})\n" >> /etc/openresty/htpasswd
fi

if [ -n "${UPLOAD_ROOT}" ]; then
    UPLOADDIR=${WEB_ROOT:-/srv}/${UPLOAD_ROOT}
    mkdir -p $UPLOADDIR
    chown www-data:www-data $UPLOADDIR
fi


config=/etc/openresty

if [ -n "${ROUTEFILE}" ]; then
    jq -s '.[0].location = .[1] |.[0]' $config/default.json $ROUTEFILE \
    | tera -t $config/nginx.conf.tmpl -e -s -o $config/nginx.conf
else
    cat $config/default.json \
    | tera -t $config/nginx.conf.tmpl -e -s -o $config/nginx.conf
fi

for t in $(find $config/ext -name '*.tmpl'); do
    cat $config/default.json | tera -t $t -e -s -o ${t%.tmpl}
done

/opt/openresty/bin/openresty 2>&1 &
echo -n "$! " >> /var/run/services
