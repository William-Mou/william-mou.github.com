#!/bin/bash
# 用法: ./rename.sh <資料夾名> <新檔名（不含 .md）>
# 範例: ./rename.sh isc23-Europe ISC23-Europe

if [ "$#" -ne 2 ]; then
    echo "用法: $0 <資料夾名> <新檔名>"
    exit 1
fi

DIR="$1"
NEWNAME="$2"

if [ ! -d "$DIR" ]; then
    echo "❌ 找不到資料夾: $DIR"
    exit 1
fi

MD_FILE=$(find "$DIR" -maxdepth 1 -type f -name "*.md" | head -n 1)
if [ -z "$MD_FILE" ]; then
    echo "❌ 沒有找到 .md 檔案"
    exit 1
fi

NEW_FILE="${DIR}/${NEWNAME}.md"
mv "$MD_FILE" "$NEW_FILE"

echo "🔧 處理 Markdown 圖片連結..."

# 1️⃣ 有 **註解** 的情況
perl -0777 -i -pe 's/!\[[^\]]*\]\(files\/([^)]+)\)\s*\n\*\*(.*?)\*\*/![\2]\(\/img\/'"${NEWNAME}"'_files\/\1\)/gs' "$NEW_FILE"

# 2️⃣ 無註解的情況
perl -0777 -i -pe 's/!\[[^\]]*\]\(files\/([^)]+)\)/![]\(\/img\/'"${NEWNAME}"'_files\/\1\)/g' "$NEW_FILE"

# 3️⃣ 轉換 YAML header（支援兩種格式：有 Name: 的舊格式、或 Anytype 的 Creation date: 格式）
if grep -q '^Name:' "$NEW_FILE"; then
    TITLE=$(grep '^Name:' "$NEW_FILE" | sed 's/Name:[[:space:]]*//' | sed 's/[[:space:]]*$//')
    DATE=$(grep 'Creation date:' "$NEW_FILE" | sed -E 's/.*"([0-9-]+)T([0-9:]+)Z".*/\1 \2/')
elif grep -q 'Creation date:' "$NEW_FILE"; then
    # Anytype 匯出沒有 Name:，標題在 YAML 後第一個「# 標題」行
    TITLE=$(awk '/^---$/ { n++; next } n==2 && /^# / { sub(/^# +/, ""); gsub(/[[:space:]]+$/, ""); print; exit }' "$NEW_FILE")
    DATE=$(grep 'Creation date:' "$NEW_FILE" | sed -E 's/.*"([0-9-]+)T([0-9:]+)Z".*/\1 \2/')
fi

if [ -n "$DATE" ]; then

    # 尋找第一張圖片作為縮圖
    THUMB_FILE=$(find "$DIR/files" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | sort | head -n 1)
    if [ -n "$THUMB_FILE" ]; then
        THUMB_BASENAME=$(basename "$THUMB_FILE")
        THUMB_PATH="/img/${NEWNAME}_files/${THUMB_BASENAME}"
    else
        THUMB_PATH=""
    fi

    awk -v title="$TITLE" -v date="$DATE" -v thumb="$THUMB_PATH" '
    BEGIN {in_header=0}
    /^---$/ {
        if (++in_header == 1) {
            print "---"
            print "title: " title
            print "date: " date
            print "tags:"
            print "categories:"
            print "thumbnail: " thumb
            print "---"
            skip=1
        } else if (in_header == 2) {
            skip=0
            next
        }
    }
    skip==0 {print}
    ' "$NEW_FILE" > "$NEW_FILE.tmp" && mv "$NEW_FILE.tmp" "$NEW_FILE"
fi

# 4️⃣ 刪除 YAML header 後第一個 Markdown 標題 (# ...)
awk '
BEGIN {in_yaml=0; done_header=0}
{
    if ($0 == "---" && in_yaml == 0) {
        in_yaml = 1
    } else if ($0 == "---" && in_yaml == 1 && done_header == 0) {
        in_yaml = 0
        done_header = 1
        print $0
        nextline = 1
        next
    }
    if (nextline) {
        if ($0 ~ /^# /) { nextline = 0; next }
        nextline = 0
    }
    print
}' "$NEW_FILE" > "$NEW_FILE.tmp" && mv "$NEW_FILE.tmp" "$NEW_FILE"

# 5️⃣ 改名圖片資料夾
if [ -d "$DIR/files" ]; then
    mv "$DIR/files" "$DIR/${NEWNAME}_files"
fi

# 6️⃣ 搬移到最終路徑
POSTS_DIR="../source/_posts"
IMG_DIR="../source/img"

mkdir -p "$POSTS_DIR" "$IMG_DIR"

mv "$NEW_FILE" "$POSTS_DIR/"
if [ -d "$DIR/${NEWNAME}_files" ]; then
    mv "$DIR/${NEWNAME}_files" "$IMG_DIR/"
fi

echo "✅ 完成：$POSTS_DIR/${NEWNAME}.md"
echo "   thumbnail 已設定為: $THUMB_PATH"
