FROM alpine:3.20

RUN apk add --no-cache curl bash iproute2

# 下载 warp-proxy
RUN wget -O /usr/local/bin/warp-proxy \
https://github.com/bepass-org/warp-plus/releases/latest/download/warp-proxy-linux-amd64 \
&& chmod +x /usr/local/bin/warp-proxy

COPY entrypoint.sh /entrypoint.sh
COPY rotate_ip.sh /rotate_ip.sh
COPY healthcheck.sh /healthcheck.sh

RUN chmod +x /*.sh

ENTRYPOINT ["/entrypoint.sh"]
