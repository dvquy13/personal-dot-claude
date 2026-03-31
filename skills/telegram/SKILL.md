---
name: telegram
description: >
  Interact with Telegram: send messages, read chat history, search messages,
  download images or files. Use when the user mentions Telegram, wants to check
  messages, send a message to a chat, or interact with a Telegram bot conversation.
---

# Telegram via Bot API

Use `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID` from the environment for all requests.
Base URL: `https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN`

Always use `jq` to parse responses cleanly.

---

## Send a message

```bash
curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
  -H "Content-Type: application/json" \
  -d "{\"chat_id\": \"$TELEGRAM_CHAT_ID\", \"text\": \"hello\", \"parse_mode\": \"MarkdownV2\"}"
```

## Read recent messages (getUpdates)

Bot API `getUpdates` only returns messages received *after* the bot last polled.
Use `offset`, `limit`, and `allowed_updates` to control what you get.

```bash
curl -s "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/getUpdates?limit=20" | jq '.result[] | {id: .update_id, text: .message.text, from: .message.from.username, date: .message.date}'
```

To fetch newer messages only (acknowledge processed ones):
```bash
curl -s "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/getUpdates?offset=<last_update_id+1>&limit=50"
```

## Get chat info

```bash
curl -s "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/getChat?chat_id=$TELEGRAM_CHAT_ID" | jq .
```

## Download a photo

Use the bundled script — it resolves the file_id to a path and downloads in one step:

```bash
${CLAUDE_SKILL_DIR}/scripts/tg-photo.sh <file_id>
# prints the local path, e.g. /tmp/tg_a1b2c3d4.jpg
```

For non-photo files (documents, etc.), do it manually:

Step 1 — resolve file path:
```bash
curl -s "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/getFile?file_id=<FILE_ID>" | jq -r '.result.file_path'
```

Step 2 — download:
```bash
curl -s "https://api.telegram.org/file/bot$TELEGRAM_BOT_TOKEN/<file_path>" -o /tmp/output_filename
```

## Send a photo

```bash
curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendPhoto" \
  -F "chat_id=$TELEGRAM_CHAT_ID" \
  -F "photo=@/path/to/image.png" \
  -F "caption=optional caption"
```

## Search messages

The Bot API does not support full-text search. Workaround: fetch a batch via
`getUpdates`, pipe through `jq` to filter by keyword:

```bash
curl -s "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/getUpdates?limit=100" \
  | jq '.result[] | select(.message.text | test("keyword"; "i")) | {text: .message.text, date: .message.date}'
```

For deeper history search, use `forwardMessages` or note that Bot API only surfaces
messages the bot has *seen* (received while running). Older history requires MTProto.

---

## Reference

- Bot API docs: https://core.telegram.org/bots/api
- All methods: https://core.telegram.org/bots/api#available-methods

## Notes

- **Bot API limitation**: only sees messages sent *after* the bot was started or last polled.
  If history is missing, the bot may not have been running when messages were sent.
- For full history/search across all time, recommend `chaindead/telegram-mcp` (MTProto user account).
- `TELEGRAM_CHAT_ID` can be a numeric ID (e.g. `-100123456789` for groups) or `@username` for public channels.
- Use `parse_mode: "MarkdownV2"` (preferred) or `"HTML"` for formatted messages. Legacy `"Markdown"` is deprecated. In MarkdownV2, special chars like `.`, `!`, `-`, `(`, `)` must be escaped with `\`.
