#!/usr/bin/env bash
set -euo pipefail

# OpenClaw Docker 开发沙盒启动脚本
# 用途：在隔离的 Docker 容器中运行 OpenClaw 开发环境
#
# 配置文件优先级：
#   1. .dev-sandbox.env.local (本地覆盖，不提交到 git)
#   2. .dev-sandbox.env (默认配置)
#   3. 环境变量

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

# 加载配置文件
load_config() {
    local config_file="${PROJECT_ROOT}/sandbox/.dev-sandbox.env"
    local local_config="${PROJECT_ROOT}/sandbox/.dev-sandbox.env.local"

    # 先加载默认配置
    if [[ -f "$config_file" ]]; then
        # shellcheck source=/dev/null
        set -a
        source "$config_file"
        set +a
        log_debug "已加载配置: $config_file"
    fi

    # 本地配置覆盖
    if [[ -f "$local_config" ]]; then
        # shellcheck source=/dev/null
        set -a
        source "$local_config"
        set +a
        log_debug "已加载本地配置: $local_config"
    fi

    # 设置默认值
    export OPENCLAW_DEV_IMAGE="${OPENCLAW_DEV_IMAGE:-openclaw-dev}"
    export OPENCLAW_DEV_CONTAINER="${OPENCLAW_DEV_CONTAINER:-openclaw-dev}"
    export OPENCLAW_GATEWAY_PORT="${OPENCLAW_GATEWAY_PORT:-18789}"
    export OPENCLAW_BRIDGE_PORT="${OPENCLAW_BRIDGE_PORT:-18790}"
    export OPENCLAW_PROJECT_DIR="${OPENCLAW_PROJECT_DIR:-$PROJECT_ROOT}"
    export OPENCLAW_CONFIG_DIR="${OPENCLAW_CONFIG_DIR:-$HOME/.openclaw-dev}"
    export OPENCLAW_DOCKER_NETWORK="${OPENCLAW_DOCKER_NETWORK:-bridge}"
    export OPENCLAW_DOCKER_EXTRA_ARGS="${OPENCLAW_DOCKER_EXTRA_ARGS:-}"
}

# 检查 Docker 是否可用
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi

    if ! docker info &> /dev/null; then
        log_error "Docker 守护进程未运行，请启动 Docker"
        exit 1
    fi
}

# 检查 Dockerfile 是否存在
check_dockerfile() {
    local dockerfile="${PROJECT_ROOT}/sandbox/Dockerfile.dev"
    if [[ ! -f "$dockerfile" ]]; then
        log_error "Dockerfile.dev 不存在: $dockerfile"
        exit 1
    fi
}

# 构建开发镜像
build_image() {
    log_info "构建开发沙盒镜像: ${OPENCLAW_DEV_IMAGE}"

    docker build \
        -t "${OPENCLAW_DEV_IMAGE}" \
        -f "${PROJECT_ROOT}/sandbox/Dockerfile.dev" \
        "${PROJECT_ROOT}"

    log_info "镜像构建完成"
}

# 准备挂载目录
prepare_directories() {
    mkdir -p "${OPENCLAW_CONFIG_DIR}"
}

# 检测是否为 TTY
is_tty() {
    [ -t 0 ] && [ -t 1 ]
}

