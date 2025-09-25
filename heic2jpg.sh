#!/bin/bash
# heic2jpg.sh - 把当前文件夹下所有文件或者某个指定文件的 HEIC/HEIF 转换为 JPG
# 使用方法：
#   bash heic2jpg.sh <文件路径> or <文件夹路径>

convert_file() {
    local infile="$1"
    local outfile="${infile%.*}.jpg"
    echo "转换: $infile -> $outfile"
    sips -s format jpeg "$infile" --out "$outfile" >/dev/null
}

convert_folder() {
    local folder="$1"
    echo "扫描文件夹: $folder"
    find "$folder" -type f \( -iname "*.heic" -o -iname "*.heif" \) | while read -r file; do
        convert_file "$file"
    done
}

if [ $# -ne 1 ]; then
    echo "用法: $0 <文件路径 或 文件夹路径>"
    exit 1
fi

target="$1"

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
