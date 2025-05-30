#!/bin/bash

cd /opt/ComfyUI-running-on-Podman-WSL2

# モデルをダウンロードするためのコンテナをビルド
podman build -t model-downloader:latest \
  --force-rm \
  --volume "/opt/ComfyUI-running-on-Podman-WSL2/data:/data" \
  ./services/download/

# モデルをダウンロードするためのコンテナを実行
# 初回にだけ実行
podman run -it --rm \
  --name model-downloader \
  --volume "/opt/ComfyUI-running-on-Podman-WSL2/data:/data" \
  localhost/model-downloader:latest

# ComfyUIのコンテナをビルド
podman build -t comfyui:v0.3.39 \
  --force-rm \
  --volume "/opt/ComfyUI-running-on-Podman-WSL2/data:/data" \
  --volume "/opt/ComfyUI-running-on-Podman-WSL2/output:/output" \
  --device "nvidia.com/gpu=all" \
  ./services/comfyui/
