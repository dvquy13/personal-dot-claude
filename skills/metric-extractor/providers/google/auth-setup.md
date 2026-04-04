# Setup: Google APIs Auth

Covers: GA4 (service account) and Google Search Console (ADC/oauth_adc).

## Prerequisites

- `gcloud` CLI installed
- GCP project created (replace `<your-gcp-project>` throughout)
- You own/admin the domain in GSC / GA4 property

---

## GA4 — Service Account Setup

One-time setup to create a service account that can read GA4 reports via the Data API.

### Step 1: Create the service account and download the key

```bash
PROJECT_ID=<your-gcp-project>
SA_NAME=metrics-reader
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud iam service-accounts create "${SA_NAME}" \
  --display-name="Metrics Reader" \
  --project="${PROJECT_ID}"

mkdir -p analytics/credentials
gcloud iam service-accounts keys create "analytics/credentials/${PROJECT_ID}-${SA_NAME}.json" \
  --iam-account="${SA_EMAIL}"
```

### Step 2: Grant GA4 Viewer access

GA4 property access is managed in GA4's own IAM, not GCP IAM.

```bash
GA4_PROPERTY_ID=<your-ga4-property-id>   # numeric only, no "properties/" prefix

gcloud auth application-default login \
  --scopes=https://www.googleapis.com/auth/analytics.edit,https://www.googleapis.com/auth/cloud-platform
gcloud auth application-default set-quota-project "${PROJECT_ID}"

TOKEN=$(gcloud auth application-default print-access-token)

curl -s -X POST \
  "https://analyticsadmin.googleapis.com/v1beta/properties/${GA4_PROPERTY_ID}/accessBindings" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{
    \"user\": \"serviceAccount:${SA_EMAIL}\",
    \"roles\": [\"predefinedRoles/viewer\"]
  }"
```

### Step 3: Enable the Analytics Data API

```bash
gcloud services enable analyticsdata.googleapis.com --project="${PROJECT_ID}"
```

### Notes

- The `analytics.edit` scope is needed for Step 2 but NOT for reading reports.
- If the service account was already created for Firebase/Firestore, skip Step 1 and reuse the existing key file.
- Do NOT include `quota_project` in service_account configs — service accounts must not send `x-goog-user-project` (see `providers/google/gotchas.md`).

---

## Google Search Console — ADC Setup

Auth type: `oauth_adc` — uses Application Default Credentials via `gcloud`.

### Prerequisites

- Logged in as the account that owns the GSC property
- Domain verified in Search Console

### One-time setup

```bash
# 1. Enable the API on your GCP project
gcloud services enable searchconsole.googleapis.com --project <your-gcp-project>

# 2. Login with the webmasters scope (opens browser once)
gcloud auth application-default login \
  --scopes=https://www.googleapis.com/auth/webmasters.readonly,https://www.googleapis.com/auth/cloud-platform

# 3. Set quota project (required — without this, API returns 403)
gcloud auth application-default set-quota-project <your-gcp-project>
```

Select the account that owns `<your-domain>` in Search Console.

### Notes

- Do NOT use API keys — GSC requires OAuth for user-specific data (returns 401)
- Do NOT use service accounts — GSC doesn't accept them for non-Workspace domains ("email not found")
- ADC refresh token does not expire unless you change your Google password or revoke it
- If you get 403 after setup, see `providers/google/gotchas.md`
