if [ -n "$WEB_ROOT" ]; then
    sed -i 's!\(set $root\).*$!\1 '"\'$WEB_ROOT\'"';!' /etc/nginx/nginx.conf
fi

/opt/nginx/sbin/nginx 2>&1 &
echo -n "$! " >> /var/run/services

