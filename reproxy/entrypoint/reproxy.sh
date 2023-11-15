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

cmd="reproxy ${routefile} ${routes}"

eval "$cmd 2>&1 &"
echo -n "$! " >> /var/run/services
