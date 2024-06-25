ARG BASEIMAGE=fj0rd/io:common
FROM ${BASEIMAGE}

ARG PIP_FLAGS="--break-system-packages"
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai
ENV PYTHONUNBUFFERED=x

RUN set -eux \
  ; apt-get update -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      python3 python3-pip \
      git openssh-client \
      buildah skopeo podman \
  ; ln -sf /usr/bin/python3 /usr/bin/python \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  \
  ; apt-get install -y --no-install-recommends build-essential \
  \
  ; pip3 install --no-cache-dir ${PIP_FLAGS} \
      pydantic structlog pyyaml PyParsing \
      httpx markdown jinja2 \
      ansible kubernetes \
      psycopg[binary] kafka-python \
      pymongo github3.py \
  ; apt-get remove -y build-essential \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  \
  ; for i in \
        ansible.posix \
        community.docker \
        community.mongodb \
        community.mysql \
        community.postgresql \
        community.general \
        community.windows \
        kubernetes.core \
  ; do \
        ansible-galaxy collection install $i ; \
    done \
  \
  ; k8s_ver=$(curl --retry 3 -s https://storage.googleapis.com/kubernetes-release/release/stable.txt | cut -c 2-) \
  ; curl --retry 3 -L https://dl.k8s.io/v${k8s_ver}/kubernetes-node-linux-amd64.tar.gz \
      | tar zxf - --strip-components=3 -C /usr/local/bin kubernetes/node/bin/kubectl kubernetes/node/bin/kubeadm \
  ; chmod +x /usr/local/bin/kubectl \
  ; chmod +x /usr/local/bin/kubeadm \
  \
  ; helm_ver=$(curl --retry 3 -sSL https://api.github.com/repos/helm/helm/releases/latest | jq -r '.tag_name' | cut -c 2-) \
  ; curl --retry 3 -L https://get.helm.sh/helm-v${helm_ver}-linux-amd64.tar.gz \
      | tar zxvf - -C /usr/local/bin linux-amd64/helm --strip-components=1 \
  \
  ; istio_ver=$(curl --retry 3 -sSL https://api.github.com/repos/istio/istio/releases/latest | jq -r '.tag_name') \
  ; curl --retry 3 -L https://github.com/istio/istio/releases/latest/download/istioctl-${istio_ver}-linux-amd64.tar.gz \
      | tar zxvf - -C /usr/local/bin istioctl \
  ;
