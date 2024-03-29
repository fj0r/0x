gen-host-key() {
    if [ ! -f "$1" ]; then
        #ssh-keygen -t ed25519 -f /nebula/ssh_host_ed25519_key -N "" < /dev/null
        dropbearkey -t ed25519 -f $1-bin
        dropbearkey -y -f $1-bin | awk 'NR==2{print}' > $1.pub
        dropbearconvert dropbear openssh $1-bin $1
        rm -f $1-bin
    fi
}

cd /nebula
config=${NEBULA_CONFIG:-/nebula/config.yaml}

gen-host-key /nebula/ssh_host_ed25519_key
/usr/local/bin/nebula -config $config 2>&1 &
echo -n "$! " >> /var/run/services
