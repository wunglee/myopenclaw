#!/bin/bash

# Jupyter 服务启动脚本 - 限制单内核版本
# 只允许同时运行一个 Kernel，避免内存占用过高

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="/tmp/jupyter-learning.pid"
JUPYTER_CONFIG="/tmp/jupyter-learning-config.py"

echo "🚀 启动 Jupyter 服务（单内核模式）..."
echo ""

# 检查是否已有实例在运行
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE" 2>/dev/null || echo "")
    if [ -n "$OLD_PID" ] && ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo "⚠️  Jupyter 已在运行 (PID: $OLD_PID)"
        echo ""
        echo "请先停止现有实例: ./stop-jupyter.sh"
        echo ""
        exit 1
    else
        rm -f "$PID_FILE"
    fi
fi

# 检查 jupyter 是否安装
if ! command -v jupyter &> /dev/null; then
    echo "❌ 错误: 未找到 jupyter 命令"
    echo "  请先安装: pip install jupyterlab"
    echo ""
    exit 1
fi

echo "📁 工作目录: $SCRIPT_DIR"
echo ""

# 检查 Deno 内核
if ! jupyter kernelspec list | grep -q "deno"; then
    echo "⚠️  警告: 未找到 Deno 内核"
    echo "  请安装: deno jupyter --unstable --install"
    echo ""
fi

echo "🧹 清理残留的 kernel 进程..."
"$SCRIPT_DIR/stop-jupyter.sh" > /dev/null 2>&1 || true

# 创建限制单内核的 Jupyter 配置
cat > "$JUPYTER_CONFIG" << 'EOF'
# 限制 Kernel 数量配置
import os

# 当打开新 notebook 时，自动关闭闲置超过 1 秒的旧 kernel
c.MappingKernelManager.cull_idle_timeout = 1
c.MappingKernelManager.cull_interval = 5
c.MappingKernelManager.cull_connected = True

# 禁用 kernel 崩溃后自动重启（避免僵尸进程）
c.MappingKernelManager.autorestart = False

# 设置 kernel 启动超时
c.MappingKernelManager.kernel_ready_timeout = 30

# 限制每个用户的 kernel 数量（如果支持）
# 注意：需要通过自定义 manager 实现硬限制
c.MappingKernelManager.max_kernels_per_user = 1
EOF

echo ""
echo "📚 可用学习目录:"
echo "  • course-7day/          - 7天AI码权课程"
echo "  • teacher-learning/     - 教师学习材料"
echo ""
echo "⚙️  单内核模式: 限制只能同时运行 1 个 Kernel"
echo "   （切换 Notebook 时旧内核会自动关闭）"
echo ""
echo "🌐 启动 Jupyter Lab..."
echo ""
echo "提示:"
echo "  • 按 Ctrl+C 停止服务"
echo "  • 或运行: ./stop-jupyter.sh"
echo "  • 打开新 Notebook 时旧内核会自动关闭释放内存"
echo ""

# 启动并记录 PID
cd "$SCRIPT_DIR"
jupyter lab --notebook-dir="$SCRIPT_DIR" --config="$JUPYTER_CONFIG" &
echo $! > "$PID_FILE"
wait $(cat "$PID_FILE")
rm -f "$PID_FILE"
rm -f "$JUPYTER_CONFIG"
