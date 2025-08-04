#!/bin/bash

cd /opt/ComfyUI-running-on-Podman-WSL2
if [ -f .env ]; then
  set -a
  source .env
  set +a
fi

# モデルをダウンロードするためのコンテナをビルド
podman build -t model-downloader:latest \
  --force-rm \
  --volume "$(pwd)/data:/data" \
  ./services/download/

# モデルをダウンロードするためのコンテナを実行
# 初回にだけ実行
podman run -it --rm \
  --name model-downloader \
  --volume "$(pwd)/data:/data" \
  localhost/model-downloader:latest

# ComfyUIのコンテナをビルド
podman build -t comfyui:${COMFYUI_TAG} \
  --force-rm \
  --build-arg COMFYUI_TAG=${COMFYUI_TAG} \
  --volume "$(pwd)/data:/data" \
  --volume "$(pwd)/output:/output" \
  --device "nvidia.com/gpu=all" \
  ./services/comfyui/

# ComfyUI-Manager をクローン
if [ ! -d "./output/config/custom_nodes/ComfyUI-Manager" ]; then
  git clone https://github.com/ltdrdata/ComfyUI-Manager.git ./output/config/custom_nodes/ComfyUI-Manager
  cd ./output/config/custom_nodes/ComfyUI-Manager
  git fetch --tags
  git checkout tags/3.35
fi
