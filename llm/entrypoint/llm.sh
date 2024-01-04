python -m fastchat.serve.controller 2>&1 &
echo -n "$! " >> /var/run/services

ext_args=${EXT_ARGS:---dtype half}
python -m fastchat.serve.vllm_worker --model-path $MODEL_PATH --trust-remote-code $ext_args 2>&1 &
echo -n "$! " >> /var/run/services

python -m fastchat.serve.openai_api_server --host localhost --port 8888 2>&1 &
echo -n "$! " >> /var/run/services

