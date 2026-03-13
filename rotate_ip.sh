#!/bin/bash
while true; do
    sleep ${RESTART_INTERVAL:-3600}
    echo "[$(date)] 开始定时更换 IP..."
    
    # 下线网卡
    wg-quick down wg0
    
    # 重新注册
    rm -f /wgcf-account.toml /wgcf-profile.conf
    wgcf register --accept-tos && wgcf generate
    
    # 再次删除 DNS 行
    sed -i '/DNS/d' wgcf-profile.conf
    sed -i "s/MTU = .*/MTU = 1280/" wgcf-profile.conf
    cp wgcf-profile.conf /etc/wireguard/wg0.conf
    
    # 重新上线
    WG_QUICK_USERSPACE_IMPLEMENTATION=wireguard-go wg-quick up wg0
    
    # 重启代理
    pkill sockd && sockd -D
    
    echo "[$(date)] IP 更换完成。当前测试："
    curl -6 -s --socks5-hostname 127.0.0.1:1080 https://api64.ipify.org || echo "IPv6 连接失败"
done
