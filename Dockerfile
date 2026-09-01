FROM ghcr.io/caidaoli/cliproxyapi:latest

USER root
RUN set -eux; \
    arch="$(uname -m)"; \
    case "$arch" in \
        x86_64)  cf_arch="amd64" ;; \
        aarch64) cf_arch="arm64" ;; \
        *) echo "unsupported arch: $arch"; exit 1 ;; \
    esac; \
    if command -v apt-get >/dev/null 2>&1; then \
        apt-get update && apt-get install -y --no-install-recommends curl ca-certificates socat && rm -rf /var/lib/apt/lists/*; \
    elif command -v apk >/dev/null 2>&1; then \
        apk add --no-cache curl ca-certificates socat; \
    fi; \
    curl -fsSL "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${cf_arch}" \
        -o /usr/local/bin/cloudflared; \
    chmod +x /usr/local/bin/cloudflared; \
    cloudflared --version

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 10000 18317

ENTRYPOINT ["/start.sh"]
