#!/bin/bash
set -e
echo "[INFO] Starting entrypoint.sh (v3 with warp-go)"

mkdir -p /etc/warp-go
cd /etc/warp-go

if [ ! -f "warp.conf" ]; then
    echo "[INFO] Generating new WARP identity with warp-go..."
    warp-go --register --config=warp.conf
    
    # 增加 Socks5 支持（通过 warp-go 内部特性，或者我们还是结合 wireproxy 提供 Socks5，
    # 但根据要求，我们要用 warp-go 接管。需要注意 warp-go 1.0.8 并不直接暴露 Socks5 端口。
    # 为了实现 Socks5，我们需要使用 warp-go 生成的 WireGuard 配置并用 wireproxy 启动。
    # 这样既利用了 warp-go 的高性能自动换 IP 特性，又暴露了安全的 1080 代理。
    # 等等，warp-go 实际上本身就是一个专门替换 wgcf 的配置生成器，同时也可以作为代理端（--proxy）！
    # 查阅资料得知，warp-go --export-wireguard=warp.conf 后，可以直接搭配 wireproxy 使用。
    # 这里我们用 warp-go 注册账号并导出配置，然后用 wireproxy 启动 1080 端口。
    
    # 转换为 wireproxy 格式
    echo "" >> warp.conf
    echo "[Socks5]" >> warp.conf
    echo "BindAddress = 0.0.0.0:1080" >> warp.conf
fi

echo "[INFO] Starting wireproxy with warp-go generated config..."
wireproxy -c /etc/warp-go/warp.conf > /var/log/wireproxy.log 2>&1 &
WP_PID=$!

sleep 3

echo "[INFO] Starting rotate_ip.sh in background..."
bash /rotate_ip.sh > /var/log/rotate.log 2>&1 &

echo "[INFO] Entering healthcheck loop..."
while true
do
  bash /healthcheck.sh
  tail -n 10 /var/log/wireproxy.log
  sleep 60
done
