---
name: social-post
description: >
  Craft platform-tailored social media content. Use when the user wants to share
  something on LinkedIn, Twitter/X, Hacker News, or Dev.to — whether it's a
  finished blog post, a raw idea, a story, a lesson learned, or a project update.
  Also use when the user isn't sure whether or where to share something.
  Triggers on: "tweet about this", "should I post this?", "share this idea",
  "write a Show HN", "draft something for LinkedIn", "is this worth posting?",
  "promote my post", "thread for my qrec post".
allowed-tools: Read, Glob
---

# Social Post Skill

Help the user share something on social media — from a finished blog post to a half-formed idea. Each platform has different audience expectations, format constraints, and community norms. This skill encodes those differences and helps decide what's worth sharing, where, and how.

## Step 1: Understand What the User Has

Before anything else, identify the input type:

| Input type | Description | Example |
|------------|-------------|---------|
| **Finished content** | Blog post, article, write-up with a URL or file path | "Share my qrec post" |
| **Raw idea / story** | Unwritten thought, experience, or lesson the user wants to share | "I had an interesting debugging session today" |
| **Vague prompt** | User isn't sure if something is worth sharing or where | "Is this worth posting?" |

- If a file path is provided, read it.
- If the content is already in context, use it.
- If neither, ask the user to describe the idea or story in a few sentences before proceeding.

## Step 2: Assess Whether It's Worth Sharing

For **raw ideas or stories**, before recommending platforms or drafting anything, briefly assess shareability:

- **Does it have a concrete insight or moment?** Vague thoughts ("AI is changing things") don't work. Specific experiences ("I tried X, it failed because Y") do.
- **Is there a reader benefit?** What does someone walk away with — a tool, a reframe, a lesson, a laugh?
- **Is it honest?** Posts that omit failure or pretend certainty read hollow.

If the idea is thin, say so and ask one clarifying question: "What was the moment that made this feel worth sharing?" Don't pad or encourage sharing something that won't land.

If the idea has legs, move to platform assessment.

## Step 3: Platform Fit Assessment

When no platform is specified, evaluate fit and present a short assessment before drafting anything.

**How to assess fit:**

| Signal in the content | Favors |
|-----------------------|--------|
| Deep technical detail, benchmarks, architectural trade-offs, honest limitations | Hacker News |
| Personal narrative, lessons learned, implementation walkthrough, code snippets | Dev.to |
| Career insight, professional angle, leadership lesson, compressible to 1,200 chars | LinkedIn |
| Single striking insight, demo, or story beat that works as a hook; thread-able | Twitter / X |
| Raw idea without a written artifact | Twitter / X or LinkedIn (lower barrier to publish) |
| Project launch or open-source tool | Hacker News (Show HN) + Dev.to + Twitter |

**Assessment format:**

```
--- PLATFORM FIT ASSESSMENT ---

Strong fit: [platform(s)]
  → [why this content lands well there]

Weaker fit: [platform(s)]
  → [what makes it a harder post — too long to compress, wrong tone, missing hook, etc.]

[If raw idea: one sentence on what form the content would take — e.g., "This would be a LinkedIn post, not a Dev.to article — there's not enough implementation detail yet for a full write-up."]

Proceed with [recommendation], or name the platforms you want.
```

Keep it to 6–8 lines. Be honest. Don't recommend a platform just to be comprehensive.

If the user specified a platform explicitly, skip this step and go straight to drafting.

## Step 4: Draft the Content

Read the relevant reference file(s) before drafting:

| Platform | Reference file |
|----------|---------------|
| LinkedIn | `~/.claude/skills/social-post/references/linkedin.md` |
| Twitter / X | `~/.claude/skills/social-post/references/twitter-x.md` |
| Hacker News | `~/.claude/skills/social-post/references/hacker-news.md` |
| Dev.to | `~/.claude/skills/social-post/references/dev-to.md` |

For **finished content**: adapt the existing material for the platform.
For **raw ideas / stories**: write original platform-native content from what the user described — don't fabricate details, but help shape the idea into the form that works for that platform.

Never invent facts, product names, statistics, or quotes.

## Output Format by Platform

### LinkedIn
```
--- LINKEDIN POST ---
[full post draft, 900–1,500 chars]

--- FIRST COMMENT (post this immediately after publishing) ---
[link + brief context, or omit section if no link exists]

--- HASHTAGS ---
#tag1 #tag2 #tag3

Character count: [N]
```

### X (formerly Twitter)
```
--- X THREAD ---

Post 1/N ([char count]/280):
[text]

Post 2/N ([char count]/280):
[text]

Post N/N ([char count]/280):
[text]
```

### Hacker News
```
--- TITLE OPTIONS ---

Option 1: [title] ([char count]/80)
Option 2: [title] ([char count]/80)
Option 3: [title] ([char count]/80)

--- FIRST COMMENT (post this as your first reply after submitting) ---
[2–3 sentences: what it does, why it matters, try-it link]

--- SUBMISSION NOTE ---
[timing reminder: Tue–Thu 8–11 AM US Eastern]
```

### Dev.to
```
--- DEV.TO ARTICLE ---

Title: [title]
Tags: [tag1, tag2, tag3, tag4, tag5]
Cover image: [description of what to use]

---

[full article Markdown]
```

## Writing Voice

DvQ's voice: conversational first-person, grounded in lived experience, honest about failures before wins. Social posts should sound like the same person talking — not an AI writing a summary of what a person might say.

Do not use:
- Short punchy fragments for effect ("It worked." / "So I built one.")
- Hype language or excessive punctuation
- Generic advice that any AI could generate
- Invented facts or statistics
- Hedges that distance the author from their own experience ("One might argue...")
- Generic CTAs ("Feel free to check it out and let me know your thoughts!")
- The standard promotional formula: problem setup → tool description → key feature → CTA. This reads as a template, not a person.

Mirror the tone of the source material. Candid and technical source → candid and technical post.

## DvQ Preferences

These apply by default unless the user says otherwise:

**Blog traffic goal**: DvQ has a personal blog and wants social posts to drive traffic there. For Dev.to, default to a short teaser (~250 words) + CTA link, not a full republication. Ask about this goal if unclear.

**Demo videos**: Do not include demo videos in social posts by default. Videos are a reward for clicking through to the blog, not a lure. Only include if the user explicitly asks.

**LinkedIn tone**: DvQ's LinkedIn audience is professional but the preferred tone is casual and personal — more "here's something I built" than "here's the problem I solved and the solution I engineered." Avoid the standard launch post formula. When in doubt, write fewer words, not more.

**HN optional caveat**: Do not include the "honest caveat" in the HN first comment by default. It undersells the tool before anyone has tried it. Only include if the user specifically wants to lead with a known limitation.

**X (formerly Twitter)**: Use `utm_source=x` (not `twitter`) in UTM links. Name output files `_x.md`. Use "Post" not "Tweet" in thread labels.
