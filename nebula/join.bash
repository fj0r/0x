mkdir -p /app/keys
cd /app/keys


nebula-cert sign -name $1 -ip $2/${VCIDR:-16} -groups "${VGROUPS:-default}"

cat /app/config.yaml.tmpl | yq e '
.listen.port = 0
| .lighthouse.am_lighthouse = false
| .lighthouse.hosts += ["'${VHOST}'"]
| .static_host_map["'${VHOST}'"] += ["'${HOST_IP}:${HOST_PORT:-51821}'"]
| .pki.ca = "'"$(cat /app/ca.crt)"'"
| .pki.cert = "'"$(cat /app/$1.crt)"'"
| .pki.key = "'"$(cat /app/$1.key)"'"
' - > $1.yaml

rm -f $1.{key,crt}
