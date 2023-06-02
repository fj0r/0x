if [ ! -f /app/wireguard/Corefile ]; then
    cat <<- EOF > /app/wireguard/Corefile
. {

    import /app/wireguard/zones/*

    #forward . 1.1.1.1 8.8.8.8 {
    #    policy sequential
    #    prefer_udp
    #    expire 10s
    #}

    reload 15s
    cache 120
    log
}
EOF
fi

mkdir -p /app/wireguard/zones

if [ ! -f /app/wireguard/zones/example ]; then
    cat <<- EOF >  /app/wireguard/zones/example
template IN A self {
    answer "{{ .Name }} IN A 127.0.0.1"
    fallthrough
}

# 1-2-3-4.ip A 1.2.3.4
template IN A ip {
    match (^|[.])(?P<a>[0-9]*)-(?P<b>[0-9]*)-(?P<c>[0-9]*)-(?P<d>[0-9]*)[.]ip[.]$
    answer "{{ .Name }} 60 IN A {{ .Group.a }}.{{ .Group.b }}.{{ .Group.c }}.{{ .Group.d }}"
    fallthrough
}
EOF
fi

/usr/local/bin/coredns -conf /app/wireguard/Corefile 2>&1 &
