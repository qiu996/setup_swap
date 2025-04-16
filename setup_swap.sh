#!/bin/bash
SWAPFILE="/swapfile"

# 检查是否在TTY终端中运行
if [ ! -t 0 ] && [ -z "$SWAP_SIZE" ]; then
    echo "错误：请下载脚本后运行（不要用curl管道执行），以便输入参数："
    echo "  wget https://raw.githubusercontent.com/qiu996/setup_swap/main/setup_swap.sh"
    echo "  sudo bash setup_swap.sh"
    exit 1
fi

# 获取root权限
if [ $EUID -ne 0 ]; then
    exec sudo "\$0" "$@"
fi

# 用户输入处理（兼容管道执行）
if [ -z "$SWAP_SIZE" ]; then
    read -p "请输入Swap大小（示例：2G/4096M）: " SWAP_SIZE
fi

# 格式校验
if [[ ! $SWAP_SIZE =~ ^[0-9]+[GM]$ ]]; then
    echo "错误：格式错误，请使用数字+G/M（如4G或4096M）"
    exit 1
fi

# 后续流程保持不变（单位转换、创建文件等）...
