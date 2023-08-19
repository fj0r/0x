FROM fj0rd/io

RUN set -eux \
  ; apt-get update -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        fonts-arphic-ukai fonts-arphic-uming \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*
