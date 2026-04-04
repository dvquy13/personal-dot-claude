# Config Schema Reference

Each metric is a single JSON file in `configs/`. The runner (`fetch-metrics.py`) loads all `*.json` files from that directory.

---

## Top-level fields

```jsonc
{
  "name":        "snake_case_identifier",  // required — used in JSON output and --name filter
  "description": "Human-readable string",  // required — explains what and where
  "auth":        { ... },                  // required — see Auth section
  "request":     { ... },                  // required — see Request section
  "extract":     { ... },                  // required — see Extract section
  "validate":    { ... }                   // optional — sanity-check the extracted value
}
```

---

## `auth`

### No auth (public pages)

```json
{ "domain": null }
```

Or explicitly:

```json
{ "type": "none" }
```

Use when the URL is publicly accessible without login.

---

### Cookie auth (authenticated dashboards)

```json
{
  "type": "cookie",
  "domain": "app.example.com"
}
```

Reads cookies from `cookies/app.example.com.json` (written by `extract-cookies.py`).

For Inertia.js apps, also add `request.inertia` — see the Request section.

---

### API key auth

```json
{
  "type": "api_key",
  "env": "MY_SERVICE_API_KEY",
  "format": "bearer",
  "setup": "Generate at example.com → Settings → API"
}
```

| Field | Values | Default | Notes |
|-------|--------|---------|-------|
| `env` | env var name | — | Runner checks `$ENV_VAR` first, then `secrets/secrets.json` |
| `format` | `"bearer"` / `"query"` | `"query"` | `bearer` → `Authorization: Bearer <key>`; `query` → `?key=<key>` appended to URL |
| `setup` | string | — | Shown in error message when key is missing |

---

### OAuth ADC (Google APIs)

```json
{
  "type": "oauth_adc",
  "scopes": ["https://www.googleapis.com/auth/webmasters.readonly"],
  "quota_project": "my-gcp-project-id"
}
```

Uses `google-auth` with Application Default Credentials. The runner:
1. Calls `google.auth.default(scopes=..., quota_project_id=...)`
2. Refreshes the token
3. Sends `Authorization: Bearer <token>` and `x-goog-user-project: <quota_project>` headers

**`quota_project` is required** — without it, requests fail with `403 SERVICE_DISABLED` on the Cloud SDK's project even when the API is enabled on yours. See `gotchas/google-apis.md`.

Setup command (run once per scope set):
```bash
gcloud auth application-default login --scopes=<comma-separated-scopes>
gcloud auth application-default set-quota-project <project-id>
```

---

### Service account (Google APIs blocked for ADC)

```json
{
  "type": "service_account",
  "credentials_file": "credentials/my-project-firebase-adminsdk-xxx.json",
  "scopes": ["https://www.googleapis.com/auth/analytics.readonly"]
}
```

