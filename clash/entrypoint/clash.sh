# CLASH_FLAVOR: premium | meta
if [ -n "$CLASH_FLAVOR" ]; then
    ln -fs /opt/Country.mmdb /config
    watchexec -r -w /config -- clash.$CLASH_FLAVOR -d /config -ext-ctl 0.0.0.0:9090 2>&1 &
    echo -n "$! " >> /var/run/services
fi
