# Gotchas: Google Search Console

See also: `providers/google/gotchas.md` for shared Google API gotchas.

---

## sc-domain: prefix must be URL-encoded

Site URL in the API path: `sc-domain:<your-domain>` → `sc-domain%3A<your-domain>`. The colon must be percent-encoded or the API returns 404.

---

## Service accounts cannot be added to Search Console (non-Workspace domains)

Google Search Console's "Add user" flow requires a real Google Account. Service account emails (`name@project.iam.gserviceaccount.com`) are GCP identities — you get "Failed to add user: email not found".

**Workaround:** Use ADC (`oauth_adc`) with the account that owns the GSC property. No service account needed for a personal/solo setup.

---

## Rows may be absent for zero-traffic periods

If the date range has no impressions, the response has no `rows` key at all — not an empty array, just absent. Use `"default_value": 0` in the extract config to handle this gracefully.

---

## analytics.readonly scope is blocked for gcloud client

Do NOT try to use ADC for GA4. See `providers/google/ga4/gotchas.md`.
