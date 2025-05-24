config=""
if [ -n "$CONFIGFILE" ]; then
    config="--config ${CONFIGFILE}"
fi

cmd="/opt/ferron/ferron ${config}"

eval "$cmd 2>&1 &"
echo -n "$! " >> /var/run/services
