routes=""
static_enabled=""
for i in "${!R_@}"; do
    static_enabled="y"
    n=${i:2}
    r=$(eval "echo \"\$$i\"")
    #routes="${routes}${n}: ${r};"
    routes="${routes} --static.rule=\"${r}\""
done

if [ -n "$static_enabled" ]; then
    routes="--static.enabled ${routes}"
fi

routefile=""
if [ -n "$ROUTEFILE" ]; then
    routefile="--file.enabled --file.name=${ROUTEFILE}"
fi

assets=""
if [ -n "$WEB_ROOT" ]; then
    assets="--assets.location=${WEB_ROOT}"
fi

args=""
if [ -n "$ARGS" ]; then
    args="${ARGS}"
fi

timeout=""
for t in read-header write idle dial keep-alive resp-header idle-conn tls continue; do
    timeout="${timeout} --timeout.${t}=${TIMEOUT:-0}"
done

others="--max=0"

cmd="reproxy --listen 0.0.0.0:${LISTEN_PORT:-80} ${assets} ${routefile} ${routes} ${timeout} ${args} ${others}"

eval "$cmd 2>&1 &"
echo -n "$! " >> /var/run/services
