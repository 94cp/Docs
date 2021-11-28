# WebRTC研究笔记

## 一、环境搭建

⚠️*国内需翻墙*

1. 安装**depot_tools**


```shell
# clone代码
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

# 环境变量（~/.bashrc or ~/.zshrc）
export PATH=depot_tools路径/depot_tools:$PATH
```

2. iOS环境配置

```shell
# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# ninja
brew install nijia

# 创建工作空间（文件夹），运行👇命令
mkdir ~/Desktop/WS/webrtc-ios
cd ~/Desktop/WS/webrtc-ios

# clone代码
fetch --nohooks webrtc_ios
# 同步配置
gclient sync

# 模拟器
gn gen out/ios_sim --args='target_os="ios" target_cpu="x64"  rtc_include_tests=false' --ide=xcode
# 真机
gn gen out/ios --args='target_os="ios" target_cpu="arm64"' --ide=xcode
# 打包
python tools_webrtc/ios/build_ios_libs.py --arch arm64 x64

# 查看framework支持架构
lipo -info WebRTC.framework/WebRTC
```

3. Android环境配置

```shell
# TODO
```

## 二、
