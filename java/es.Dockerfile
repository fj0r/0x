# https://github.com/hankcs/HanLP
# https://github.com/medcl/elasticsearch-analysis-pinyin
# https://github.com/KennFalcon/elasticsearch-analysis-hanlp
# https://github.com/medcl/elasticsearch-analysis-ik

FROM elasticsearch:7.13.2
ARG plugin_version=7.13.2
RUN set eux \
  ; elasticsearch-plugin install --batch \
    https://github.com/medcl/elasticsearch-analysis-pinyin/releases/download/v${plugin_version}/elasticsearch-analysis-pinyin-${plugin_version}.zip \
  ; elasticsearch-plugin install --batch \
    https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v${plugin_version}/elasticsearch-analysis-ik-${plugin_version}.zip \
  ; chown 1000 -R plugins
