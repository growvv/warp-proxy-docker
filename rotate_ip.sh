#!/bin/bash

# 后台无限循环，定时更换 IP (删除现有配置并重启 wireproxy)
while true
do
  sleep ${ROTATE_INTERVAL:-3600}

  echo "Rotating WARP IP..."
  pkill wireproxy
  
  mkdir -p /etc/wireguard
  cd /etc/wireguard
  rm -f wgcf-account.toml wgcf-profile.conf wireproxy.conf
  wgcf register --accept-tos
  wgcf generate
  
  cat wgcf-profile.conf > wireproxy.conf
  echo "" >> wireproxy.conf
  echo "[Socks5]" >> wireproxy.conf
  echo "BindAddress = 0.0.0.0:1080" >> wireproxy.conf
  sed -i 's/DNS = .*/DNS = 1.1.1.1, 1.0.0.1, 2606:4700:4700::1111, 2606:4700:4700::1001/g' wireproxy.conf

  wireproxy -c /etc/wireguard/wireproxy.conf &

  echo "IP rotated"
done
