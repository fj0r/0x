cd /opt/CloudflareST
./cfst
ip=$(cat result.csv | awk -F',' 'NR==2{print $1}')
# CONFIG_CLOUDFLARE: /data/proxies/cloudflare.yaml|.proxies[0].server
IFS='|' read -ra CONFIG <<< "$CONFIG_CLOUDFLARE"
cat ${CONFIG[0]} | yq e "${CONFIG[1]} = \"${ip}\"" - | tee ${CONFIG[0]}

echo "$(date -Is) ${ip}" >> /var/log/cloudflareST
touch /data/config.yaml
