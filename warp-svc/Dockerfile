FROM ubuntu:22.04

# 避免安装时的交互提示
ENV DEBIAN_FRONTEND=noninteractive

ARG http_proxy
ARG https_proxy
ARG HTTP_PROXY
ARG HTTPS_PROXY

ENV http_proxy=${http_proxy}
ENV https_proxy=${https_proxy}
ENV HTTP_PROXY=${HTTP_PROXY}
ENV HTTPS_PROXY=${HTTPS_PROXY}

# 安装必要的依赖、Cloudflare 官方源以及 socat（用于端口转发）
RUN apt-get update && \
    apt-get install -y curl gnupg lsb-release socat iproute2 iptables && \
    curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list && \
    apt-get update && \
    apt-get install -y cloudflare-warp && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 复制脚本并赋予执行权限
COPY entrypoint.sh /entrypoint.sh
COPY ip_changer.sh /ip_changer.sh
RUN chmod +x /entrypoint.sh /ip_changer.sh

ENTRYPOINT ["/entrypoint.sh"]
