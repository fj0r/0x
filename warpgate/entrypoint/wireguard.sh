addrs=""
for i in $(ls /etc/wireguard/ | grep '.*\.conf' | cut -d '.' -f 1); do
    wg-quick up $i
    addrs+="$(ip addr show $i | awk 'NR==3 {print $2}' | cut -d'/' -f 1) "
done
echo "==> wg addr: ${addrs}"

echo "warpgate starting"
warpgate --config /data/warpgate.yaml run