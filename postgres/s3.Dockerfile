FROM fj0rd/scratch:arrow as arrow
FROM postgres:16

COPY --from=arrow /usr/include /usr/include
COPY --from=arrow /usr/lib /usr/lib/x86_64-linux-gnu

ENV BUILD_DEPS \
    git \
    binutils \
    m4 \
    pkg-config \
    lsb-release \
    libcurl4-openssl-dev \
    libssl-dev \
    libicu-dev \
    uuid-dev \
    build-essential \
    ninja-build \
    cmake \
    libpq-dev \
    postgresql-server-dev-${PG_MAJOR} \
    tree

ENV LANG zh_CN.utf8
ENV TIMEZONE=Asia/Shanghai
RUN set -eux \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  ; sed -i /etc/locale.gen \
      -e 's/# \(en_US.UTF-8 UTF-8\)/\1/' \
      -e 's/# \(zh_CN.UTF-8 UTF-8\)/\1/' \
  ; locale-gen \
  ; apt-get update \
  ; apt-get install -y --no-install-recommends \
      curl jq ripgrep ca-certificates \
      ${BUILD_DEPS:-} \
  \
  ; build_dir=/root/build \
  ; mkdir -p $build_dir \
  ; cd $build_dir \
  \
  ; mkdir $build_dir/fdw \
  ; paq_version=$(curl https://api.github.com/repos/pgspider/parquet_s3_fdw/releases/latest | jq -r '.tag_name') \
  ; curl --retry 3 -sSL https://github.com/pgspider/parquet_s3_fdw/archive/refs/tags/${paq_version}.tar.gz | tar zxf - --strip-components=1 -C $build_dir/fdw \
  ; cd $build_dir/fdw \
  ; make install USE_PGXS=1 CCFLAGS=-std=c++17 \
  \
  ; rm -rf $build_dir \
  ; apt-get purge -y --auto-remove ${BUILD_DEPS:-} \
  ; apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  ;

COPY .psqlrc /root

