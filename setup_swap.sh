#!/bin/bash
# 全自动创建Swap脚本（支持自定义大小）
SWAPFILE="/swapfile"

# 自检并获取root权限
if [ $EUID -ne 0 ]; then
    echo "正在自动获取root权限..."
    exec sudo "\$0" "$@"  # 关键！自动重新以sudo执行脚本
fi

# 交互输入Swap大小
read -p "请输入Swap大小（示例：2G/4096M）: " SWAP_SIZE
if [[ ! $SWAP_SIZE =~ ^[0-9]+[GM]$ ]]; then
    echo "错误：请输入类似4G或4096M的格式"
    exit 1
fi

# 计算单位转换（支持G/M）
UNIT=${SWAP_SIZE: -1}
VALUE=${SWAP_SIZE%?}
if [ "$UNIT" == "G" ]; then
    COUNT=$(($VALUE*1024))   # 1G=1024个1M块
else
    COUNT=$VALUE            # 直接使用M单位
fi

# 替换现有swap（自动处理）
if [ -f $SWAPFILE ]; then
    echo "检测到旧swap文件，自动移除..."
    swapoff $SWAPFILE 2>/dev/null
    rm -f $SWAPFILE
fi

# 创建交换文件（带进度条）
echo "正在创建${SWAP_SIZE}B交换文件..."
if ! dd if=/dev/zero of=$SWAPFILE bs=1M count=$COUNT status=progress ; then
    echo "交换文件创建失败！请检查磁盘空间"
    exit 1
fi

# 配置交换分区
chmod 600 $SWAPFILE
mkswap $SWAPFILE >/dev/null
swapon $SWAPFILE

# 设置内存阈值（70%启用swap）
echo "$SWAPFILE swap swap defaults 0 0" >> /etc/fstab
echo "vm.swappiness=30" >> /etc/sysctl.conf
sysctl -p >/dev/null

# 完成提示
echo -e "\n✅ 配置完成！"
free -h | grep -E 'Mem|Swap'
echo "Swap触发阈值：物理内存使用超过70%时启用（vm.swappiness=30）"
