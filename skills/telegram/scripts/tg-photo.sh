#!/usr/bin/env bash
# Usage: tg-photo.sh <file_id>
# Downloads a Telegram photo to /tmp/tg_<file_id_short>.jpg and prints the path.
set -euo pipefail

FILE_ID="${1:?Usage: tg-photo.sh <file_id>}"
API="https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}"

FILE_PATH=$(curl -sf "${API}/getFile?file_id=${FILE_ID}" | jq -r '.result.file_path')

if [[ -z "$FILE_PATH" || "$FILE_PATH" == "null" ]]; then
  echo "Error: could not resolve file_id to a path" >&2
  exit 1
fi

EXT="${FILE_PATH##*.}"
HASH=$(echo -n "$FILE_ID" | md5 | cut -c1-8)
OUT="/tmp/tg_${HASH}.${EXT}"

curl -sf "https://api.telegram.org/file/bot${TELEGRAM_BOT_TOKEN}/${FILE_PATH}" -o "$OUT"
echo "$OUT"
