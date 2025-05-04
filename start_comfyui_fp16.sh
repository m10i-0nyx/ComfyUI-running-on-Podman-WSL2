#!/bin/bash

cd /opt/ComfyUI-running-on-Podman-WSL2

# ComfyUIのコンテナを実行
# WSL2起動時に実行すればOK
podman run -d --rm \
  --name comfyui \
  -p 8888:8888 \
  --volume "/opt/ComfyUI-running-on-Podman-WSL2/data:/data" \
  --volume "/opt/ComfyUI-running-on-Podman-WSL2/output:/output" \
  --device "nvidia.com/gpu=all" \
  -e CLI_ARGS="--force-fp16 --dont-print-server" \
  localhost/comfyui:v0.3.31
