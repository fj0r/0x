#!/bin/sh
r=${IMAGE_TAG_RETAINS:-20}
echo $(date -Is) retain $r >> /var/log/clean-registry.log
curl -sSL localhost:5000/admin/deletion?retain=$r | curl -sSL -X POST localhost:5000/admin/deletion --data-binary @-
