# Skill: metric-extractor

Add, configure, and run metrics with the metric-extractor pipeline. Fetches numbers from APIs, web pages, and dashboards; pushes results to Supabase; sends Telegram alerts.

---

## Setup Mode (first time in a new project)

When `analytics/` doesn't exist in the project:

```bash
mkdir -p analytics/{scripts,configs,fixtures,cookies,secrets,credentials}
cp ~/.claude/skills/metric-extractor/scripts/* analytics/scripts/
cp ~/.claude/skills/metric-extractor/alerts.yaml analytics/alerts.yaml
```

Add to `.gitignore`:
```
analytics/cookies/
analytics/secrets/
analytics/credentials/
```

Add to `CLAUDE.md`:
```
Metrics pipeline scripts and configs live in analytics/. See ~/.claude/skills/metric-extractor/SKILL.md for full docs.
```

---

## Adding a Metric — Three-Tier Decision

### Tier 1: Known provider → one-shot

Check `providers/` in this skill. If the provider is listed:

1. Copy the closest `config-example.json` from `providers/<name>/`
2. Fill in project-specific values (property IDs, credentials paths, domains)
3. Save to `analytics/configs/<metric-name>.json`
4. Save a fixture to `analytics/fixtures/<metric-name>.txt`
5. Test: `uv run scripts/fetch-metrics.py --fixture --test` (from `analytics/`)

**No clarifying questions needed** — produce the config immediately.

Known providers:
- `providers/google/ga4/` — GA4 Data API (service_account auth)
- `providers/google/search-console/` — GSC Search Analytics (oauth_adc auth)
- `providers/google/firebase-firestore/` — Firestore Aggregation Query (service_account auth)
- `providers/lemonsqueezy/` — LemonSqueezy API (api_key auth)
- `providers/chrome-web-store/` — CWS listing page (no auth, regex)

---

### Tier 2: New but inferable provider → interview + collaborate

If the provider has a public API or dashboard but isn't in `providers/`:

Run a structured interview:
1. **Endpoint** — What URL returns the data? (REST, GraphQL, scrape?)
2. **Auth** — API key, OAuth, cookie, public?
3. **Response shape** — JSON path or regex to the value?
4. **Pagination** — Is the value on page 1 or aggregated across pages?
5. **Rate limits** — Any throttling to be aware of?

After gathering answers, produce the config. At the end, create `providers/<provider-name>/` in this skill with:
- `config-example.json` (scrubbed)
- `gotchas.md` (pitfalls found during setup)
- `fixtures/<name>.txt`

---

### Tier 3: Unknown / undocumented provider → flag + plan

If the provider has no public docs, no public API, and no obvious scrape path:

1. **Explicitly flag** the provider as unknown/undocumented
2. **Write a tracer bullet plan** at `.claude/plans/<provider-name>-metric.md`:
   - Investigation steps (find network requests, check for internal APIs, review auth flows)
   - What to try first, what to try if that fails
   - Blockers and unknowns
3. **Do NOT create** any `analytics/configs/` file yet

---

## Auth Decision Tree

Work through this top-to-bottom, stop at first match:

```
Is there an official REST API for this data?
├── YES → Does the API require OAuth? (user-specific data, Google APIs)
│   ├── YES → Is it GSC? (cannot add service accounts)
│   │   └── YES → auth.type = "oauth_adc"  (see providers/google/gotchas.md)
│   ├── YES → Is it GA4 or Firebase? (analytics.readonly blocked for gcloud client)
│   │   └── YES → auth.type = "service_account"  (use Firebase service account key)
│   └── NO  → auth.type = "api_key"
└── NO → Is the data on a public page (no login)?
    ├── YES → auth.domain = null  (or auth.type = "none")
    └── NO → auth.type = "cookie"  (scrape authenticated dashboard)
              Is the dashboard Inertia.js (Laravel/Vue)?
              ├── YES → use request.inertia two-step fetch
              └── NO → plain GET with cookies
```

**Rule:** Always prefer an official API over scraping.

---

## Step-by-Step: Adding a Config

### 1. Identify what to measure

- What page shows this number?
- Count, dollar amount, or percentage?
- Time range: all-time, 28d, YTD?

### 2. Inspect the network request

**For APIs:** Read the docs. Find the endpoint that returns your number.

**For cookie-based metrics:**
1. Open Chrome DevTools → Network → Fetch/XHR
2. Log in → navigate to the page → find the XHR returning the number
3. Right-click → Copy → Copy as cURL
4. Note: URL, method, headers, body

**Inertia.js?** Signs: `X-Inertia` in request headers, `data-page` in HTML source. See `providers/lemonsqueezy/gotchas.md`.

