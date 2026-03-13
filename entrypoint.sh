#!/bin/bash

# 初始化 WARP 账号并生成 WireGuard 配置文件
cd /etc/wireguard
if [ ! -f "wgcf-profile.conf" ]; then
    echo "Generating new WARP identity..."
    wgcf register --accept-tos
    wgcf generate
fi

# 转换配置为 wireproxy 格式，加入 Socks5 配置
cat wgcf-profile.conf > wireproxy.conf
echo "" >> wireproxy.conf
echo "[Socks5]" >> wireproxy.conf
echo "BindAddress = 0.0.0.0:1080" >> wireproxy.conf

# 启动 Wireproxy
wireproxy -c /etc/wireguard/wireproxy.conf &

sleep 5

bash /rotate_ip.sh &

while true
do
  bash /healthcheck.sh
  sleep 60
done
