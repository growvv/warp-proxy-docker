#!/bin/bash

while true; do
    # 等待设定的间隔时间
    sleep ${RESTART_INTERVAL:-3600}
    
    echo "[$(date)] 开始定时更换 WARP IP..."
    
    # 1. 关闭旧隧道
    wg-quick down wg0
    
    # 2. 重新注册身份
    rm -f /wgcf-account.toml /wgcf-profile.conf
    wgcf register --accept-tos
    wgcf generate
    sed -i "s/MTU = .*/MTU = 1280/" wgcf-profile.conf
    cp wgcf-profile.conf /etc/wireguard/wg0.conf
    
    # 3. 重新拉起隧道
    WG_QUICK_USERSPACE_IMPLEMENTATION=wireguard-go wg-quick up wg0
    
    # 4. 重启代理服务
    pkill sockd
    sockd -D
    
    echo "[$(date)] IP 更换完成！新出口 IP 如下："
    curl -6 -s --socks5-hostname 127.0.0.1:1080 https://api64.ipify.org || echo "IPv6 获取失败"
done
