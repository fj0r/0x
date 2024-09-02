FROM ghcr.io/fj0r/io

RUN set -eux \
  ; apt-get update -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      fontconfig fonts-noto-cjk fonts-noto-cjk-extra \
      fonts-arphic-ukai fonts-arphic-uming \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*
