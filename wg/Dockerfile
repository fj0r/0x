FROM rust AS builder

WORKDIR /src
RUN git clone --depth=1 https://github.com/cloudflare/boringtun.git \
 && cd boringtun \
 && cargo build --release \
 && strip ./target/release/boringtun

FROM debian:bullseye-slim

WORKDIR /app
COPY --from=builder /src/boringtun/target/release/boringtun /usr/local/bin

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TIMEZONE=Asia/Shanghai

ENV WG_LOG_LEVEL=info \
    WG_THREADS=4 \
    WG_SUDO=1 \
    WG_QUICK_USERSPACE_IMPLEMENTATION=/usr/local/bin

RUN apt-get update \
 && echo "resolvconf resolvconf/linkify-resolvconf boolean false" \
      | debconf-set-selections \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      tzdata wireguard-tools inetutils-ping \
      iproute2 iptables \
      resolvconf tcpdump \
      procps socat curl \
 && ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
 && echo "$TIMEZONE" > /etc/timezone \
 && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
