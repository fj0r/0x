FROM fj0rd/io

RUN set -eux \
  ; pip3 --no-cache-dir install \
    ansible \
  ; ansible-galaxy collection install amazon.aws \
  ; ansible-galaxy collection install kubernetes.core \
  \
  ; k8s_ver=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt | cut -c 2-) \
  ; curl -L https://dl.k8s.io/v${k8s_ver}/kubernetes-client-linux-amd64.tar.gz \
      | tar zxf - --strip-components=3 -C /usr/local/bin kubernetes/client/bin/kubectl \
  ; chmod +x /usr/local/bin/kubectl

