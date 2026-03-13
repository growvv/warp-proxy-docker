#!/bin/bash
mkdir -p /etc/wireguard
function register_warp() {
    echo "[$(date)] 正在生成新的 WARP 账号..."
    rm -f /wgcf-account.toml /wgcf-profile.conf
    wgcf register --accept-tos
    wgcf generate
    sed -i "s/MTU = .*/MTU = 1280/" wgcf-profile.conf
    cp wgcf-profile.conf /etc/wireguard/wg0.conf
}
register_warp
echo "[$(date)] 正在启动 WireGuard 隧道..."
WG_QUICK_USERSPACE_IMPLEMENTATION=wireguard-go wg-quick up wg0
echo "[$(date)] 正在启动 Dante SOCKS5 代理..."
sockd -D
/rotate_ip.sh &
wait
