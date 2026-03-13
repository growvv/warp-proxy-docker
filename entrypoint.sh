#!/bin/bash
mkdir -p /etc/wireguard

function register_warp() {
    echo "[$(date)] 正在注册 WARP 账号..."
    rm -f /wgcf-account.toml /wgcf-profile.conf
    wgcf register --accept-tos
    wgcf generate
    
    # 核心修复：删除 DNS 行防止 resolvconf 报错导致网卡删除
    sed -i '/DNS/d' wgcf-profile.conf
    # 设置 MTU 为 1280 提高兼容性
    sed -i "s/MTU = .*/MTU = 1280/" wgcf-profile.conf
    
    cp wgcf-profile.conf /etc/wireguard/wg0.conf
}

# 1. 初始化注册
register_warp

# 2. 启动隧道
echo "[$(date)] 启动 WireGuard 隧道..."
WG_QUICK_USERSPACE_IMPLEMENTATION=wireguard-go wg-quick up wg0

# 3. 检查网卡是否成功启动
max_retry=10
counter=0
while ! ip link show wg0 > /dev/null 2>&1; do
    sleep 1
    ((counter++))
    if [ $counter -ge $max_retry ]; then
        echo "错误：wg0 网卡未能在 10 秒内启动！"
        exit 1
    fi
done

# 4. 启动代理
echo "[$(date)] 启动 Dante SOCKS5 代理..."
sockd -D

# 5. 后台定时任务
/rotate_ip.sh &
wait