# 启动开发容器
start_container() {
    # 检查容器是否已存在
    if docker ps -a --format '{{.Names}}' | grep -q "^${OPENCLAW_DEV_CONTAINER}$"; then
        if docker ps --format '{{.Names}}' | grep -q "^${OPENCLAW_DEV_CONTAINER}$"; then
            log_warn "容器 ${OPENCLAW_DEV_CONTAINER} 已在运行"
            if is_tty; then
                log_info "进入现有容器..."
                docker exec -it "${OPENCLAW_DEV_CONTAINER}" bash
            else
                log_info "容器正在运行，使用 './sandbox/dev-sandbox.sh enter' 进入"
            fi
            return
        else
            log_info "启动已停止的容器..."
            docker start "${OPENCLAW_DEV_CONTAINER}" > /dev/null
            if is_tty; then
                docker exec -it "${OPENCLAW_DEV_CONTAINER}" bash
            else
                log_info "容器已启动，使用 './sandbox/dev-sandbox.sh enter' 进入"
            fi
            return
        fi
    fi

    log_info "启动开发沙盒容器..."
    log_info "项目目录: ${OPENCLAW_PROJECT_DIR}"
    log_info "配置目录: ${OPENCLAW_CONFIG_DIR}"
    log_info "容器名称: ${OPENCLAW_DEV_CONTAINER}"

    prepare_directories

    # 构建 Docker 参数数组
    local docker_args=()
    docker_args+=("--network" "${OPENCLAW_DOCKER_NETWORK}")
    docker_args+=("-p" "${OPENCLAW_GATEWAY_PORT}:18789")
    docker_args+=("-p" "${OPENCLAW_BRIDGE_PORT}:18790")
    docker_args+=("-v" "${OPENCLAW_PROJECT_DIR}:/workspace")
    docker_args+=("-v" "${OPENCLAW_CONFIG_DIR}:/root/.openclaw")
    docker_args+=("-e" "NODE_ENV=development")
    docker_args+=("-e" "OPENCLAW_PROFILE=dev")
    docker_args+=("--hostname" "openclaw-dev")

    if is_tty; then
        # 交互式模式
        docker run -it \
            --name "${OPENCLAW_DEV_CONTAINER}" \
            "${docker_args[@]}" \
            -w /workspace \
            "${OPENCLAW_DEV_IMAGE}" \
            bash
    else
        # 非交互式模式，后台运行
        docker run -d \
            --name "${OPENCLAW_DEV_CONTAINER}" \
            "${docker_args[@]}" \
            -w /workspace \
            "${OPENCLAW_DEV_IMAGE}" \
            sleep infinity
        log_info "容器已在后台启动"
        log_info "使用 './sandbox/dev-sandbox.sh enter' 进入容器"
        log_info "使用 './sandbox/dev-sandbox.sh exec <命令>' 执行命令"
    fi
}

# 停止容器
stop_container() {
    log_info "停止容器 ${OPENCLAW_DEV_CONTAINER}..."
    docker stop "${OPENCLAW_DEV_CONTAINER}" 2>/dev/null || true
    log_info "容器已停止"
}

# 删除容器
remove_container() {
    log_info "删除容器 ${OPENCLAW_DEV_CONTAINER}..."
    docker rm -f "${OPENCLAW_DEV_CONTAINER}" 2>/dev/null || true
    log_info "容器已删除"
}

# 进入运行中的容器
enter_container() {
    if ! docker ps --format '{{.Names}}' | grep -q "^${OPENCLAW_DEV_CONTAINER}$"; then
        log_error "容器 ${OPENCLAW_DEV_CONTAINER} 未运行"
        exit 1
    fi
    docker exec -it "${OPENCLAW_DEV_CONTAINER}" bash
}

# 在容器中执行命令
exec_in_container() {
    if ! docker ps --format '{{.Names}}' | grep -q "^${OPENCLAW_DEV_CONTAINER}$"; then
        log_error "容器 ${OPENCLAW_DEV_CONTAINER} 未运行"
        exit 1
    fi
    docker exec "${OPENCLAW_DEV_CONTAINER}" "$@"
}

# 查看容器状态
status() {
    log_info "容器状态:"
    docker ps -a --filter "name=${OPENCLAW_DEV_CONTAINER}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

    log_info "\n镜像信息:"
    docker images "${OPENCLAW_DEV_IMAGE}" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"

    log_info "\n配置信息:"
    echo "  镜像: ${OPENCLAW_DEV_IMAGE}"
    echo "  容器: ${OPENCLAW_DEV_CONTAINER}"
    echo "  项目目录: ${OPENCLAW_PROJECT_DIR}"
    echo "  配置目录: ${OPENCLAW_CONFIG_DIR}"
    echo "  网关端口: ${OPENCLAW_GATEWAY_PORT}"
    echo "  桥接端口: ${OPENCLAW_BRIDGE_PORT}"
}

