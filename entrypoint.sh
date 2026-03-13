#!/bin/bash
# 初始化并启动隧道
mkdir -p /etc/wireguard

function register_warp() {
    rm -f /wgcf-account.toml /wgcf-profile.conf
    wgcf register --accept-tos
    wgcf generate
    sed -i "s/MTU = .*/MTU = 1280/" wgcf-profile.conf
    cp wgcf-profile.conf /etc/wireguard/wg0.conf
}

register_warp
WG_QUICK_USERSPACE_IMPLEMENTATION=wireguard-go wg-quick up wg0

# 启动代理
sockd -D
# 启动后台定时更换
/rotate_ip.sh &
wait
