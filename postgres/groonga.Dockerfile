FROM fj0rd/0x:pg

RUN set -eux \
  ; build_dir=/root/build \
  ; mkdir ${build_dir} \
  ; cd ${build_dir} \
  ; curl -sSLO https://packages.groonga.org/debian/groonga-apt-source-latest-bullseye.deb \
  ; apt install -y -V ./groonga-apt-source-latest-bullseye.deb \
  ; apt-get update \
  ; apt-get install -y --no-install-recommends \
      postgresql-${PG_MAJOR}-pgdg-pgroonga \
      # groonga-tokenizer-mecab \
  ; rm -rf ${build_dir}
