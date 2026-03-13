#!/bin/bash
echo "[INFO] Running healthcheck..."
IP=$(curl -s --socks5 127.0.0.1:1080 --connect-timeout 10 https://cloudflare.com/cdn-cgi/trace | grep "ip=" | cut -d'=' -f2)

if [ -z "$IP" ]; then
   echo "[ERROR] Proxy dead or unreachable, restarting wireproxy..."
   pkill wireproxy
   sleep 3
   cd /etc/warp-go
   wireproxy -c warp.conf > /var/log/wireproxy.log 2>&1 &
else
   echo "[INFO] Healthcheck passed. Current IP: $IP"
fi
