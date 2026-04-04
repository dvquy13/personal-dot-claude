# Gotchas: app.lemonsqueezy.com

Site type: Inertia.js (Laravel)

## Auth/redirect JS challenge

Visiting any dashboard URL redirects through `/auth/redirect?url=...` before serving the page. This challenge requires JavaScript (iframe + postMessage to `auth.lemonsqueezy.com`) and **cannot be completed by urllib**.

**Key insight:** The auth/redirect page is itself an Inertia app. It embeds the same `version` hash in its `data-page` attribute that the actual dashboard uses. So the standard two-step Inertia fetch (`discover_inertia_version` → Inertia JSON request) works correctly — the version is extracted from the redirect page, not the dashboard page.

**Session freshness requirement:** The `laravel_session` cookie must be fresh. If the session has gone idle, the Inertia JSON request returns HTTP 409 even with the correct version. Fix: visit any Lemon page in Chrome, then re-run `extract-cookies.py`. The session typically stays valid for 30 minutes of inactivity.

**Symptom:** HTTP 409 from `fetch_inertia` with message "Inertia session stale". Not the same as a version mismatch 409 — both look identical in the response, but a fresh cookie re-extract resolves it.

## Inertia partial reload

The dashboard data comes from a partial reload, not the full page response:
- `X-Inertia-Partial-Data: overview`
- `X-Inertia-Partial-Component: App/Dashboard`

These headers MUST accompany the Inertia version header, or the response returns an empty `props` object.

`Sec-Fetch-*`, `Origin`, and `Referer` headers are also required — without them, the partial reload returns 419 (CSRF failure) or an empty response.

## Charts array

The `props.overview.charts` array contains all dashboard metrics. Each item has a stable `slug` field — use `charts[slug=<value>]` filter syntax in jsonpath paths rather than numeric indices. Chart order can change if LemonSqueezy adds new metrics to the dashboard.

Known slugs (as of 2026-04-02):
| Slug | Metric | Field used |
|------|--------|------------|
| `revenue` | All Revenue (period total, cents) | `total` |
| `new-orders` | New orders (period count) | `total` |
| `monthly-recurring-revenue-snapshot` | Current MRR (cents) | `most_recent_total` |
| `new-order-revenue` | New order revenue (cents) | `total` |
| `new-subscriptions` | New subscriptions (count) | `total` |
| `subscription-renewals-revenue` | Renewal revenue (cents) | `total` |
| `refunds` | Refunds (count) | `total` |

## `most_recent_total` vs `total` for MRR

`total` on the MRR chart is the sum of snapshots over the selected date range — not the current MRR. `most_recent_total` is the last data point in the selected range and represents the actual current MRR value. Use `most_recent_total` for "what is MRR right now?".

## Date range in URL

The dashboard URL requires `date_from` and `date_to` query params. The `partial_data` response respects this range. Use `{{start_of_year}}&date_to={{today}}` to get YTD metrics. Metrics like `revenue.total` reflect the selected period, not all time.

## Cloudflare Bot Management blocks Supabase Edge Function IPs

Cloudflare Bot Management blocks Supabase Edge Function IPs (shared cloud ranges). Revenue may be `null` in any Edge Function context. The Python runner (GitHub Actions) is unaffected — different IPs.

## Not yet expressible in config schema

- The distinction between `total` (period sum) and `most_recent_total` (point-in-time value) for MRR requires domain knowledge — the config field name alone doesn't document which to use.
- `partial_component` (`App/Dashboard`) is a Laravel/Vue class path that could change on a refactor. No way to auto-discover it without DevTools inspection.
