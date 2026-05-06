---
name: dvq-pptx
description: Generate and edit PPTX presentations with the dvq design system. Hard fork of the pptx skill — Google Slides optimised, Plotly charts, Figtree font, dvq colour tokens baked in.
---

# dvq-pptx

Personal fork of the base pptx skill. Design tokens, chart rules, and Google Slides compatibility are all pre-wired — do not ask the user for these preferences again.

## Quick Reference

| Task | Guide |
|------|-------|
| Read/analyze content | `uv run --python 3.13 --with "markitdown[pptx]" python3.13 -m markitdown presentation.pptx` |
| Edit or create from template | Read [editing.md](editing.md) |
| Create from scratch | Read [pptxgenjs.md](pptxgenjs.md) |
| Generate a chart | Edit and run [scripts/gen_chart.py](scripts/gen_chart.py) |

---

## dvq Design Tokens (Always Apply)

Apply these to **every** presentation. Never use other colors or fonts unless the user explicitly overrides.

```
Background:   #FFFFFF  (slide)       #F8FAFC  (accent boxes / callouts)
Text:         #0F172A  (primary)     #64748B  (muted / secondary)
Accent:       #0062A8  (headings, key phrases, highlights — one accent only)
Border:       #E2E8F0
Font:         Figtree — 700 bold headings, 400 regular body
              Google Slides supports Figtree natively; no substitution needed.
No shadows. No gradients. Minimal borders.
```

**Type scale (LAYOUT_16x9 — 10" × 5.625"):**

| Element | Size | Style |
|---------|------|-------|
| Slide title | 32pt | bold, color accent |
| Section head | 24pt | bold, color primary |
| Body | 14–16pt | regular, primary or muted |
| Caption / meta | 13pt | regular, muted |

**Standard title layout (use on every slide):**
```javascript
// Title box
slide.addText(title, {
  x: 0.5, y: 0.18, w: 9, h: 1.05,
  fontFace: "Figtree", fontSize: 32, bold: true,
  color: "0062A8", align: "left", valign: "middle", margin: 0,
});
// Hairline rule below title
slide.addShape(pres.shapes.RECTANGLE, {
  x: 0.5, y: 1.28, w: 9, h: 0.014,
  fill: { color: "E2E8F0" }, line: { color: "E2E8F0", width: 0 },
});
// Content starts at y: 1.42
```

---

## Charts: Always Use Plotly

**Never use pptxgenjs `addChart`.** Google Slides converts OOXML charts to static images on import, discarding all font and style settings.

Always generate charts as PNG via Plotly + kaleido, then embed with `addImage`.

### Step-by-step

1. Edit `scripts/gen_chart.py` — update `OPTIONS`, `METRICS`, `DATA`, `SLOT_W`, `SLOT_H`, `OUTPUT`
2. Run:
   ```bash
   uv run --python 3.13 --with plotly --with kaleido python3.13 scripts/gen_chart.py
   ```
3. Embed the output PNG in your pptxgenjs script:
   ```javascript
   slide.addImage({ path: "/tmp/chart.png", x: 4.85, y: 1.42, w: SLOT_W, h: SLOT_H });
   ```

### Aspect ratio rule (critical)

The PNG pixel dimensions must match the slide slot ratio exactly — otherwise Google Slides stretches it:

```
png_height = round(png_width / (slot_w_inches / slot_h_inches))
```

Example: slot 4.8" × 3.9" → `width=700, height=round(700 / (4.8/3.9)) = 569`

`gen_chart.py` calculates this automatically from `SLOT_W` / `SLOT_H`.

### dvq chart style

```python
fig.update_layout(
    barmode="group",
    paper_bgcolor="white",
    plot_bgcolor="white",
    font=dict(family="Figtree, DM Sans, Inter, sans-serif", size=13, color="#64748B"),
    margin=dict(l=10, r=10, t=10, b=10),
    legend=dict(orientation="h", yanchor="bottom", y=-0.28, xanchor="center", x=0.5,
                font=dict(size=12), bgcolor="rgba(0,0,0,0)", borderwidth=0),
    xaxis=dict(showgrid=False, showline=False, zeroline=False),
    yaxis=dict(showgrid=False, showline=False, zeroline=False),
)
# Accent series color: "#0062A8"
# Neutral series color: "#94A3B8"
```

---

## Reading Content

```bash
uv run --python 3.13 --with "markitdown[pptx]" python3.13 -m markitdown presentation.pptx
```

Check for missing content, wrong order, leftover placeholders:
```bash
uv run --python 3.13 --with "markitdown[pptx]" python3.13 -m markitdown output.pptx \
  | grep -iE "xxxx|lorem|ipsum|this.*(page|slide).*layout"
```

---

## Editing Workflow

Read [editing.md](editing.md) for the full template-based editing workflow.

---

## Creating from Scratch

Read [pptxgenjs.md](pptxgenjs.md) for the full pptxgenjs API reference.

Run your script with:
```bash
NODE_PATH=$(npm root -g) node your-deck.js
```

pptxgenjs must be installed globally: `npm install -g pptxgenjs`

---

## Design Principles (dvq)

- **White background always** — no dark slides, no gradient backgrounds
- **One accent color** — #0062A8 only; never add a second accent
- **Dominance** — accent used sparingly so it stands out when it appears
- **Left-align body text** — only center slide titles or callout numbers
- **Every slide needs a visual element** — chart, icon circles, accent boxes, or a layout with columns; plain text-only slides are not acceptable
- **No accent lines under titles** — use whitespace + the hairline rule only
- **Consistent spacing** — 0.5" margins, ~0.3" between content blocks

**Layout patterns to use:**
- Two-column (text left, chart/visual right)
- Numbered rows with accent circles (icon + bold label + description)
- Accent card rows (left bar + f8fafc background + heading + body)
- IN/OUT or before/after columns with colored header bands

---

## QA (Required)

### Content QA
```bash
uv run --python 3.13 --with "markitdown[pptx]" python3.13 -m markitdown output.pptx
```

### Visual QA (macOS, no LibreOffice)

Quick Look renders the first slide only:
```bash
mkdir -p /tmp/slides_qa && qlmanage -t -s 1400 -o /tmp/slides_qa output.pptx
```

For full rendering, upload to Google Drive and open in Google Slides — that is the target viewer.

### Verification loop

1. Generate → content QA → qlmanage thumbnail check
2. List issues found
3. Fix, regenerate
4. Repeat until clean pass

**Do not declare success without at least one fix-and-verify cycle.**

---

## Google Slides Compatibility Notes

| Feature | Behaviour in Google Slides |
|---------|---------------------------|
| pptxgenjs `addChart` | Converted to static image — fonts lost |
| `addImage` (PNG) | Renders exactly as generated |
| Figtree font | Supported natively — no substitution |
| Shadows | Rendered correctly |
| OOXML animations | Dropped on import |

---

## Dependencies

```bash
npm install -g pptxgenjs
uv run --python 3.13 --with plotly --with kaleido python3.13 scripts/gen_chart.py
uv run --python 3.13 --with "markitdown[pptx]" python3.13 -m markitdown ...
```

LibreOffice (`soffice`) and `pdftoppm` are needed for `thumbnail.py` — skip if not available; use qlmanage + Google Slides upload for visual QA instead.