### 3. Identify the value in the response

- **HTML:** find text around the number, write a regex
- **JSON:** trace the dot-notation path from root

JSONPath examples (`references/config-schema.md` for full syntax):
```
data.0.attributes.total_revenue          # numeric index
meta.page.total                          # nested keys
props.overview.charts[slug=revenue].total  # array filter by field value
rows.0.clicks                            # first item in array
```

When value might be absent (zero-traffic periods), use `"default_value": 0`.

### 4. Write the config

Copy the closest `config-example.json` from `providers/`. Full schema: `references/config-schema.md`.

### 5. Test

```bash
# Live test — fetches real data
cd analytics
uv run scripts/fetch-metrics.py --name <your_metric_name> --test
```

Save a fixture after a successful live run, then verify offline:
```bash
uv run scripts/fetch-metrics.py --fixture --test
```

### 6. Regression gate

```bash
# All metrics, offline
uv run scripts/fetch-metrics.py --fixture --test

# All metrics, live
uv run scripts/fetch-metrics.py --test
```

---

## Running the Pipeline

### Locally

```bash
cd analytics

# Fetch all metrics + push to Supabase + send Telegram alerts
uv run scripts/fetch-metrics.py | \
  SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... \
  uv run scripts/push-and-notify.py

# Fetch only (no push/alert)
uv run scripts/fetch-metrics.py --test
```

### CI (GitHub Actions)

Workflow at `.github/workflows/fetch-metrics.yml` runs daily at `00:00 UTC` (07:00 GMT+7) and on `workflow_dispatch`.

Required GitHub Secrets:
| Secret | What it holds |
|---|---|
| `GOOGLE_ADC_CREDENTIALS` | Contents of `~/.config/gcloud/application_default_credentials.json` |
| `GA4_SERVICE_ACCOUNT_JSON` | Firebase/GA4 service account key JSON |
| `LEMONSQUEEZY_API_KEY` | LemonSqueezy API key |
| `SUPABASE_URL` | Supabase project URL |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase service role key |
| `TELEGRAM_BOT_TOKEN` | Telegram bot token |
| `TELEGRAM_CHAT_ID` | Telegram chat ID |

**When ADC changes**, update the secret:
```bash
gh secret set GOOGLE_ADC_CREDENTIALS < ~/.config/gcloud/application_default_credentials.json
```

### Alerts (`analytics/alerts.yaml`)

`push-and-notify.py` reads `alerts.yaml` from the `analytics/` directory:
- `type: failure` — fires on any metric with `status: error`
- `type: metric_change` — fires when a metric value changes by `min_delta` or more

---

## Gotchas Index

| Provider | Gotcha file |
|----------|-------------|
| Any Google API (GSC, GA4, Firebase) | `providers/google/gotchas.md` |
| GA4 specifically | `providers/google/ga4/gotchas.md` |
| Google Search Console specifically | `providers/google/search-console/gotchas.md` |
| LemonSqueezy | `providers/lemonsqueezy/gotchas.md` |

Key gotchas without reading:
- **Google APIs**: `x-goog-user-project` header required for `oauth_adc` — runner sets it from `auth.quota_project`
- **Google APIs**: API keys always return 401 for user-data APIs — must use `oauth_adc`
- **GA4**: `analytics.readonly` blocked for gcloud client — use `service_account`
- **LemonSqueezy**: 409 = stale session — re-run `extract-cookies.py`
- **LemonSqueezy**: `charts[slug=revenue].total` not `charts[0].total` — chart order changes

---

## Directory Layout

```
~/.claude/skills/metric-extractor/   ← this skill (templates)
  SKILL.md
  scripts/                           ← generic scripts
  references/config-schema.md
  alerts.yaml                        ← template (copy to analytics/)
  evals/evals.json                   ← TDD evals
  providers/
    google/
      auth-setup.md                  ← GSC + GA4 auth setup
      gotchas.md                     ← shared Google API gotchas
      search-console/
        config-example.json
        gotchas.md
        fixtures/
      ga4/
        config-example.json
        gotchas.md
        fixtures/
      firebase-firestore/
        config-example.json
        fixtures/
    lemonsqueezy/
      config-example.json
      gotchas.md
      fixtures/
    chrome-web-store/
      config-example.json
      fixtures/

<project>/analytics/                 ← project instance
  scripts/                           ← copies of scripts (for CI)
  configs/                           ← one JSON per metric
  fixtures/                          ← committed response bodies
  alerts.yaml                        ← project-specific alert rules
  cookies/                           ← gitignored
  secrets/                           ← gitignored
  credentials/                       ← gitignored
```
