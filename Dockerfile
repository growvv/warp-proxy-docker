FROM alpine:latest

# 1. 直接通过 apk 安装所有工具（包含 wireguard-go）
# 这会从官方镜像源抓取最新稳定版，不再依赖脆弱的 GitHub API
RUN apk add --no-cache \
    wireguard-tools \
    wireguard-go \
    curl \
    dante-server \
    iproute2 \
    ca-certificates \
    bash

# 2. 安装 wgcf (这个不在 apk 库中，仍需 curl，但我们用了更稳的下载逻辑)
RUN WGCF_URL=$(curl -s https://api.github.com/repos/ViRb3/wgcf/releases/latest | grep "browser_download_url.*linux_amd64" | cut -d '"' -f 4) && \
    if [ -z "$WGCF_URL" ]; then WGCF_URL="https://github.com/ViRb3/wgcf/releases/download/v2.2.22/wgcf_2.2.22_linux_amd64"; fi && \
    curl -L "$WGCF_URL" -o /usr/local/bin/wgcf && \
    chmod +x /usr/local/bin/wgcf

# 3. 拷贝脚本与配置
COPY entrypoint.sh /entrypoint.sh
COPY rotate_ip.sh /rotate_ip.sh
COPY sockd.conf /etc/sockd.conf

RUN chmod +x /entrypoint.sh /rotate_ip.sh

ENTRYPOINT ["/entrypoint.sh"]
