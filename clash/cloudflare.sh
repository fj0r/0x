cd /opt/CloudflareST
./CloudflareST
ip=$(cat result.csv | awk -F',' 'NR==2{print $1}')
# CONFIG_CLOUDFLARE: /config/proxies/cloudflare.yaml|.proxies[0].server
IFS='|' read -ra CONFIG <<< "$CONFIG_CLOUDFLARE"
cat ${CONFIG[0]} | yq e "${CONFIG[1]} = ${ip}" - > ${CONFIG[0]}
