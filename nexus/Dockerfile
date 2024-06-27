ARG NEXUS_VERSION=latest

FROM maven:3-jdk-8-alpine AS build

RUN set -eux \
  ; apk add git \
  ;

RUN set -eux \
  ; git clone --depth=1 https://github.com/sonatype-nexus-community/nexus-repository-composer.git \
  ; cd nexus-repository-composer/ \
  ; mvn clean package -PbuildKar \
  ;

RUN set -eux \
  ; git clone --depth=1 https://github.com/sonatype-nexus-community/nexus-repository-cargo.git \
  ; cd nexus-repository-cargo/ \
  ; mvn clean package -PbuildKar \
  ;

RUN set -eux \
  ; git clone --depth=1 https://github.com/sonatype-nexus-community/nexus-repository-cabal.git \
  ; cd nexus-repository-cabal/ \
  ; mvn clean package -PbuildKar \
  ;


FROM sonatype/nexus3:$NEXUS_VERSION

ARG DEPLOY_DIR=/opt/sonatype/nexus/deploy/
USER root
COPY --from=build /nexus-repository-composer/nexus-repository-composer/target/nexus-repository-composer-*-bundle.kar ${DEPLOY_DIR}
COPY --from=build /nexus-repository-cargo/target/nexus-repository-cargo-*-bundle.kar ${DEPLOY_DIR}
COPY --from=build /nexus-repository-cabal/nexus-repository-cabal/target/nexus-repository-cabal-*-bundle.kar ${DEPLOY_DIR}
USER nexus
