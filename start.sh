#!/bin/sh
set -e

echo "[start.sh] === accept-18317 版本已生效 ==="

# 1. cloudflared 隧道
if [ -n "$CLOUDFLARE_TUNNEL_TOKEN" ]; then
    echo "[start.sh] 启动 cloudflared..."
    cloudflared tunnel --no-autoupdate run --token "$CLOUDFLARE_TUNNEL_TOKEN" &
fi

# 2. 端口桥:Render 只认 0.0.0.0,新版 CPA 只听 127.0.0.1:18317
OUT_PORT="${PORT:-10000}"
if command -v socat >/dev/null 2>&1; then
    echo "[start.sh] socat: 0.0.0.0:${OUT_PORT} -> 127.0.0.1:18317"
    socat TCP-LISTEN:"${OUT_PORT}",fork,reuseaddr,bind=0.0.0.0 TCP:127.0.0.1:18317 &
else
    echo "[start.sh] 警告:未安装 socat,Render 将检测不到端口!"
fi

# 3. 启动 CPA 主程序
echo "[start.sh] 启动 CPA 主程序..."
if [ -x /CLIProxyAPI/CLIProxyAPI ]; then
    exec /CLIProxyAPI/CLIProxyAPI
elif [ -x /CLIProxyAPI/cli-proxy-api ]; then
    exec /CLIProxyAPI/cli-proxy-api
else
    ls -la /CLIProxyAPI/ || true
    exit 1
fi
