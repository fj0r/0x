FROM rust as build

WORKDIR /app
RUN set -eux \
  ; apt update \
  ; apt-get install -y --no-install-recommends git cmake \
  ;

RUN set -eux \
  ; git clone --depth=1 https://github.com/delta-io/kafka-delta-ingest.git \
  ; cd kafka-delta-ingest \
  ; cargo build --release --features s3 \
  ;


FROM debian:stable-slim
RUN set -eux \
  ; apt update \
  ; apt-get install -y --no-install-recommends \
      libssl3 \
      tree \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/kafka-delta-ingest/target/release/kafka-delta-ingest /app/kafka-delta-ingest

