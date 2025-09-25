#!/bin/bash
# mount_ntfs.sh - 自动检测并挂载 NTFS 分区为读写
# 使用方法：
#   bash mount_ntfs.sh 

set -e

# 挂载点
MOUNTPOINT="/Volumes/NTFS"
# 确认 ntfs-3g 路径（brew 安装可能在 /opt/homebrew/bin/）
NTFS3G=$(which ntfs-3g || echo "/usr/local/bin/ntfs-3g")

echo "🔎 正在查找 NTFS 分区..."
# 查找第一个 Windows_NTFS 分区
DISK_ID=$(diskutil list | awk '/Microsoft Basic Data|Windows_NTFS/ {print $NF; exit}')

if [[ -z "$DISK_ID" ]]; then
    echo "❌ 未找到 NTFS 分区，请检查硬盘是否插入"
    exit 1
fi

echo "✅ 找到 NTFS 分区: $DISK_ID"

# 卸载系统自动挂载的只读卷
echo "🔧 卸载系统只读挂载..."terminal integrated font family
diskutil unmount /dev/$DISK_ID || true

# 创建挂载点目录
sudo mkdir -p "$MOUNTPOINT"

# 用 ntfs-3g 挂载为读写
echo "🚀 使用 ntfs-3g 挂载到 $MOUNTPOINT"
sudo $NTFS3G /dev/$DISK_ID $MOUNTPOINT -o local -o allow_other -o auto_xattr -o auto_cache

echo "🎉 挂载完成：$MOUNTPOINT"
