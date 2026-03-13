#!/bin/bash

# 确保目录存在
mkdir -p /etc/wireguard
cd /etc/wireguard

# 初始化 WARP 账号并生成 WireGuard 配置文件
if [ ! -f "wgcf-profile.conf" ]; then
    echo "Generating new WARP identity..."
    wgcf register --accept-tos
    wgcf generate
fi

# 转换配置为 wireproxy 格式，加入 Socks5 配置
# 为了解决 IPv6 支持问题，显式修改 Endpoint 为 IPv4 (或者让 wgcf 自动选择)
cat wgcf-profile.conf > wireproxy.conf
echo "" >> wireproxy.conf
echo "[Socks5]" >> wireproxy.conf
echo "BindAddress = 0.0.0.0:1080" >> wireproxy.conf

# 强制 DNS 使用 WARP 的 DNS，以正确解析并转发 IPv6（6in4）
sed -i 's/DNS = .*/DNS = 1.1.1.1, 1.0.0.1, 2606:4700:4700::1111, 2606:4700:4700::1001/g' wireproxy.conf

# 启动 Wireproxy
wireproxy -c /etc/wireguard/wireproxy.conf &

sleep 5

bash /rotate_ip.sh &

while true
do
  bash /healthcheck.sh
  sleep 60
done
