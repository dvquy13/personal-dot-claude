# Dev.to Platform Reference

## What Dev.to Is (and Isn't)

Dev.to is not a promo channel — it's a publishing platform. A Dev.to post for a blog post is a **full article republication**, adapted for Dev.to's audience and conventions. The output should be a complete, standalone article that happens to also point to the original.

Dev.to articles rank on Google for months or years. Write for longevity, not just the day-of launch.

## Format Constraints

- **Length**: 2,000–2,500 words is the sweet spot for technical posts
- **Tags**: Minimum 4–5 tags; choose searchable ones (see below)
- **Images**: Aim for 1 image per 300–400 words; articles with 10+ images perform better
- **Code**: Use fenced Markdown code blocks (``` language); avoid screenshots of code when possible
- **Cover image**: Set one explicitly. If omitted, Dev.to auto-picks the first image.
- **Editor**: Use Markdown mode, not the visual editor

## Frontmatter (YAML at top of article)

```yaml
---
title: [Article title]
published: true
description: [1–2 sentence summary for SEO and social previews]
tags: claudeai, devtools, opensource, ai, productivity
cover_image: [URL or leave blank to prompt user to upload]
---
```

## Content Best Practices

- **Personal story first**: Open with a specific moment or experience that created the problem. Not "Many developers face..." — "I was three hours into a debugging session when..."
- **Show failure before success**: What didn't work, and why. This is a differentiator from AI-generated content.
- **Show real code**: Actual implementation details, even messy ones. Theory without code reads hollow on Dev.to.
- **Explain the why**: Don't just describe what you built — explain the decisions. Why this approach and not that one?
- **Include failure modes**: A "What Can Go Wrong" or "Limitations" section. AI-generated posts skip this; human-written posts don't.

## Adapting a Blog Post for Dev.to

**First: ask about the goal.** Full republication maximizes Dev.to engagement (readers stay on-platform). A teaser drives traffic to the original blog. These are different strategies — don't assume.

- **Blog traffic goal** → write a short teaser (~250 words): problem + what you built + one key insight + explicit CTA link to the blog. Set `canonical_url` in frontmatter.
- **Dev.to engagement goal** → full republication with expanded technical sections (see below).

When doing a full republication:

1. **Keep the original structure** but expand technical sections with more implementation detail
2. **Add a Dev.to-specific intro** (1 paragraph) that addresses the Dev.to developer audience directly
3. **Convert any Quarto-specific syntax** (callouts, footnotes) to plain Markdown
4. **Add code snippets** if the original post references code without showing it — only include code you can verify is accurate; don't invent CLI commands or API details
5. **Canonical URL**: Add `canonical_url: [original blog URL]` to frontmatter so search engines attribute the original
6. **Cross-post note** at the bottom: "Originally published at [your blog]" is expected and accepted

## Tag Strategy

Pick from these for an AI developer tools post:
- `claudeai` or `claude`
- `devtools`
- `opensource`
- `ai` or `llm`
- `productivity`
- `python` (if code is Python)
- `cli` (if it's a CLI tool)

Use 4–5 tags. More than 4 officially supported but search weighting drops off.

## Anti-Patterns

- Posting a promotional summary ("Check out my tool qrec — here's what it does") instead of a full article
- AI-sounding prose (theatrical pauses, dramatic fragments, generic insights)
- No code or implementation detail
- Skipping the failure/limitation section
- Ignoring the canonical URL — this matters for SEO

## Output Checklist

- [ ] YAML frontmatter with title, description, tags, canonical_url
- [ ] 2,000–2,500 words
- [ ] Opens with personal story or specific moment
- [ ] Includes failure/what-didn't-work before the solution
- [ ] At least one code snippet or technical implementation detail
- [ ] Limitations or caveats section present
- [ ] 4–5 tags chosen
- [ ] Cover image recommendation included
- [ ] "Originally published at" note at the bottom