| Field | Notes |
|-------|-------|
| `credentials_file` | Path to service account JSON key. Relative paths: checked against cwd first, then skill base dir. |
| `scopes` | OAuth scopes to request. |
| `quota_project` | Optional — omit for service accounts (they're already project-scoped). |

Use when `oauth_adc` is blocked by Google's default client policy (e.g. `analytics.readonly`). Do **not** include `quota_project` — service accounts must not send `x-goog-user-project`.

---

## `request`

### Simple GET

```json
{
  "url": "https://example.com/api/data",
  "method": "GET"
}
```

`method` defaults to `GET` if omitted.

### POST with JSON body

```json
{
  "url": "https://api.example.com/v1/query",
  "method": "POST",
  "body": {
    "startDate": "{{today-28d}}",
    "endDate": "{{today}}",
    "searchType": "web"
  }
}
```

String values in `body` support the same URL templates as the `url` field. Non-string values (numbers, booleans) are passed through unchanged.

### Inertia.js two-step fetch

```json
{
  "url": "https://app.example.com/dashboard?date_from={{start_of_year}}&date_to={{today}}",
  "inertia": {
    "partial_data": "overview",
    "partial_component": "App/Dashboard"
  }
}
```

When `request.inertia` is present, the runner:
1. GET the URL → extracts `version` from `data-page` HTML attribute (works even on auth-redirect pages)
2. GET the same URL with `X-Inertia`, `X-Inertia-Version`, `X-Inertia-Partial-Data`, `X-Inertia-Partial-Component`, `X-XSRF-TOKEN`, and `Sec-Fetch-*` headers → returns JSON

Find `partial_data` and `partial_component` in DevTools → Network → XHR request headers.

**HTTP 409** = stale session (not version mismatch). Fix: visit the site in Chrome → re-run `extract-cookies.py`.

---

## URL templates

Templates are resolved in both `url` and string values inside `request.body`.

| Template | Resolves to |
|----------|-------------|
| `{{today}}` | Today's date, `YYYY-MM-DD` |
| `{{today-7d}}` | 7 days ago |
| `{{today-28d}}` | 28 days ago |
| `{{today-30d}}` | 30 days ago |
| `{{today-90d}}` | 90 days ago |
| `{{start_of_year}}` | January 1 of the current year |
| `{{start_of_month}}` | First day of the current month |

---

## `extract`

### Regex (HTML / text responses)

```json
{
  "type": "regex",
  "pattern": ">(\\d[\\d,]*) users</div>",
  "group": 1,
  "cast": "int"
}
```

| Field | Default | Notes |
|-------|---------|-------|
| `pattern` | — | Python regex; use `\\d` not `\d` in JSON |
| `group` | `1` | Capture group index |
| `cast` | `"string"` | See Cast types below |

Flags: `re.DOTALL` is always set (`.` matches newlines).

---

### JSONPath (JSON responses)

```json
{
  "type": "jsonpath",
  "path": "data.0.attributes.total_revenue",
  "cast": "money_cents",
  "default_value": 0
}
```

| Field | Default | Notes |
|-------|---------|-------|
| `path` | — | Dot-notation path from JSON root |
| `cast` | `"string"` | See Cast types below |
| `default_value` | _(absent)_ | Return this value instead of erroring when path not found |

**Path syntax:**

```
data.0.attributes.name        # plain key traversal; numeric segments index into arrays
meta.page.total               # nested keys
charts[slug=revenue].total    # array filter: find first item where item["slug"] == "revenue"
rows.0.clicks                 # first element of an array
```

Array filter syntax: `key[field=value]` — finds the first array item where `item[field] == value` (string comparison). Use this instead of numeric indices when the array order might change.

---

### Cast types

| Value | Effect |
|-------|--------|
| `"string"` | Keep as-is (default) |
| `"int"` | `int(raw)` — strips commas first if needed |
| `"float"` | `float(raw)` |
| `"money_cents"` | `round(float(raw) / 100, 2)` — converts integer cents to dollars |

---

## `validate`

```json
{ "min": 0, "max": 1000000 }
```

Both fields are optional. If the extracted value falls outside the range, the metric result has `status: "error"`. Use to catch obviously wrong values (e.g. a regex that matched a different number).

---

## Full examples

### Public page (regex)

```json
{
  "name": "cws_users",
  "description": "Chrome Web Store user count (public listing page)",
  "auth": { "domain": null },
  "request": {
    "url": "https://chromewebstore.google.com/detail/my-extension/abc123",
    "method": "GET"
  },
  "extract": {
    "type": "regex",
    "pattern": ">(\\d[\\d,]*) users</div>",
    "group": 1,
    "cast": "int"
  },
  "validate": { "min": 0, "max": 1000000 }
}
```

### REST API with bearer token

```json
{
  "name": "lemon_revenue",
  "description": "All-time revenue from LemonSqueezy",
  "auth": {
    "type": "api_key",
    "env": "LEMONSQUEEZY_API_KEY",
    "format": "bearer",
    "setup": "Generate at app.lemonsqueezy.com → Settings → API → New API key"
  },
  "request": {
    "url": "https://api.lemonsqueezy.com/v1/stores",
    "method": "GET"
  },
  "extract": {
    "type": "jsonpath",
    "path": "data.0.attributes.total_revenue",
    "cast": "money_cents"
  },
  "validate": { "min": 0, "max": 10000000 }
}
```

### Google API (oauth_adc, POST with date range)

```json
{
  "name": "gsc_clicks_28d",
  "description": "GSC total clicks for calens.dev, last 28 days",
  "auth": {
    "type": "oauth_adc",
    "scopes": ["https://www.googleapis.com/auth/webmasters.readonly"],
    "quota_project": "my-gcp-project-id"
  },
  "request": {
    "url": "https://www.googleapis.com/webmasters/v3/sites/sc-domain%3Acalens.dev/searchAnalytics/query",
    "method": "POST",
    "body": {
      "startDate": "{{today-28d}}",
      "endDate": "{{today}}",
      "searchType": "web"
    }
  },
  "extract": {
    "type": "jsonpath",
    "path": "rows.0.clicks",
    "cast": "int",
    "default_value": 0
  },
  "validate": { "min": 0, "max": 100000 }
}
```

### Inertia.js dashboard (cookie + partial reload)

```json
{
  "name": "lemon_mrr",
  "description": "Current MRR from LemonSqueezy dashboard",
  "auth": {
    "type": "cookie",
    "domain": "app.lemonsqueezy.com"
  },
  "request": {
    "url": "https://app.lemonsqueezy.com/stores/12345/dashboard?date_from={{start_of_year}}&date_to={{today}}",
    "inertia": {
      "partial_data": "overview",
      "partial_component": "App/Dashboard"
    }
  },
  "extract": {
    "type": "jsonpath",
    "path": "props.overview.charts[slug=monthly-recurring-revenue-snapshot].most_recent_total",
    "cast": "money_cents"
  },
  "validate": { "min": 0, "max": 100000 }
}
```

---

## Runner CLI reference

```bash
# Fetch all metrics (live)
uv run scripts/fetch-metrics.py

# Fetch one metric by name
uv run scripts/fetch-metrics.py --name cws_users

# Validate: exit 1 if any metric fails
uv run scripts/fetch-metrics.py --test

# Offline: use fixtures instead of live HTTP (no auth needed)
uv run scripts/fetch-metrics.py --fixture --test

# Override directories
uv run scripts/fetch-metrics.py \
  --config-dir /path/to/configs \
  --cookie-dir /path/to/cookies \
  --fixture-dir /path/to/fixtures
```

Output format:
```json
{
  "fetched_at": "2026-04-03T12:00:00Z",
  "metrics": {
    "cws_users": { "value": 42, "status": "ok", "fetched_at": "..." },
    "lemon_revenue": { "value": null, "status": "error", "error": "...", "fetched_at": "..." }
  }
}
```
