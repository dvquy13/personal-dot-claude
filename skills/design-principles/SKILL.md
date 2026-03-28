---
name: design-principles
description: >
  Personal UI/UX design principles grounded in CRAP (Contrast, Repetition,
  Alignment, Proximity) and a minimal accent-oriented aesthetic. Invoke when
  designing or reviewing UI — layouts, components, color choices, typography,
  spacing, or interaction patterns. Also use when the user asks "does this look
  right", "how should I design this", or wants a design review.
allowed-tools: Read, Glob, Grep
---

# Personal Design Principles

These principles govern all UI design decisions. They are grounded in the CRAP framework — Contrast, Repetition, Alignment, Proximity — applied through a minimal, accent-oriented aesthetic.

If a project has its own established design system or palette, honor it. These principles fill the gap when it doesn't.

---

## Foundation: CRAP

**Contrast** — Elements that are different must look *very* different, not slightly different. Weak contrast is worse than no contrast — it implies a relationship that isn't there. Apply contrast to create hierarchy: the most important thing on screen should be obviously the most important.

**Repetition** — Repeat visual elements (color, font weight, spacing rhythm, border style) consistently. The accent color is the primary repeated signal — it means "interactive" everywhere it appears. Consistency builds recognition; variation should be intentional, not accidental.

**Alignment** — Nothing is placed arbitrarily. Every element connects to a shared invisible line. A single left axis for all block-level content is the default; introducing a second axis requires deliberate justification.

**Proximity** — Related things are close. Unrelated things are separated. Physical distance implies relationship distance. Use proximity before using borders or backgrounds to group content — if spacing alone communicates the grouping, the border is unnecessary noise.

---

## Color

Default palette: black, white, and one accent color. This is the starting point for every project that doesn't bring its own palette.

- Resist adding a second accent. Most problems that feel like they need a new color are solved by weight, spacing, or opacity instead.
- Semantic colors (green for success, red for error, amber for warning) are status indicators only — never decoration.
- When a project has a multi-color palette, honor it fully. These principles apply when there's no palette defined.

---

## Interaction Model

All interactive elements (nav items, cards, links, tags, secondary buttons, chips) are rendered in neutral black/white at rest. On hover, all visible parts — text, borders, icons — transition to the accent color together.

The exception is **primary call-to-action buttons**: these may carry accent fill pre-applied to draw the eye to the most important action. Use this sparingly — one or two per screen. When accent fill is everywhere, it signals nothing (Repetition and Contrast working against each other).

This model serves CRAP directly:
- **Contrast**: the accent state is visually distinct from rest; the primary CTA is distinct from everything else
- **Repetition**: every hover looks the same — one color, consistent signal
- **Alignment**: interactive affordance doesn't scatter random colors across the layout

---

## Typography

- **Default font for UI chrome** (labels, numbers, nav, buttons, headings): **Google Sans** (available via Google Fonts). Fall back to Inter only if Google Sans is explicitly unavailable.
- If the user specifies a font, use it exactly. Do not substitute silently — if unsure about availability, ask rather than guess.
- Use a humanist or rounded sans-serif for prose reading zones: long-form text, summaries, user-generated content. Example: DM Sans, Inter (from rsms.me/inter).
- Use monospace only for machine-scannable content: IDs, code, timestamps in data rows. Example: Google Sans Code, Roboto Mono.
- Define a single type scale as tokens. Never write raw pixel values — resize the entire UI by editing the scale, not by hunting down individual declarations.

---

## Spacing & Layout

- Generous white space. When in doubt, add more — crowding creates noise that fights Contrast and Proximity.
- One left alignment axis for all block-level elements: headings, cards, search bars, filter rows all share the same left edge. A second left edge is a defect.
- Content has a max-width column (around 900px is comfortable for dense data UIs). Don't let lines run full-viewport on wide screens.
- Group related content through proximity before reaching for borders or background fills. If a border is the only thing separating two groups, ask whether better spacing would do it instead.

---

## Motion

Keep motion purposeful and brief. Transitions communicate state change — they are not decoration.

- Color and opacity transitions: 100–150ms.
- Fill/width transitions (progress bars): 400ms ease.
- Infinite animations (spinners, pulse dots): slow and calm, never frantic.
- No transitions on structural layout properties (width, height of containers).
- No shadows to animate. No bouncing. No attention-seeking.

---

## Token-Based Implementation

When implementing a design in HTML/CSS/JS, all design values must be defined once and referenced everywhere — never scattered as raw literals:

- **CSS custom properties** for all colors, border radii, and spacing variants. Define on `:root`, reference as `var(--name)`. Change one value, everything updates.
- **JS token object** (e.g. `const T = {}`) for any design values consumed in JavaScript (chart colors, canvas draws). Populate by reading CSS vars at runtime: `getComputedStyle(document.documentElement).getPropertyValue('--accent')`. This keeps CSS and JS in sync from a single source.
- **Tailwind config `extend`** if using Tailwind: wire theme colors to CSS vars so utility classes and custom CSS share the same token.

If you find yourself writing the same hex value twice, stop and define it as a token first.

---

## What to Avoid

- **Shadows on cards** — transparency is preferred; elevation is noise in a flat, high-contrast system.
- **Decorative borders** — borders are structural dividers, not decoration. Ask "does this border communicate structure or just fill space?"
- **Accent color creep** — every non-CTA element that gets pre-applied accent dilutes the signal. Audit regularly.
- **Two competing left axes** — always a defect, never intentional.
- **Slight differences** — if two things are meant to be different, make them obviously different (Contrast). Near-matches look like mistakes.
- **Raw font-size values** — always use scale tokens so the system can be resized holistically.
- **Unnecessary color to solve a spacing problem** — proximity and weight almost always work better.
