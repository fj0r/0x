for i in Country.mmdb geoip.dat geoip.db; do
    ln -fs /opt/${i} /data
done

watchexec -r --debounce 1000 \
    -w /data/config.yaml \
    -w /data/rules \
    -- mihomo -d /data -ext-ctl 0.0.0.0:9090 2>&1 &

echo -n "$! " >> /var/run/services
