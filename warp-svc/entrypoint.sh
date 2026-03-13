#!/bin/bash

# 1. 启动 WARP 后台守护进程
warp-svc > /dev/null 2>&1 &
WARP_PID=$!

# 等待 daemon 启动完成
echo "Waiting for warp-svc to initialize..."
sleep 3
while ! warp-cli --accept-tos status > /dev/null 2>&1; do
    sleep 1
done
echo "warp-svc is running."

# 2. 初始化 WARP 配置 (使用内部端口 10080)
warp-cli --accept-tos registration new
warp-cli --accept-tos mode proxy
warp-cli --accept-tos proxy port 10080
warp-cli --accept-tos connect

# 等待连接成功
sleep 3

# 3. 使用 socat 将容器的 0.0.0.0 端口转发到 WARP 的 127.0.0.1 端口
# 这样外部才可以连接到容器里的代理
socat TCP-LISTEN:${SOCKS_PORT:-1080},fork,reuseaddr TCP:127.0.0.1:10080 &

# 4. 启动定时更换 IP 的后台脚本
/ip_changer.sh &

# 保持前台运行，防止容器退出
wait $WARP_PID