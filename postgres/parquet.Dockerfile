FROM postgres:15

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
    libpq-dev \
    libkrb5-dev \
    postgresql-server-dev-${PG_MAJOR} \
    tree ninja-build

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
  \
  ; cd $build_dir \
  \
  ; mkdir $build_dir/cmake \
  ; curl -sSL https://github.com/Kitware/CMake/releases/download/v3.26.1/cmake-3.26.1-linux-x86_64.tar.gz \
    | tar -zxf - -C $build_dir/cmake --strip-components=1 \
  ; ln -sf $build_dir/cmake/bin/cmake /usr/local/bin \
  \
  ; mkdir $build_dir/arrow \
  ; arrow_ver=$(curl -sSL https://arrow.apache.org/install/ | rg 'Current Version: ([.0-9]+)' -or '$1') \
  ; curl -sSL https://dlcdn.apache.org/arrow/arrow-${arrow_ver}/apache-arrow-${arrow_ver}.tar.gz \
    | tar zxf - -C $build_dir/arrow --strip-components=1 \
  ; cd $build_dir/arrow/cpp \
  ; mkdir build \
  ; cd build \
  ; cmake .. --preset ninja-release \
        -DARROW_BUILD_INTEGRATION=OFF \
        -DARROW_BUILD_STATIC=OFF \
        -DARROW_BUILD_TESTS=OFF \
        -DARROW_EXTRA_ERROR_CONTEXT=ON \
        -DARROW_WITH_RE2=OFF \
        -DARROW_JSON=ON \
        -DARROW_PARQUET=ON \
        -DARROW_S3=ON \
        -DARROW_WITH_UTF8PROC=ON \
        -DARROW_WITH_ZLIB=ON \
        -DARROW_WITH_ZSTD=ON \
  ; cmake --build . \
  ; mv release/* /usr/lib/x86_64-linux-gnu \
  ; mv $build_dir/arrow/cpp/build/awssdk_ep-install/lib/libaws-cpp-sdk-core.a /usr/lib/x86_64-linux-gnu \
  ; mv $build_dir/arrow/cpp/build/awssdk_ep-install/lib/libaws-cpp-sdk-s3.a /usr/lib/x86_64-linux-gnu \
  \
  ; mkdir -p /usr/local/include/aws \
  ; cp -r $build_dir/arrow/cpp/build/awssdk_ep-install/include/aws /usr/local/include/ \
  \
  ; mkdir -p /usr/local/include/arrow \
  ; cd $build_dir/arrow/cpp/src/arrow \
  ; tar -cf - $(find . -name '*.h') | tar -xf - -C /usr/local/include/arrow \
  ; cp $build_dir/arrow/cpp/build/src/arrow/util/config.h /usr/local/include/arrow/util/config.h \
  \
  ; mkdir -p /usr/local/include/parquet \
  ; cd $build_dir/arrow/cpp/src/parquet \
  ; tar -cf - $(find . -name '*.h') | tar -xf - -C /usr/local/include/parquet \
  ; cp $build_dir/arrow/cpp/build/src/parquet/parquet_version.h /usr/local/include/parquet/parquet_version.h \
  \
  ; mkdir $build_dir/parquet \
  ; paq_version=$(curl https://api.github.com/repos/pgspider/parquet_s3_fdw/releases/latest | jq -r '.tag_name') \
  ; curl -sSL https://github.com/pgspider/parquet_s3_fdw/archive/refs/tags/${paq_version}.tar.gz | tar zxf - --strip-components=1 -C $build_dir/parquet \
  ; cd $build_dir/parquet \
  #; sed -e 's!\(-std=c++\)11!\117!' -i Makefile \
  ; make install USE_PGXS=1 CCFLAGS=-std=c++17 \
  \
  ; rm -rf /usr/local/include/arrow /usr/local/include/parquet /usr/local/include/aws \
  ; rm -f /usr/lib/x86_64-linux-gnu/libaws-cpp-sdk-core.a /usr/lib/x86_64-linux-gnu/libaws-cpp-sdk-s3.a \
  ; rm -rf $build_dir \
  ; rm -f /usr/local/bin/cmake \
  ; apt-get purge -y --auto-remove ${BUILD_DEPS:-} \
  ; apt-get clean -y && rm -rf /var/lib/apt/lists/*


COPY .psqlrc /root

