cp config.yaml config.out.yaml
yq -i e "(.ip_prefixes += \"${IP_PREFIX:-10.10.0.0/16}\")
        |(.dns_config.nameservers += \"${NAMESERVER:-8.8.8.8}\")
        |(.dns_config.domains += \"${DOMAIN}\")
        |(.server_url = \"${SERVER_URL:-http://127.0.0.1:8080}\")" \
config.out.yaml
