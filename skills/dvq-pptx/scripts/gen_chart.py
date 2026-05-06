"""dvq chart generator — Plotly + kaleido with dvq design tokens.

Generates a grouped bar chart PNG sized to exactly fit a pptxgenjs slide slot
(no stretching in Google Slides).

Usage:
    uv run --python 3.13 --with plotly --with kaleido python3.13 scripts/gen_chart.py

Customize the DATA, OPTIONS, METRICS, and SLOT_* constants below, then run.
The accent series name must match one entry in OPTIONS exactly.

Aspect ratio rule (critical for Google Slides):
    png_height = round(png_width / (SLOT_W / SLOT_H))
    e.g. slot 4.8" x 3.9" -> width=700, height=round(700/(4.8/3.9))=569
"""

import plotly.graph_objects as go

# ── Configure your chart here ────────────────────────────────────────────────

OUTPUT = "/tmp/chart.png"

# Slide slot dimensions in inches (must match addImage w/h in your .js script)
SLOT_W = 4.8
SLOT_H = 3.9

# Chart data
OPTIONS = ["Option A", "Option B", "Option C", "This"]   # bar groups (series)
METRICS = ["Metric 1", "Metric 2", "Metric 3"]           # x-axis categories

DATA = {
    "Option A": [1, 2, 3],
    "Option B": [4, 3, 2],
    "Option C": [2, 3, 1],
    "This":     [5, 4, 5],   # highlighted in accent blue
}

ACCENT_SERIES = "This"   # name of the series to highlight

# ── dvq design tokens ────────────────────────────────────────────────────────

ACCENT  = "#0062A8"
NEUTRAL = "#94A3B8"
FONT    = "Figtree, DM Sans, Inter, sans-serif"

# ── Render ───────────────────────────────────────────────────────────────────

def main():
    fig = go.Figure()

    for opt in OPTIONS:
        fig.add_trace(go.Bar(
            name=opt,
            x=METRICS,
            y=DATA[opt],
            marker_color=ACCENT if opt == ACCENT_SERIES else NEUTRAL,
            marker_line_width=0,
        ))

    fig.update_layout(
        barmode="group",
        paper_bgcolor="white",
        plot_bgcolor="white",
        font=dict(family=FONT, size=13, color="#64748B"),
        margin=dict(l=10, r=10, t=10, b=10),
        legend=dict(
            orientation="h",
            yanchor="bottom",
            y=-0.28,
            xanchor="center",
            x=0.5,
            font=dict(size=12),
            bgcolor="rgba(0,0,0,0)",
            borderwidth=0,
        ),
        xaxis=dict(showgrid=False, showline=False, zeroline=False, tickfont=dict(size=13)),
        yaxis=dict(showgrid=False, showline=False, zeroline=False, tickfont=dict(size=12)),
        bargap=0.2,
        bargroupgap=0.05,
    )

    png_width = 700
    png_height = round(png_width / (SLOT_W / SLOT_H))
    fig.write_image(OUTPUT, width=png_width, height=png_height, scale=2)
    print(f"Written: {OUTPUT}  ({png_width}x{png_height}px for {SLOT_W}\"x{SLOT_H}\" slot)")


if __name__ == "__main__":
    main()
