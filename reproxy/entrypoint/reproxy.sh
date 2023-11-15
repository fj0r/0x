routes=""
for i in "${!R_@}"; do
    n=${i:2}
    r=$(eval "echo \"\$$i\"")
    routes="${routes}${n}: ${r};"
done

if [ -n "$routes" ]; then
    routes="-inline-routes '${routes}'"
fi

routefile=""
if [ -n "$ROUTEFILE" ]; then
    routefile="--file.enabled --file.name=${ROUTEFILE}"
fi

assets=""
if [ -n "$WEB_ROOT" ]; then
    assets="--assets.location=${WEB_ROOT}"
fi

timeout=""
for t in read-header write idle dial keep-alive resp-header idle-conn tls continue; do
    timeout="${timeout} --timeout.${t}=${TIMEOUT:-0}"
done

cmd="reproxy --listen 0.0.0.0:80 ${assets} ${routefile} ${routes} ${timeout}"

eval "$cmd 2>&1 &"
echo -n "$! " >> /var/run/services
