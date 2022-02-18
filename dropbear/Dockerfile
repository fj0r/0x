FROM io as build

RUN set -eux \
  ; apt-get update \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    # libz libcrypto
    #autoconf libssl-dev zlib1g-dev \
    apt install --no-install-recommends \
        autoconf libssl1.1 zlib1g-dev
  ; mkdir /build \
  ; mkdir /target

WORKDIR /build

RUN set -eux \
  ; mkdir dropbear \
  ; curl -sSL https://matt.ucc.asn.au/dropbear/dropbear-2020.81.tar.bz2 \
    | tar jxvf - -C dropbear --strip-components=1 \
  ; cd dropbear \
  ; ./configure \
  ; make PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp" \
  ; mv dropbear dbclient dropbearkey dropbearconvert scp /target

RUN set -eux \
  ; git clone --depth=1 https://github.com/openssh/openssh-portable.git \
  ; cd openssh-portable \
  ; autoreconf \
  ; ./configure \
  ; make sftp-server \
  ; mv sftp-server /target

