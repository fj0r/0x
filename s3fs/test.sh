if [ ! -z "${S3ENDPOINT}" ]; then
    _endpoint="-o endpoint=$S3ENDPOINT"
else
    _endpoint="-o use_path_request_style"
fi

export s3_umask=0222
export s3_use_cache=/tmp,allow_other,nonempty,use_sse
export s3_allow_other=
# export s3_url=https://s3.amazonaws

s3opt=""
for i in "${!s3_@}"; do
    _key=${i:3}
    _value=$(eval "echo \$$i")
    if [ -z "$_value" ]; then
        s3opt+="-o $_key "
    else
        s3opt+="-o $_key=$_value "
    fi
done

cmd="s3fs -f $s3opt -o bucket=$S3BUCKET -o passwd_file=/.passwd-s3fs -o url=$S3URL $_endpoint /data"
echo $cmd
