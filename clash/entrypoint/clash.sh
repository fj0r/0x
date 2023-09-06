# CLASH_FLAVOR: premium | meta
if [ -n "$CLASH_FLAVOR" ]; then
    ln -fs /opt/Country.mmdb /data
    watchexec -r -w /data/config.yaml -e yaml,yml -- clash.$CLASH_FLAVOR -d /data -ext-ctl 0.0.0.0:9090 2>&1 &
    echo -n "$! " >> /var/run/services
fi
