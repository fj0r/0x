FROM fj0rd/io as build

RUN set -eux \
  ; apt-get update \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        automake autoconf \
        # libz libcrypto
        libssl-dev zlib1g-dev \
  ; mkdir /build /target

WORKDIR /build

RUN set -eux \
  ; mkdir dropbear \
  ; curl -sSL https://matt.ucc.asn.au/dropbear/dropbear-2020.81.tar.bz2 \
    | tar jxvf - -C dropbear --strip-components=1 \
  ; cd dropbear \
  ; ./configure \
  ; make PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp" \
  ; mkdir -p /target/bin \
  ; mv dropbear scp dropbearkey dropbearconvert /target/bin \
  ; mv dbclient /target/bin/ssh

RUN set -eux \
  ; git clone --depth=1 https://github.com/openssh/openssh-portable.git \
  ; cd openssh-portable \
  ; autoreconf \
  ; ./configure \
  ; make sftp-server \
  ; mkdir -p /target/libexec \
  ; mv sftp-server /target/libexec

FROM debian:bullseye-slim

COPY --from=build /target /target