# 重建镜像
rebuild() {
    log_info "重新构建镜像..."
    remove_container 2>/dev/null || true
    docker rmi "${OPENCLAW_DEV_IMAGE}" 2>/dev/null || true
    build_image
    log_info "重建完成，使用 './sandbox/dev-sandbox.sh start' 启动"
}

# 查看日志
logs() {
    if ! docker ps -a --format '{{.Names}}' | grep -q "^${OPENCLAW_DEV_CONTAINER}$"; then
        log_error "容器 ${OPENCLAW_DEV_CONTAINER} 不存在"
        exit 1
    fi
    docker logs "$@" "${OPENCLAW_DEV_CONTAINER}"
}

# 初始化配置文件
init_config() {
    local local_config="${PROJECT_ROOT}/sandbox/.dev-sandbox.env.local"
    if [[ -f "$local_config" ]]; then
        log_warn "本地配置文件已存在: $local_config"
        return
    fi

    log_info "创建本地配置文件: $local_config"
    cat > "$local_config" << 'EOF'
# OpenClaw 开发沙盒本地配置
# 此文件不会被提交到 git，可安全存放个人配置

# 自定义容器名称（避免与其他开发者冲突）
# OPENCLAW_DEV_CONTAINER=openclaw-dev-$(whoami)

# 自定义端口（避免端口冲突）
# OPENCLAW_GATEWAY_PORT=28789
# OPENCLAW_BRIDGE_PORT=28790

# 资源限制
# OPENCLAW_DOCKER_EXTRA_ARGS="--memory=8g --cpus=4"
EOF
    log_info "配置文件创建完成，请编辑: $local_config"
}

# 显示帮助
show_help() {
    cat << 'HELP_EOF'
OpenClaw Docker 开发沙盒管理脚本

用法:
    ./sandbox/dev-sandbox.sh [命令] [选项]

命令:
    start       启动开发沙盒容器（如果不存在则创建）
    stop        停止运行中的容器
    restart     重启容器
    rm          删除容器
    rebuild     重建镜像并清理旧容器
    enter       进入运行中的容器
    status      查看容器和镜像状态
    exec        在容器中执行命令
    build       仅构建镜像，不启动容器
    logs        查看容器日志
    init        初始化本地配置文件
    help        显示此帮助信息

配置文件:
    sandbox/.dev-sandbox.env         默认配置（可提交到 git）
    sandbox/.dev-sandbox.env.local   本地覆盖配置（不提交到 git）

环境变量:
    OPENCLAW_DEV_IMAGE       镜像名称
    OPENCLAW_DEV_CONTAINER   容器名称
    OPENCLAW_GATEWAY_PORT    网关端口
    OPENCLAW_BRIDGE_PORT     桥接端口
    OPENCLAW_PROJECT_DIR     项目目录
    OPENCLAW_CONFIG_DIR      配置目录
    OPENCLAW_DOCKER_EXTRA_ARGS 额外的 Docker 参数

快速开始:
    # 1. 初始化本地配置（可选）
    ./sandbox/dev-sandbox.sh init

    # 2. 启动开发环境
    ./sandbox/dev-sandbox.sh start

    # 3. 在沙盒内开发
    pnpm install
    pnpm dev

    # 4. 停止和清理
    ./sandbox/dev-sandbox.sh stop
    ./sandbox/dev-sandbox.sh rm

HELP_EOF
}

# 主函数
main() {
    # 加载配置
    load_config

    local cmd="${1:-start}"

    case "$cmd" in
        start)
            check_docker
            check_dockerfile
            build_image
            start_container
            ;;
        stop)
            stop_container
            ;;
        restart)
            stop_container
            sleep 1
            start_container
            ;;
        rm|remove)
            remove_container
            ;;
        rebuild)
            check_docker
            check_dockerfile
            rebuild
            ;;
        enter)
            enter_container
            ;;
        status)
            status
            ;;
        exec)
            shift
            exec_in_container "$@"
            ;;
        build)
            check_docker
            check_dockerfile
            build_image
            log_info "镜像构建完成: ${OPENCLAW_DEV_IMAGE}"
            ;;
        logs)
            shift
            logs "$@"
            ;;
        init)
            init_config
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "未知命令: $cmd"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
