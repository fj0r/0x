echo "warpgate starting"
warpgate --config /data/warpgate.yaml run 2>&1 &

echo -n "$! " >> /var/run/services