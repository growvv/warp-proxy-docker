#!/bin/bash
while true; do
    sleep ${RESTART_INTERVAL:-3600}
    echo "[$(date)] 定时更换 IP..."
    
    wg-quick down wg0
    
    rm -f /wgcf-account.toml /wgcf-profile.conf
    wgcf register --accept-tos && wgcf generate
    sed -i '/DNS/d' wgcf-profile.conf
    sed -i "s/MTU = .*/MTU = 1280/" wgcf-profile.conf
    sed -i '/\[Interface\]/a Table = off' wgcf-profile.conf
    cp wgcf-profile.conf /etc/wireguard/wg0.conf
    
    WG_QUICK_USERSPACE_IMPLEMENTATION=wireguard-go wg-quick up wg0
    ip -4 route add 0.0.0.0/0 dev wg0
    ip -6 route add ::/0 dev wg0
    
    echo "[$(date)] 更换完成，测试连接..."
    curl -6 -s --socks5-hostname 127.0.0.1:1080 https://api64.ipify.org || echo "失败"
done
