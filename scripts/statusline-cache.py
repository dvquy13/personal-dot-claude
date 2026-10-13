#!/usr/bin/env python3
"""Prompt cache status line segment. Reads status line JSON from stdin."""
import json, os, re, sys, time

G, Y, R, D, X = "\033[32m", "\033[33m", "\033[31m", "\033[2m", "\033[0m"
BAR_WIDTH = 10


def fmt_left(sec):
    sec = max(0, int(sec))
    if sec >= 3600:
        h, m = divmod(sec // 60, 60)
        return f"{h}h {m}m" if m else f"{h}h"
    if sec >= 60:
        return f"{sec // 60}m"
    return f"{sec}s"


def ttl_seconds(ttl):
    return {"5m": 300, "1h": 3600}.get(ttl)


# Base input $/1M tokens, from platform.claude.com/docs/en/about-claude/pricing (checked 2026-10-13).
# Cache write = 1.25x (5m) or 2x (1h). First matching pattern wins; unlisted models get no estimate.
# (model id regex, $/1M, $/1M when prompt is over 100k tokens or None)
INPUT_PRICE = [
    (r"fable", 10.0, None),
    (r"opus-5-5", 4.0, None),
    (r"opus-4(-[01])?(?!-[5-9])", 15.0, None),  # Opus 4 and 4.1; Opus 4.5+ fall through to $5
    (r"opus-5(?!-5)", 5.0, None),  # Opus 5
    (r"opus-4-[5-8]", 5.0, None),  # Opus 4.5 to 4.8
    (r"sonnet-5", 2.0, None),
    (r"sonnet-4", 3.0, None),
    (r"haiku-5-5", 0.10, 0.50),
    (r"haiku-4-5", 1.0, None),
    (r"haiku-3-5", 0.80, None),
]
WRITE_MULT = {"5m": 1.25, "1h": 2.0}


def recache_cost(model_id, ttl, tokens):
    mid = (model_id or "").lower()
    rule = next((r for r in INPUT_PRICE if re.search(r[0], mid)), None)
    if rule is None:
        return None
    _, price, long_price = rule
    if long_price is not None and tokens > 100_000:
        price = long_price
    return tokens / 1e6 * price * WRITE_MULT.get(ttl, 1.25)


def main():
    try:
        data = json.load(sys.stdin)
    except ValueError:
        return
    pc = data.get("prompt_cache")
    if not isinstance(pc, dict) or pc.get("caching_observed") is False:
        return

    now = float(os.environ.get("CACHE_NOW") or time.time())
    expires = pc.get("expires_at")
    left = expires - now if expires is not None else None
    warm = pc.get("warm") and (left is None or left > 0)

    if not warm:
        out = f"{R}cache ○ cold"
        tokens = pc.get("recache_tokens_if_cold")
        if tokens is not None:
            out += f" · next message re-caches {round(tokens / 1000)}k tokens"
            cost = recache_cost((data.get("model") or {}).get("id"), pc.get("ttl"), tokens)
            if cost is not None:
                out += f" (~${cost:.2f})"
        causes = (pc.get("last_miss_cause") or {}).get("causes")
        if causes:
            out += f" · last miss: {', '.join(causes)}"
        print(out + X)
        return

    ttl = pc.get("ttl")
    total = ttl_seconds(ttl)
    color = G
    parts = ["cache ●"]
    if ttl:
        parts[0] += f" {ttl}"
    if left is not None:
        if total:
            frac = min(1.0, left / total)
            if frac < 0.2:
                color = Y
            filled = round(frac * BAR_WIDTH)
            parts[0] += f" {'▰' * filled}{'▱' * (BAR_WIDTH - filled)}"
        parts[0] += f" {fmt_left(left)} left"
    if pc.get("hit_ratio") is not None:
        parts.append(f"hit {round(pc['hit_ratio'] * 100)}%")
    if pc.get("misses") is not None:
        parts.append(f"misses {pc['misses']}")
    print(f"{color}{' · '.join(parts)}{X}")


main()
