#!/bin/bash

cd /opt/ComfyUI-running-on-podman-WSL2/

# モデルをダウンロードするためのコンテナをビルド
podman build -t model-downloader:latest \
  --force-rm \
  --volume "/opt/ComfyUI-running-on-podman-WSL2/data:/data" \
  --device "nvidia.com/gpu=all" \
  ./services/download/

# モデルをダウンロードするためのコンテナを実行
# 初回にだけ実行
podman run -it --rm \
  --name model-downloader \
  --volume "/opt/ComfyUI-running-on-podman-WSL2/data:/data" \
  --device "nvidia.com/gpu=all" \
  localhost/model-downloader:latest

# ComfyUIのコンテナをビルド
podman build -t comfyui:v0.3.31 \
  --force-rm \
  --volume "/opt/ComfyUI-running-on-podman-WSL2/data:/data" \
  --volume "/opt/ComfyUI-running-on-podman-WSL2/output:/output" \
  --device "nvidia.com/gpu=all" \
  ./services/comfyui/

# ComfyUIのコンテナを実行
# WSL2起動時に実行すればOK
podman run -d --rm \
  --name comfyui \
  -p 8888:8888 \
  --volume "/opt/ComfyUI-running-on-podman-WSL2/data:/data" \
  --volume "/opt/ComfyUI-running-on-podman-WSL2/output:/output" \
  --device "nvidia.com/gpu=all" \
  localhost/comfyui:v0.3.31

# k8sだと自分の環境だとうまくいかなのでメモだけ
#podman kube play --replace k8s.yaml
