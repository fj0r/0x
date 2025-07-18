#!/bin/sh
r=${IMAGE_TAG_RETAINS:-10}
echo $(date -Is) retain $r >> /var/log/clean-registry.log
if [ -n "${HTPASSWD}" ]; then
    curl -fsSL -u "$HTPASSWD" localhost:5000/admin/deletion?retain=$r \
    | curl -fsSL -u "$HTPASSWD" -X POST localhost:5000/admin/deletion --data-binary @-
else
    curl -fsSL localhost:5000/admin/deletion?retain=$r \
    | curl -fsSL -X POST localhost:5000/admin/deletion --data-binary @-
fi

/usr/local/bin/registry garbage-collect --delete-untagged /etc/docker/registry/config.yml
