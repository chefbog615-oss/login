# Azure Login Bootstrap Quickstart

Use this guide to quickly set up GitHub Actions OIDC authentication with your Azure account.

## Prerequisites

- Azure subscription with admin/owner access
- GitHub repository where you want to enable Azure authentication
- GitHub personal access token with `repo` and `actions:write` scopes (optional but recommended)

## Step 1: Create Bootstrap Credentials

You need a service principal in your Azure AD tenant to run the bootstrap workflow. This SP will have permissions to create the actual app registration and federated credentials.

### Option A: Using Azure CLI (Recommended)

```bash
az ad sp create-for-rbac --name "github-actions-bootstrap" --role "Owner"
```

This outputs a JSON object. Save this for Step 2.

### Option B: Using Azure Portal

1. Go to Azure AD > App registrations > New registration
2. Name it `github-actions-bootstrap`
3. Go to Certificates & secrets > New client secret
4. Copy the secret value
5. Go to the Overview page and note the Application (client) ID and Directory (tenant) ID
6. In your subscription, assign this app the `Owner` role

## Step 2: Create GitHub Secret

In your GitHub repository:

1. Go to Settings > Secrets and variables > Actions
2. Click "New repository secret"
3. Name: `AZURE_BOOTSTRAP_CREDENTIALS`
4. Value: Paste the JSON from Step 1

Example format:
```json
{
  "clientId": "00000000-0000-0000-0000-000000000000",
  "clientSecret": "your-secret-value",
  "tenantId": "11111111-1111-1111-1111-111111111111",
  "subscriptionId": "22222222-2222-2222-2222-222222222222"
}
```

## Step 3: (Optional) Create GitHub PAT Secret

If you want the bootstrap workflow to automatically set secrets in your repo:

1. Create a GitHub Personal Access Token at https://github.com/settings/tokens
2. Grant `repo` and `actions:write` permissions
3. In your repo Settings > Secrets, create a new secret named `GH_PAT` with this token

## Step 4: Run Bootstrap Workflow

1. Go to GitHub > Actions
2. Find "Azure Login Bootstrap" workflow
3. Click "Run workflow"
4. Fill in the prompts:
   - **github-repo**: Your repository (e.g., `owner/my-repo`)
   - **github-ref**: Branch to trust for OIDC (default: `refs/heads/main`)
   - **app-name**: Display name for the app (default: `azure-login-github-actions`)
   - **audience**: OIDC audience (default: `api://AzureADTokenExchange`)

## Step 5: Verify Setup

Check your repo secrets. You should see three new secrets created:
- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

## Step 6: Test with Demo Workflow

Run one of the demo workflows to verify everything works:

1. Go to Actions > "Azure Login Demo"
2. Click "Run workflow"
3. Check the logs to confirm Azure CLI commands succeed

---

## Account Information

**Azure Email**: chefbog420@outlook.com

Replace this with your actual Azure account email in the bootstrap credentials.

## Troubleshooting

**Bootstrap workflow fails with "Unable to authenticate":**
- Verify `AZURE_BOOTSTRAP_CREDENTIALS` is valid JSON
- Check that the service principal has `Owner` role on your subscription

**Demo workflow fails:**
- Verify the three secrets were created
- Re-run the bootstrap workflow
- Check that your GitHub Actions has permission to write secrets

## Next Steps

After successful bootstrap:
- Use the demo workflows as templates for your CI/CD
- Refer to [README.md](README.md) for advanced usage options
- Configure role-based access instead of Owner (recommended for production)

