#!/bin/bash

set -Eeuo pipefail

mkdir -vp /data/config/custom_nodes

declare -A MOUNTS

MOUNTS["/root/.cache"]="/data/.cache"
MOUNTS["${WORKSPACE}/input"]="/data/config/input"
MOUNTS["${WORKSPACE}/output"]="/output"

for to_path in "${!MOUNTS[@]}"; do
  set -Eeuo pipefail
  from_path="${MOUNTS[${to_path}]}"
  rm -rf "${to_path}"
  if [ ! -f "$from_path" ]; then
    mkdir -vp "$from_path"
  fi
  mkdir -vp "$(dirname "${to_path}")"
  ln -sT "${from_path}" "${to_path}"
  echo Mounted $(basename "${from_path}")
done

if [ -f "/data/config/startup.sh" ]; then
  pushd ${WORKSPACE}
  . /data/config/startup.sh
  popd
fi

exec "$@"
