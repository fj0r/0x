FROM python3

RUN set -eux \
  ; pip install --break-system-packages risingwave requests
