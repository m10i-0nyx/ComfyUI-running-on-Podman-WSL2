# ComfyUI running on Fedora42 + Podman + WSL2 on Windows10/11

## Setup on Windows
1. Winキー + R で「ファイル名を指定して実行」
2. 「cmd」を入力してOK
3. (よく使うので)Windows Terminalをインストール
```powershell
winget install --id Microsoft.WindowsTerminal --source winget
```

4. WSLをインストール  
インストーラーが立ち上がるので「はい」  
```powershell
winget install --id Microsoft.WSL --source winget
```

5. ここで一旦Windows端末のOSを再起動する  

6. WSLをアップデート
インストーラーが立ち上がるので「はい」  
```powershell
wsl --update
```

7. WSLにFedora42を入れる  
```powershell
wsl --install FedoraLinux-42
```

8. 初回Fedora起動時はUNIX username(要はユーザ名)を入れる必要がある  
忘れない好きな英字名を入れよう
> Please create a default user account. The username does not need to match your Windows username.  
>For more information visit: https://aka.ms/wslusers  
>Enter new UNIX username: 

9. 次回Windows起動時はWindows TermainalなどでFedoraを立ち上げる
```powershell
wsl -d FedoraLinux-42
```

## Setup on Fedora42

```bash
# Fedoraのソフトウェアを更新
sudo dnf -y upgrade

# NVIDIAのコンテナツールキットをインストールする準備
curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | \
  sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo

# NVIDIAコンテナツールキットをインストールしていく
sudo dnf install -y nvidia-container-toolkit

# WSL上でGPUを認識しているかテスト
nvidia-smi
```

GPU認識していれば下記のような結果が出力される(あくまで一例)
```
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 575.51.03              Driver Version: 576.28         CUDA Version: 12.9     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce GTX 1060 6GB    On  |   00000000:01:00.0  On |                  N/A |
|  0%   37C    P8              7W /  120W |    3112MiB /   6144MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
```

引き続きPodmanコンテナの準備を進める
```bash
# 認識していたらPodmanコンテナの準備
sudo dnf install -y git podman
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
sudo nvidia-ctk config --set nvidia-container-cli.no-cgroups --in-place
sudo sed -i 's/^#no-cgroups = false/no-cgroups = true/;' /etc/nvidia-container-runtime/config.toml

sudo mkdir -p /usr/share/containers/oci/hooks.d/
cat << '_EOL_' | sudo tee /usr/share/containers/oci/hooks.d/oci-nvidia-hook.json > /dev/null
{
    "version": "1.0.0",
    "hook": {
        "path": "/usr/bin/nvidia-container-runtime-hook",
        "args": ["nvidia-container-runtime-hook", "prestart"],
        "env": [
            "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        ]
    },
    "when": {
        "always": true,
        "commands": [".*"]
    },
    "stages": ["prestart"]
}
_EOL_

# podmanコンテナ上でGPUを認識できるかテスト
podman run -it --rm \
  docker.io/nvidia/cuda:11.8.0-base-rockylinux8 \
  nvidia-smi
```

PodmanコンテナでもGPU認識していれば下記のような結果が出力される(あくまで一例)
```
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 575.51.03              Driver Version: 576.28         CUDA Version: 12.9     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce GTX 1060 6GB    On  |   00000000:01:00.0  On |                  N/A |
|  0%   36C    P8              7W /  120W |    2914MiB /   6144MiB |      1%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
```

引き続きComfyUI用コンテナを準備する
```bash
# /opt配下にリポジトリをクローン(取得)
cd /opt
sudo chown root:wheel . && sudo chmod 775 .
git clone https://github.com/m10i-0nyx/ComfyUI-running-on-container.git

cd ComfyUI-running-on-container
chmod +x build.sh start_comfyui.sh

# **初回だけ実行**
# モデルをダウンロードするためのコンテナをビルド
# ComfyUIのコンテナをビルド
# モデルをダウンロードするためのコンテナを実行
./build.sh
```

## Launch ComfyUI
ここまでたどり着いたらあとはComfyUIを起動するのみ
```bash
# ComfyUIのコンテナを実行(defaultで --force-fp16 指定)
./start_comfyui.sh

# もしくは　--force-fp32指定
# ./start_comfyui.sh --force-fp32
```

Windows端末のWebブラウザで http://localhost:8888 を
開けばComfyUIが立ち上がるはず

## Additional Information
ただこのまま生成を続けると、/opt配下に大量のモデル・画像データが置かれてコンテナ肥大化  
→WSL肥大化  
→Windowsディスク枯渇につながる  
ので/optのディレクトリを別の物理ストレージにマウントする設定をするのを推奨

詳しくは私のQiita記事を参照  
WSL2上のLinuxマシンへホスト上の物理ディスクをマウントしよう(永続化もあるよ)  
https://qiita.com/m10i/items/c6051d7225c01f6ffd4d

## Thanks

Special thanks to everyone behind these awesome projects, without them, none of this would have been possible:

- [ComfyUI](https://github.com/comfyanonymous/ComfyUI)
