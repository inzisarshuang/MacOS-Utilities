#!/bin/bash
# heic2jpg.sh - 把 HEIC/HEIF 转换为 JPG
# 使用方法：
#   bash heic2jpg.sh <文件路径或文件夹路径>
#   bash heic2jpg.sh <文件路径或文件夹路径> --delete-original

DELETE_ORIGINAL=false

if [ "$2" = "--delete-original" ]; then
    DELETE_ORIGINAL=true
fi

convert_file() {
    local infile="$1"
    local outfile="${infile%.*}.jpg"

    echo "转换: $infile -> $outfile"

    if sips -s format jpeg "$infile" --out "$outfile" >/dev/null; then
        if [ "$DELETE_ORIGINAL" = true ] && [ -f "$outfile" ]; then
            rm "$infile"
            echo "已删除原文件: $infile"
        fi
    else
        echo "错误: 转换失败，保留原文件: $infile"
        return 1
    fi
}

convert_folder() {
    local folder="$1"
    echo "扫描文件夹: $folder"

    find "$folder" -type f \( -iname "*.heic" -o -iname "*.heif" \) | while read -r file; do
        convert_file "$file"
    done
}

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "用法: $0 <文件路径 或 文件夹路径> [--delete-original]"
    exit 1
fi

target="$1"

if [ $# -eq 2 ] && [ "$2" != "--delete-original" ]; then
    echo "错误: 未知参数 $2"
    echo "可用参数: --delete-original"
    exit 1
fi

if [ -f "$target" ]; then
    # 如果是单个文件
    ext="${target##*.}"
    ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

    if [[ "$ext_lower" == "heic" || "$ext_lower" == "heif" ]]; then
        convert_file "$target"
    else
        echo "错误: 文件不是 HEIC/HEIF 格式"
        exit 1
    fi
elif [ -d "$target" ]; then
    # 如果是文件夹
    convert_folder "$target"
else
    echo "错误: $target 不是有效的文件或文件夹"
    exit 1
fi

echo "✅ 完成！"
