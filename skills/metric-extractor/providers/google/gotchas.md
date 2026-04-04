# Gotchas: Google APIs

Applies to: GSC, GA4, Firebase — any Google API using `oauth_adc` or `service_account` auth.

---

## x-goog-user-project header is required (oauth_adc only)

The `quota_project_id` field in `~/.config/gcloud/application_default_credentials.json` does NOT propagate to API requests automatically when using `urllib` directly.

You must send it as a request header on every call:
```
x-goog-user-project: <your-project-id>
```

The `google-auth` library only forwards this automatically when you use its own HTTP adapter (`google.auth.transport.requests.AuthorizedSession`). Since we use `urllib`, the runner sets this header explicitly from `config.auth.quota_project`.

**Symptom without it:** `403 SERVICE_DISABLED` on `projects/764086051850` (the Cloud SDK's project) even though the API is enabled on your own project.

---

## Service accounts must NOT send x-goog-user-project

When using `service_account` auth, do not include `quota_project` in the config. Service accounts are already project-scoped; sending the header causes:

```
403 USER_PROJECT_DENIED: Caller does not have required permission to use project ...
  Grant roles/serviceusage.serviceUsageConsumer
```

---

## API keys do not work for user-specific Google APIs

`searchconsole.googleapis.com`, `analyticsdata.googleapis.com`, and similar user-data APIs require OAuth2. API keys return `401 Unauthorized` immediately.

---

## Service accounts cannot be added to Search Console (non-Workspace domains)

Google Search Console's "Add user" flow requires a real Google Account. Service account emails are GCP identities, not Google Accounts — you get "Failed to add user: email not found".

**Workaround:** Use ADC (`oauth_adc`) with the account that owns the GSC property.

---

## ADC scopes are locked at login time

`gcloud auth application-default login` locks in the scopes for the refresh token. If you need a new scope later, re-run the full login with all scopes:

```bash
gcloud auth application-default login \
  --scopes=https://www.googleapis.com/auth/webmasters.readonly,\
https://www.googleapis.com/auth/cloud-platform,\
https://www.googleapis.com/auth/iam
gcloud auth application-default set-quota-project <your-gcp-project>
```

The new scopes list replaces the old one — it does not append.

**Symptom of missing `webmasters.readonly`:** GSC metrics return `HTTP Error 403: Forbidden`. This is silent with `--fixture` — fixture mode skips all HTTP calls. Always do a live `--test` run after changing ADC credentials.

---

## Always set the quota project after ADC login

```bash
gcloud auth application-default set-quota-project <your-gcp-project>
```

Without this, some APIs return `403 accessNotConfigured`.

---

## GSC sc-domain: prefix must be URL-encoded

Site URL in the API path: `sc-domain:<your-domain>` → `sc-domain%3A<your-domain>`. The colon must be percent-encoded or the API returns 404.

---

## GA4 / analytics.readonly scope is blocked for the gcloud default client

Google has blocked `analytics.readonly` for the gcloud SDK's default OAuth client ID. Running:

```bash
gcloud auth application-default login --scopes=...,https://www.googleapis.com/auth/analytics.readonly
```

will show "This app has been blocked" in the browser.

**Workaround:** Use `auth.type = "service_account"` with a service account key file. See `providers/google/ga4/gotchas.md`.

---

## GSC rows may be absent for zero-traffic periods

If the date range has no impressions, the response has no `rows` key at all — not an empty array, just absent. Use `"default_value": 0` in the extract config.
