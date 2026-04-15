#!/bin/bash

# Stock Socratic 一键更新脚本 (Mac/Linux)
# 用法: ./update.sh [安装目录]

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Stock Socratic 更新脚本 ===${NC}"
echo ""

# GitHub 仓库地址
REPO_URL="https://github.com/fatliuwei/stock-socratic.git"
RAW_URL="https://raw.githubusercontent.com/{your-username}/stock-socratic/main"

# 检测平台并确定安装目录
declare -A PLATFORM_DIRS=(
    ["WorkBuddy"]="$HOME/.workbuddy/skills/stock-socratic"
    ["ClaudeCode"]=".claude/skills/stock-socratic"
    ["OpenCode"]=".opencodeskills/stock-socratic"
    ["OpenClaw"]=".openclaw/skills/stock-socratic"
    ["Trae"]=".trae/skills/stock-socratic"
)

INSTALL_DIR="${1:-}"

if [ -z "$INSTALL_DIR" ]; then
    # 自动检测当前目录属于哪个平台
    CURRENT_DIR=$(pwd)
    DETECTED_PLATFORM=""
    
    for PLATFORM in "${!PLATFORM_DIRS[@]}"; do
        if [[ "$CURRENT_DIR" == *"$PLATFORM"* ]]; then
            DETECTED_PLATFORM="$PLATFORM"
            break
        fi
    done
    
    if [ -n "$DETECTED_PLATFORM" ]; then
        INSTALL_DIR="${PLATFORM_DIRS[$DETECTED_PLATFORM]}"
        echo -e "${CYAN}检测到平台: $DETECTED_PLATFORM${NC}"
    else
        # 尝试检测常见的 skills 目录
        for PLATFORM in "${!PLATFORM_DIRS[@]}"; do
            TEST_PATH="${PLATFORM_DIRS[$PLATFORM]}"
            if [ -d "$TEST_PATH" ]; then
                INSTALL_DIR="$TEST_PATH"
                echo -e "${CYAN}检测到安装目录: $TEST_PATH${NC}"
                break
            fi
        done
    fi
fi

if [ -z "$INSTALL_DIR" ] || [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${RED}错误: 无法检测到 Stock Socratic 的安装目录${NC}"
    echo ""
    echo "请手动指定安装目录:"
    echo "  ./update.sh /path/to/stock-socratic"
    echo ""
    echo "或从安装目录运行此脚本"
    exit 1
fi

echo "安装目录: $INSTALL_DIR"
echo ""

# 检查是否为 git 仓库
if [ -d "$INSTALL_DIR/.git" ]; then
    echo -e "${CYAN}检测到 Git 仓库，使用 git pull 更新...${NC}"
    cd "$INSTALL_DIR"
    if git pull origin main; then
        echo -e "${GREEN}✓ 更新成功!${NC}"
    else
        echo -e "${RED}✗ Git 更新失败${NC}"
        echo "尝试使用直接下载方式..."
        USE_DIRECT_DOWNLOAD=true
    fi
else
    USE_DIRECT_DOWNLOAD=true
fi

# 直接下载方式
if [ "$USE_DIRECT_DOWNLOAD" = true ]; then
    echo -e "${CYAN}使用直接下载方式更新...${NC}"
    
    # 创建临时目录
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT
    
    # 下载最新版本
    echo "下载最新版本..."
    ZIP_URL="https://github.com/{your-username}/stock-socratic/archive/refs/heads/main.zip"
    ZIP_PATH="$TEMP_DIR/stock-socratic.zip"
    
    if command -v curl &> /dev/null; then
        curl -L -o "$ZIP_PATH" "$ZIP_URL"
    elif command -v wget &> /dev/null; then
        wget -O "$ZIP_PATH" "$ZIP_URL"
    else
        echo -e "${RED}错误: 需要 curl 或 wget 来下载更新${NC}"
        exit 1
    fi
    
    # 解压
    echo "解压文件..."
    unzip -q "$ZIP_PATH" -d "$TEMP_DIR"
    
    # 复制文件
    EXTRACTED_DIR="$TEMP_DIR/stock-socratic-main"
    echo "更新文件..."
    
    # 备份旧版本
    BACKUP_DIR="${INSTALL_DIR}.backup.$(date +%Y%m%d%H%M%S)"
    cp -r "$INSTALL_DIR" "$BACKUP_DIR"
    echo "已备份旧版本到: $BACKUP_DIR"
    
    # 复制新文件（排除 .git 等）
    rsync -av --exclude='.git' --exclude='.gitignore' --exclude='*.backup.*' "$EXTRACTED_DIR/" "$INSTALL_DIR/" 2>/dev/null || \
    cp -r "$EXTRACTED_DIR"/* "$INSTALL_DIR/" 2>/dev/null || true
    
    echo -e "${GREEN}✓ 更新成功!${NC}"
fi

# 显示版本信息
SKILL_FILE="$INSTALL_DIR/SKILL.md"
if [ -f "$SKILL_FILE" ]; then
    VERSION_LINE=$(grep "version:" "$SKILL_FILE" | head -1)
    if [ -n "$VERSION_LINE" ]; then
        echo ""
        echo -e "${GREEN}当前版本: $VERSION_LINE${NC}"
    fi
fi

echo ""
echo -e "${GREEN}=== 更新完成 ===${NC}"
echo ""
echo "提示: 请重启您的 AI 助手以加载最新版本"
