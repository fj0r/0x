if [ -n "${VECTORFILE}" ]; then
    /usr/local/bin/vector -c $VECTORFILE &> /var/log/vector &
    echo -n "$! " >> /var/run/services
fi
