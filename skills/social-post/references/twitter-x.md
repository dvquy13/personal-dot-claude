# Twitter / X Platform Reference

## Format Constraints

- **Single tweet**: 280 characters max
- **URL rule**: All URLs count as exactly 23 characters regardless of actual length (auto-shortened via t.co)
- **Emoji rule**: Each emoji counts as 2 characters
- **Threads**: Reply-chain format; each reply is its own 280-char tweet
- **Hashtags**: 1–2 max. More than 2–3 looks spammy and can reduce reach.
- **Images**: 1200×675px; JPG or PNG; appear inline in feed

## Algorithm Notes (2025–2026)

X now **actively boosts external article links**. This is a reversal from 2018–2024. Linking out to a full article (blog post, Dev.to, etc.) is no longer penalized — it's encouraged. Post your best material on a permanent platform first, then link from X.

## Thread Structure for a Technical Tool Launch

- **Tweet 1** (hook + link): Specific problem or striking fact + link to the blog post. This is the most important tweet — it must standalone.
- **Tweet 2**: The problem in concrete terms. What was actually broken or annoying?
- **Tweet 3**: The solution. What does the tool do and how does it work at a high level?
- **Tweet 4**: The key technical insight or the thing that surprised you. The "aha" that makes engineers lean in.
- **Tweet 5** (CTA): GitHub link + invitation for feedback or questions.

Limit to 3–5 tweets. Longer threads lose readers fast.

## Anti-Patterns

- More than 5 tweets in a thread for a launch post
- More than 2–3 hashtags
- Asking followers to retweet (looks desperate, can get you shadowbanned)
- Threads with no link to the full article (threads disappear in 48h; articles compound)
- A standalone link tweet with no context (write the hook, then add the link)

## Character Count Guidance

When drafting, account for:
- URLs: 23 chars each
- Line breaks: count as characters
- Emojis: 2 chars each

Always show the char count per tweet so the user can see if they're within limit.

## Output Checklist

- [ ] Tweet 1 hooks in ≤280 chars and includes the blog post link
- [ ] 3–5 tweets total
- [ ] Each tweet stands alone (someone reading only tweet 3 should still get value)
- [ ] 1–2 hashtags max, appended to the final tweet
- [ ] Char count shown for each tweet
- [ ] No requests to RT or follow
