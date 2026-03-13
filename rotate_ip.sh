#!/bin/bash
while true; do
    sleep ${RESTART_INTERVAL:-3600}
    echo "[$(date)] 开始定时更换 WARP IP..."
    wg-quick down wg0
    rm -f /wgcf-account.toml /wgcf-profile.conf
    wgcf register --accept-tos && wgcf generate
    sed -i "s/MTU = .*/MTU = 1280/" wgcf-profile.conf
    cp wgcf-profile.conf /etc/wireguard/wg0.conf
    WG_QUICK_USERSPACE_IMPLEMENTATION=wireguard-go wg-quick up wg0
    pkill sockd && sockd -D
    echo "[$(date)] 更换完成，新 IP:"
    curl -6 -s --socks5-hostname 127.0.0.1:1080 https://api64.ipify.org || echo "获取失败"
done
