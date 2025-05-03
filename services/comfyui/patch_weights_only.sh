#!/bin/bash
set -e

# パッチ対象ファイル
TARGET_FILE="/comfyui/comfy/utils.py"

# weights_only=True を weights_only=False に変更
sed -i 's/weights_only=True/weights_only=False/' "$TARGET_FILE"
