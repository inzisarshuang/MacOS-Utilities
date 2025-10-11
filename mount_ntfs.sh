#!/bin/bash
# mount_ntfs.sh - 自动检测并挂载所有 NTFS 分区为读写
# 用法：
#   bash mount_ntfs.sh

set -e

# 挂载点前缀（多盘会自动在后面加编号）
MOUNTPOINT_BASE="/Volumes/NTFS"
# 确认 ntfs-3g 路径（brew 安装可能在 /opt/homebrew/bin/）
NTFS3G=$(which ntfs-3g || echo "/usr/local/bin/ntfs-3g")

if [[ ! -x "$NTFS3G" ]]; then
  echo "❌ 未找到可执行的 ntfs-3g：$NTFS3G"
  echo "   请通过 brew 安装：brew install ntfs-3g"
  exit 1
fi

echo "🔎 正在查找 NTFS 分区..."

# —— 兼容 Bash 3.2：用 while-read 代替 mapfile ——
DISK_IDS=()
diskutil list | awk '/Microsoft Basic Data|Windows_NTFS/ {print $NF}' | while read -r id; do
  DISK_IDS+=("$id")
done

# Bash 3.2 的子进程问题：上面 while 管道在子 Shell 中运行，数组在父进程不可见；
# 所以改为用命令替换一次性读入，再逐项追加。
if [[ ${#DISK_IDS[@]} -eq 0 ]]; then
  OUTPUT="$(diskutil list | awk '/Microsoft Basic Data|Windows_NTFS/ {print $NF}')"
  while read -r id; do
    [[ -n "$id" ]] && DISK_IDS+=("$id")
  done <<< "$OUTPUT"
fi
# —— 以上为最小兼容处理 ——

if [[ ${#DISK_IDS[@]} -eq 0 ]]; then
    echo "❌ 未找到 NTFS 分区，请检查硬盘是否插入"
    exit 1
fi

echo "✅ 找到 ${#DISK_IDS[@]} 个 NTFS 分区: ${DISK_IDS[*]}"

idx=1
for DISK_ID in "${DISK_IDS[@]}"; do
  echo "———"
  echo "🔧 处理分区：/dev/$DISK_ID"

  # 卸载系统自动挂载的只读卷（若已挂载）
  echo "⏏️  卸载系统只读挂载（若存在）..."
  diskutil unmount "/dev/$DISK_ID" || true

  # 为每个分区创建独立挂载点（/Volumes/NTFS, /Volumes/NTFS-2, /Volumes/NTFS-3 …）
  if [[ $idx -eq 1 ]]; then
    MOUNTPOINT="$MOUNTPOINT_BASE"
  else
    MOUNTPOINT="${MOUNTPOINT_BASE}-${idx}"
  fi
  sudo mkdir -p "$MOUNTPOINT"

  # 使用 ntfs-3g 挂载为读写
  echo "🚀 使用 ntfs-3g 挂载到 $MOUNTPOINT"
  sudo "$NTFS3G" "/dev/$DISK_ID" "$MOUNTPOINT" -o local -o allow_other -o auto_xattr -o auto_cache

  echo "🎉 已挂载：$MOUNTPOINT"
  ((idx++))
done

echo "✅ 全部完成！"
