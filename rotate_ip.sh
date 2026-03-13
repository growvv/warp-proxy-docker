#!/bin/bash
while true; do
    sleep ${RESTART_INTERVAL:-3600}
    echo "[$(date)] 执行定时换IP..."
    wg-quick down wg0
    # 重新注册
    rm -f /wgcf-account.toml /wgcf-profile.conf
    wgcf register --accept-tos && wgcf generate
    sed -i "s/MTU = .*/MTU = 1280/" wgcf-profile.conf
    cp wgcf-profile.conf /etc/wireguard/wg0.conf
    # 重启
    WG_QUICK_USERSPACE_IMPLEMENTATION=wireguard-go wg-quick up wg0
    pkill sockd && sockd -D
    echo "[$(date)] 更换完成"
done
