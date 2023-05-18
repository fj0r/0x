set_vector () {
    /usr/local/bin/vector -c $2 &> /var/log/vector-$1 &
    echo -n "$! " >> /var/run/services
}

__vector=$(for i in "${!vector_@}"; do echo $i; done)
if [ -n "$__vector" ]; then
    for i in "${!vector_@}"; do
        _ID=${i:7}
        echo "[$(date -Is)] starting vector $_ID"
        _config=$(eval "echo \$$i")
        set_vector ${_ID} ${_config}
    done
fi
