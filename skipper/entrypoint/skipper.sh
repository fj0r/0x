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
    routefile="-routes-file ${ROUTEFILE}"
fi

cmd="/usr/local/bin/skipper -address :80 -wait-for-healthcheck-interval 0 ${routefile} ${routes}"

eval "$cmd &"
echo -n "$! " >> /var/run/services
