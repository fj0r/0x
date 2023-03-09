if [ -n "$S3SECRET_KEY" ]; then
    echo "[$(date -Is)] starting s3fs"

    s3opt=""
    s3user=${S3USER:-root}
    for i in "${!s3_@}"; do
        _key=${i:3}
        _value=$(eval "echo \$$i")
        if [ -z "$_value" ]; then
            s3opt+="-o $_key "
        else
            s3opt+="-o $_key=$_value "
        fi
    done

    echo "${S3ACCESS_KEY}:${S3SECRET_KEY}" > /.passwd-s3fs
    chmod go-rwx /.passwd-s3fs
    chown $s3user /.passwd-s3fs
    mkdir -p $S3MOUNTPOINT
    chown $s3user $S3MOUNTPOINT

    if [ -n "${S3REGION}" ]; then
        _region="-o endpoint=$S3REGION"
    else
        _region="-o use_path_request_style"
    fi
    cmd="sudo -u $s3user s3fs -f $s3opt -o bucket=$S3BUCKET -o passwd_file=/.passwd-s3fs -o url=$S3ENDPOINT $_region $S3MOUNTPOINT"
    echo $cmd
    eval $cmd &> /var/log/s3fs &
    echo -n "$! " >> /var/run/services
fi
