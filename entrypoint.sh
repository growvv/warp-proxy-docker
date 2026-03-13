#!/bin/bash
mkdir -p /etc/wireguard

function register_warp() {
    echo "[$(date)] 注册 WARP..."
    rm -f /wgcf-account.toml /wgcf-profile.conf
    wgcf register --accept-tos && wgcf generate
    sed -i '/DNS/d' wgcf-profile.conf
    sed -i "s/MTU = .*/MTU = 1280/" wgcf-profile.conf
    # 禁用 wg-quick 自动路由，改由我们手动控制，防止崩溃
    sed -i '/\[Interface\]/a Table = off' wgcf-profile.conf
    cp wgcf-profile.conf /etc/wireguard/wg0.conf
}

register_warp

echo "[$(date)] 启动隧道..."
WG_QUICK_USERSPACE_IMPLEMENTATION=wireguard-go wg-quick up wg0

# 强制设置路由：让容器内所有出口流量走 wg0
ip -4 route add 0.0.0.0/0 dev wg0
ip -6 route add ::/0 dev wg0

echo "[$(date)] 检查隧道握手状态..."
sleep 2
wg show wg0

# 启动 Gost 代理：监听 1080 端口
echo "[$(date)] 启动 Gost SOCKS5 代理..."
gost -L socks5://:1080?dns=1.1.1.1 &

/rotate_ip.sh &
wait
