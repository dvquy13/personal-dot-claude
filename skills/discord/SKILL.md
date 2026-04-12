---
name: discord
description: >
  Interact with Discord: send messages to channels, post to webhooks, list
  channels, read recent messages. Use ONLY when the user mentions Discord,
  wants to send a message to a Discord channel, or post a Discord notification.
  Do NOT use for Telegram, Slack, or other platforms.
---

# Discord

Two mechanisms are available depending on the target:

| Mechanism | When to use | Secret |
|-----------|-------------|--------|
| Webhook | Quick post to the Claude Code channel | `DISCORD_CLAUDE_CODE_WEBHOOK_URL` |
| Bot API | Any other channel in the Icewrack server | `DISCORD_CM_BOT_TOKEN` + `DISCORD_ICEWRACK_SERVER_ID` |

Always use `jq` to parse responses cleanly.

---

## Send via webhook (Claude Code channel)

No auth header needed — the token is baked into the URL.

```bash
curl -s -X POST "$DISCORD_CLAUDE_CODE_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{"content": "your message here"}'
```

With an embed:
```bash
curl -s -X POST "$DISCORD_CLAUDE_CODE_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "embeds": [{
      "title": "Title here",
      "description": "Body here",
      "color": 5814783
    }]
  }'
```

---

## Send via Bot API (any channel)

Base URL: `https://discord.com/api/v10`
Auth header: `Authorization: Bot $DISCORD_CM_BOT_TOKEN`

### Send a message to a channel
```bash
curl -s -X POST "https://discord.com/api/v10/channels/<CHANNEL_ID>/messages" \
  -H "Authorization: Bot $DISCORD_CM_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content": "your message here"}'
```

### List channels in the Icewrack server
```bash
curl -s "https://discord.com/api/v10/guilds/$DISCORD_ICEWRACK_SERVER_ID/channels" \
  -H "Authorization: Bot $DISCORD_CM_BOT_TOKEN" \
  | jq '.[] | {id, name, type}'
```

### Read recent messages from a channel
```bash
curl -s "https://discord.com/api/v10/channels/<CHANNEL_ID>/messages?limit=20" \
  -H "Authorization: Bot $DISCORD_CM_BOT_TOKEN" \
  | jq '.[] | {id, author: .author.username, content, timestamp}'
```

### Send a message with an embed
```bash
curl -s -X POST "https://discord.com/api/v10/channels/<CHANNEL_ID>/messages" \
  -H "Authorization: Bot $DISCORD_CM_BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "embeds": [{
      "title": "Title",
      "description": "Body",
      "color": 5814783
    }]
  }'
```

---

## Notes

- Channel type `0` = text channel, `2` = voice, `4` = category — filter by `type == 0` for text channels.
- Discord API rate limits: 5 req/5s per channel. Add `| jq .` to debug response errors.
- Webhook posts appear from the webhook's configured name/avatar, not the bot.
- For the Claude Code webhook channel, prefer the webhook path — it's simpler and doesn't need a channel ID.
- Markdown in Discord: `**bold**`, `*italic*`, `\`code\``, `\`\`\`lang\ncodeblock\`\`\``
