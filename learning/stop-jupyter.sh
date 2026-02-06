#!/bin/bash

# Jupyter 服务停止脚本 - 独立版本
# 可用于停止任何方式启动的 Jupyter Lab/Notebook

set -euo pipefail

echo "🛑 停止 Jupyter 服务..."
echo ""

# 获取 learning 目录路径（脚本所在目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="/tmp/jupyter-learning.pid"
STOPPED=false

# 1. 从 PID 文件停止（如果是通过 start-jupyter.sh 启动的）
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE" 2>/dev/null || echo "")
    if [ -n "$PID" ] && ps -p "$PID" > /dev/null 2>&1; then
        echo "  → 停止已记录的进程 (PID: $PID)..."
        kill "$PID" 2>/dev/null || true
        sleep 1
        STOPPED=true
    fi
    rm -f "$PID_FILE"
fi

# 2. 按工作目录查找并停止（通用的停止方式）
echo "  → 查找 working 目录的 Jupyter 进程..."
# 匹配包含 learning 目录路径的 jupyter-lab 进程
JUPYTER_PIDS=$(ps aux | grep "jupyter-lab" | grep "$SCRIPT_DIR" | grep -v grep | awk '{print $2}' || true)
if [ -n "$JUPYTER_PIDS" ]; then
    for PID in $JUPYTER_PIDS; do
        echo "    停止 jupyter-lab (PID: $PID)..."
        kill -TERM "$PID" 2>/dev/null || kill -9 "$PID" 2>/dev/null || true
    done
    sleep 1
    STOPPED=true
fi

# 3. 查找并停止所有 deno kernel 进程（防止僵尸进程）
echo "  → 查找 deno kernel 进程..."
DENO_PIDS=$(ps aux | grep "deno jupyter" | grep -v grep | awk '{print $2}' || true)
if [ -n "$DENO_PIDS" ]; then
    for PID in $DENO_PIDS; do
        echo "    停止 deno kernel (PID: $PID)..."
        kill -9 "$PID" 2>/dev/null || true
    done
    STOPPED=true
fi

# 4. 清理残留的 kernel 连接文件
echo "  → 清理残留文件..."
KERNEL_DIR="$HOME/Library/Jupyter/runtime"
if [ -d "$KERNEL_DIR" ]; then
    KERNEL_COUNT=$(ls -1 "$KERNEL_DIR"/kernel-*.json 2>/dev/null | wc -l || echo "0")
    if [ "$KERNEL_COUNT" -gt 0 ]; then
        rm -f "$KERNEL_DIR"/kernel-*.json
        echo "    已清理 $KERNEL_COUNT 个 kernel 连接文件"
    fi
    # 清理旧的 jpserver 文件
    rm -f "$KERNEL_DIR"/jpserver-*.json 2>/dev/null || true
    rm -f "$KERNEL_DIR"/jpserver-*.html 2>/dev/null || true
fi

# 5. 最终确认
echo ""
REMAINING=$(ps aux | grep -E "(jupyter-lab.*$SCRIPT_DIR|deno jupyter)" | grep -v grep | wc -l || echo "0")
if [ "$REMAINING" -eq 0 ]; then
    echo "✅ Jupyter 服务已完全停止"
else
    echo "⚠️  仍有 $REMAINING 个进程可能需要手动处理:"
    ps aux | grep -E "(jupyter-lab.*$SCRIPT_DIR|deno jupyter)" | grep -v grep | awk '{print "    PID " $2 ": " $11}' || true
fi
