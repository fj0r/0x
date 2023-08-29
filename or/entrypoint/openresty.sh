if [ -n "${HTPASSWORD}" ]; then
    IFS=':' read -ra HTP <<< "$HTPASSWORD"
    printf "${HTP[0]}:$(openssl passwd -apr1 ${HTP[1]})\n" >> /etc/openresty/htpasswd
fi

if [ -n "${UPLOAD_ROOT}" ]; then
    UPLOADDIR=${WEB_ROOT:-/srv}/${UPLOAD_ROOT}
    mkdir -p $UPLOADDIR
    chown www-data:www-data $UPLOADDIR
fi

merge_config () {
    local cfg=$(cat /etc/openresty/default.json)

    if [ -n "${ROUTEFILE}" ]; then
        cfg=$(echo $cfg | jq -s '.[0].location = .[1] | .[0]' - $ROUTEFILE)
    fi

    if [ -n "${SITEFILE}" ]; then
        cfg=$(echo $cfg | jq -s '.[0].site = .[1] | .[0]' - $SITEFILE)
    fi

    echo -n $cfg
}

config=$(merge_config)

dest=/etc/openresty
echo $config | tera -t $dest/nginx.conf.tmpl -e -i -s -o $dest/nginx.conf

for t in $(find $dest/ext -name '*.tmpl'); do
    echo $config | tera -t $t -e -i -s -o ${t%.tmpl}
done


/usr/local/openresty/bin/openresty 2>&1 &
echo -n "$! " >> /var/run/services
