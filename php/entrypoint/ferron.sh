config="--config ${CONFIGFILE:-/opt/ferron/ferron.kdl}"

cmd="/opt/ferron/ferron ${config}"

eval "$cmd 2>&1 &"
echo -n "$! " >> /var/run/services
