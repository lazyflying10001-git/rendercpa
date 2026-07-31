# 基于 CPA 官方镜像,在里面再装一个 cloudflared,启动时两个一起跑
# 锁定 v7.1.19(无示例密钥强制检测的版本),不要用 latest
FROM ghcr.io/caidaoli/cliproxyapi:latest

# 安装 cloudflared(Cloudflare 隧道客户端)
# 自动识别 CPU 架构(Render 一般是 amd64)
USER root
RUN set -eux; \
    arch="$(uname -m)"; \
    case "$arch" in \
        x86_64)  cf_arch="amd64" ;; \
        aarch64) cf_arch="arm64" ;; \
        *) echo "unsupported arch: $arch"; exit 1 ;; \
    esac; \
    if command -v apt-get >/dev/null 2>&1; then \
        apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && rm -rf /var/lib/apt/lists/*; \
    elif command -v apk >/dev/null 2>&1; then \
        apk add --no-cache curl ca-certificates; \
    fi; \
    curl -fsSL "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${cf_arch}" \
        -o /usr/local/bin/cloudflared; \
    chmod +x /usr/local/bin/cloudflared; \
    cloudflared --version

# 放入启动脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Render 通过 PORT 环境变量告诉容器对外端口,但我们走隧道,这个不强制
# CPA 默认监听 8317
EXPOSE 8317

ENTRYPOINT ["/start.sh"]
