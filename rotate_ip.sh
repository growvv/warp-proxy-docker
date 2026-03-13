#!/bin/bash

while true
do
  sleep ${ROTATE_INTERVAL}

  pkill warp-proxy

  warp-proxy \
  --bind 0.0.0.0:1080 \
  --country US &

  echo "IP rotated"
done
