#!/usr/bin/env bash

if [ -n "${MODEL_PATH}" ]; then
    pushd ${MODEL_PATH}
    for i in $(fd --full-path . -t d); do
        pushd $i;
        ollama create $(cat source.txt)
        popd;
    done
    popd;
fi

/bin/ollama ${1:-serve}
