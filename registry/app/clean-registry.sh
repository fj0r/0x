#!/bin/sh
r=${IMAGE_TAG_RETAINS:-10}
echo $(date -Is) retain $r >> /var/log/clean-registry.log
if [ -n "${HTPASSWD}" ]; then
    curl -sSL -u "$HTPASSWD" localhost:5000/admin/deletion?retain=$r \
    | curl -sSL -u "$HTPASSWD" -X POST localhost:5000/admin/deletion --data-binary @-
else
    curl -sSL localhost:5000/admin/deletion?retain=$r \
    | curl -sSL -X POST localhost:5000/admin/deletion --data-binary @-
fi

/usr/local/bin/registry garbage-collect --delete-untagged /etc/docker/registry/config.yml
