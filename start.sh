#!/bin/sh
# 同时启动 cloudflared 隧道 和 CPA 主程序
set -e

echo "[start.sh] 容器启动..."

# ---- 1. 启动 cloudflared 隧道(后台)----
if [ -n "$CLOUDFLARE_TUNNEL_TOKEN" ]; then
    echo "[start.sh] 检测到 Tunnel Token,启动 cloudflared..."
    cloudflared tunnel --no-autoupdate run --token "$CLOUDFLARE_TUNNEL_TOKEN" &
    CF_PID=$!
    echo "[start.sh] cloudflared 已在后台启动 (pid=$CF_PID)"
else
    echo "[start.sh] 警告:未设置 CLOUDFLARE_TUNNEL_TOKEN,跳过隧道(服务将无法通过域名访问)"
fi

# ---- 2. 启动 CPA 主程序(前台)----
# 直接调用官方镜像里的入口程序,让 CPA 成为容器主进程
echo "[start.sh] 启动 CPA 主程序..."

# CPA 可执行文件路径(官方镜像默认在 /CLIProxyAPI/ 下)
if [ -x "/CLIProxyAPI/CLIProxyAPI" ]; then
    exec /CLIProxyAPI/CLIProxyAPI
elif [ -x "/CLIProxyAPI/cli-proxy-api" ]; then
    exec /CLIProxyAPI/cli-proxy-api
else
    echo "[start.sh] 未在预期路径找到 CPA 可执行文件,尝试列出目录:"
    ls -la /CLIProxyAPI/ || true
    echo "[start.sh] 请检查镜像内 CPA 程序的实际路径并修改 start.sh"
    exit 1
fi
