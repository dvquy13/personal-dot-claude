# Gotchas: GA4 (Google Analytics Data API)

See also: `providers/google/gotchas.md` for shared Google API gotchas.

---

## analytics.readonly scope is blocked for the gcloud default client

Google has blocked `analytics.readonly` (and other sensitive scopes) for the gcloud SDK's default OAuth client ID. Running:

```bash
gcloud auth application-default login --scopes=...,https://www.googleapis.com/auth/analytics.readonly
```

will show "This app has been blocked" in the browser. The warning text says:
> "To use these scopes, you must provide your own client ID or use service account impersonation."

**Workaround:** Use `auth.type = "service_account"` with a service account key file. The service account must have GA4 Viewer access granted via the Analytics Admin API. See `providers/google/auth-setup.md`.

---

## GA4 Data API must be enabled separately

Even if Firebase/Firestore APIs are enabled, you must explicitly enable:

```bash
gcloud services enable analyticsdata.googleapis.com --project=<your-gcp-project>
```

---

## BetaAnalyticsDataClient silently fails in Supabase Edge Function

The Python `google-analytics-data` library's `BetaAnalyticsDataClient` silently fails in the Supabase Edge Function Deno runtime. Use direct REST calls instead:

```
POST https://analyticsdata.googleapis.com/v1beta/properties/<id>:runReport
```

This is what the fetch-metrics.py runner does — it never uses the Python client library.

---

## quota_project must be included in service_account config

Unlike `oauth_adc`, the service_account auth does NOT send `x-goog-user-project`. However, the `quota_project` field in the config is used by the runner to set the quota project on the service account credentials object. Include it to avoid `403 accessNotConfigured`.

Wait — actually this contradicts the general gotcha. Check `providers/google/gotchas.md`: service accounts must NOT send `x-goog-user-project`. The runner handles this by only setting the header for `oauth_adc` auth type, not `service_account`.
