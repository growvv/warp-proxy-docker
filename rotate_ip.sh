#!/bin/bash
echo "[INFO] Starting rotate_ip loop..."

# 如果 EXPECTED_REGIONS 不为空，解析成数组。如果为空，留空代表不需要匹配地区。
IFS=',' read -r -a REGIONS_ARRAY <<< "${EXPECTED_REGIONS}"

while true
do
  # 第一次启动时，直接尝试匹配地区
  MATCH=false
  while [ "$MATCH" = false ]; do
      echo "[INFO] Requesting new WARP identity with warp-go..."
      pkill wireproxy
      sleep 3
      
      cd /etc/warp-go
      rm -f warp.conf
      warp-go --register --export-wireguard=warp.conf
      
      echo "" >> warp.conf
      echo "[Socks5]" >> warp.conf
      echo "BindAddress = 0.0.0.0:1080" >> warp.conf
      
      # 优先级处理
      if [ "${IPV6_PRIORITY}" = "true" ]; then
          sed -i 's/DNS = .*/DNS = 2606:4700:4700::1111, 2606:4700:4700::1001, 1.1.1.1, 1.0.0.1/g' warp.conf
      else
          sed -i 's/DNS = .*/DNS = 1.1.1.1, 1.0.0.1, 2606:4700:4700::1111, 2606:4700:4700::1001/g' warp.conf
      fi

      echo "[INFO] Starting wireproxy..."
      wireproxy -c /etc/warp-go/warp.conf > /var/log/wireproxy.log 2>&1 &
      sleep 10
      
      # 检查当前获取到的 IP 地区
      CURRENT_REGION=$(curl -s --socks5 127.0.0.1:1080 --connect-timeout 5 https://api.ip.sb/geoip | jq -r '.country_code')
      
      if [ -z "$CURRENT_REGION" ] || [ "$CURRENT_REGION" == "null" ]; then
          echo "[WARN] Could not determine region, retrying..."
          continue
      fi
      
      echo "[INFO] Current WARP Region is: ${CURRENT_REGION}"
      
      # 如果没有配置期望地区，那么刷到啥就是啥，直接成功退出循环
      if [ ${#REGIONS_ARRAY[@]} -eq 0 ]; then
          echo "[INFO] No EXPECTED_REGIONS specified, keeping IP."
          MATCH=true
          break
      fi
      
      # 检查是否匹配期望地区
      for REGION in "${REGIONS_ARRAY[@]}"; do
          if [ "${CURRENT_REGION}" == "${REGION}" ]; then
              MATCH=true
              break
          fi
      done
      
      if [ "$MATCH" = true ]; then
          echo "[INFO] Region matched (${CURRENT_REGION})! Keeping IP."
      else
          echo "[INFO] Region ${CURRENT_REGION} not in expected list (${EXPECTED_REGIONS}). Re-rolling in 5s..."
          sleep 5
      fi
  done
  
  # 满足地区后，进入休眠，等待下一次定时刷新 (ROTATE_INTERVAL)
  echo "[INFO] IP rotated and region matched. Sleeping for ${ROTATE_INTERVAL:-3600} seconds..."
  sleep ${ROTATE_INTERVAL:-3600}
done
