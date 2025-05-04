#!/usr/bin/env bash

set -Eeuo pipefail

# TODO: maybe just use the .gitignore file to create all of these
mkdir -vp /data/.cache \
  /data/embeddings \
  /data/config/custom_nodes \
  /data/models/ \
  /data/models/checkpoints \
  /data/models/vae \
  /data/models/loras \
  /data/models/upscale \
  /data/models/hypernetworks \
  /data/models/controlnet \
  /data/models/gligen \
  /data/models/clip

echo "Downloading, this might take a while..."

aria2c -x 10 --disable-ipv6 --input-file /docker/links.txt --dir /data/models --continue

echo "Checking SHAs..."

parallel --will-cite -a /docker/checksums.sha256 "echo -n {} | sha256sum -c"

cat <<EOF
By using this software, you agree to the following licenses:
https://github.com/comfyanonymous/ComfyUI/blob/master/LICENSE
And licenses of all UIs, third party libraries, and extensions.
EOF
