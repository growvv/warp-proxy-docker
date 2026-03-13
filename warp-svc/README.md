# WARP Proxy Docker (官方完整版 / warp-svc)

这是一个基于 Cloudflare 官方 `warp-svc` 客户端的 Docker 容器。它提供了完整的网络路由接管和 6in4（IPv6 支持）能力。

## ⚠️ 适用场景与缺点说明

- **✅ 支持 IPv6 (6in4)**: 该版本能提供完整的双栈代理，通过代理可以访问纯 IPv6 的网站。
- **✅ 高连通率**: 由于使用的是官方守护进程，具有更强大的网络混淆和重连机制。
- **❌ CPU 占用较高**: 守护进程会在后台进行频繁的系统路由注入、心跳维护和网络探测，容易导致容器 CPU 占用居高不下。
- **❌ 权限要求高**: 容器必须在 `privileged: true` 及 `cap_add: NET_ADMIN` 的特权模式下运行。

如果您只需要轻量级的 IPv4 代理，请返回上级目录使用默认的 **Wireproxy 轻量版**。如果您确切需要通过代理访问纯 IPv6 网站，请使用此目录下的版本。

## 🚀 快速开始

### 1. 启动服务
```bash
cd warp-svc
docker compose up -d
```

### 2. 验证 IPv6 连接
```bash
curl -x socks5h://127.0.0.1:1080 https://ipv6.icanhazip.com
```

### 3. 配置更换 IP 间隔
可以通过修改 `docker-compose.yml` 中的 `RESTART_INTERVAL` (单位: 秒) 来控制自动换 IP 的频率。

## 📝 文件说明
- `Dockerfile` - 基于 Ubuntu 构建并安装 `cloudflare-warp` 官方客户端
- `entrypoint.sh` - 初始化 WARP 并使用 `socat` 建立 1080 端口到代理端口的转发
- `ip_changer.sh` - 定时通过 `warp-cli` 执行重新注册和重连操作以达到更换 IP 的目的
