#!/bin/bash

cd /opt/ComfyUI-running-on-Podman-WSL2

ARGS="--force-fp16"
# --force-fp32 が引数に含まれている場合、ARGSに"--force-fp32"をセット
for arg in "$@"; do
  if [ "$arg" = "--force-fp32" ]; then
    ARGS="--force-fp32"
    break
  fi
done

# dont-print-server オプションを追加
ARGS="${ARGS} --dont-print-server"

# ComfyUIのコンテナを実行
# WSL2起動時に実行すればOK
podman run -d --rm \
  --name comfyui \
  -p 8888:8888 \
  --volume "/opt/ComfyUI-running-on-Podman-WSL2/data:/data" \
  --volume "/opt/ComfyUI-running-on-Podman-WSL2/output:/output" \
  --device "nvidia.com/gpu=all" \
  -e CLI_ARGS="${ARGS}" \
  localhost/comfyui:v0.3.39
