for i in Country.mmdb geoip.dat geoip.db; do
    ln -fs /opt/${i} /data
done

if [ -n "$WATCH_ALL" ]; then
    watchexec -r -w /data/ -e yaml,yml -- mihomo -d /data -ext-ctl 0.0.0.0:9090 2>&1 &
else
    watchexec -r -w /data/config.yaml -- mihomo -d /data -ext-ctl 0.0.0.0:9090 2>&1 &
fi
echo -n "$! " >> /var/run/services
