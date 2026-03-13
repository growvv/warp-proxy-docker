FROM alpine:3.20

# 1. 必须添加 unzip 工具来处理 zip 文件
RUN apk add --no-cache curl bash iproute2 ca-certificates unzip

# 2. 下载、解压、重命名并清理
# 注意：warp-plus 的 zip 包内二进制文件名通常是 warp-plus
RUN curl -L -o /tmp/warp.zip https://github.com/bepass-org/warp-plus/releases/download/v1.2.6/warp-plus_linux-amd64.zip \
    && unzip /tmp/warp.zip -d /usr/local/bin/ \
    && mv /usr/local/bin/warp-plus /usr/local/bin/warp-proxy \
    && chmod +x /usr/local/bin/warp-proxy \
    && rm /tmp/warp.zip

COPY entrypoint.sh /entrypoint.sh
COPY rotate_ip.sh /rotate_ip.sh
COPY healthcheck.sh /healthcheck.sh

RUN chmod +x /*.sh

ENTRYPOINT ["/entrypoint.sh"]
