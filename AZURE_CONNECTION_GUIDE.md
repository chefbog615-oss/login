# Azure Login for GitHub Actions - Complete Setup Guide

## Quick Summary

You now have everything needed to connect your Azure account (`chefbog420@outlook.com`) to GitHub Actions with secure OIDC authentication.

## What Was Set Up For You

✅ **Azure Login Bootstrap Workflow** - Automated setup for OIDC authentication  
✅ **Bootstrap Script** - Creates Azure AD app, service principal, and federated credentials  
✅ **Demo Workflows** - Ready-to-use examples for Azure CLI and PowerShell  
✅ **Complete Documentation** - Step-by-step guides and troubleshooting  

## Your Action Items (In Order)

### Step 1: Create Bootstrap Service Principal (Do This First)

Open Azure CLI or Azure Cloud Shell and run:

```bash
az ad sp create-for-rbac --name "github-actions-bootstrap" --role "Owner"
```

**Copy the entire JSON output** - you'll need this in the next step.

Example output (yours will have different IDs):
```json
{
  "appId": "12345678-1234-1234-1234-123456789012",
  "displayName": "github-actions-bootstrap",
  "password": "your-secret-here",
  "tenant": "87654321-4321-4321-4321-210987654321"
}
```

### Step 2: Add the Secret to Your GitHub Repository

1. Go to your repository: https://github.com/chefbog615-oss/login
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. **Name**: `AZURE_BOOTSTRAP_CREDENTIALS`
5. **Value**: Paste the entire JSON from Step 1
6. Click **Add secret**

### Step 3: Run the Bootstrap Workflow

1. Go to **Actions** tab in your repository
2. In the left sidebar, click **"Azure Login Bootstrap"**
3. Click **"Run workflow"** button
4. Fill in these values:
   - **github-repo**: `chefbog615-oss/login`
   - **github-ref**: `refs/heads/master`
   - **app-name**: (leave as default)
   - **audience**: (leave as default)
5. Click **Run workflow**
6. Wait for it to complete (usually < 2 minutes)

### Step 4: Verify the Setup

After the workflow completes successfully:

1. Go back to **Settings** → **Secrets and variables** → **Actions**
2. You should see three new secrets:
   - `AZURE_CLIENT_ID`
   - `AZURE_TENANT_ID`
   - `AZURE_SUBSCRIPTION_ID`

If you don't see these, check the workflow run logs for errors.

### Step 5: Test It Works

1. Go to **Actions** tab
2. Click **"Azure Login Demo"** in the left sidebar
3. Click **"Run workflow"**
4. Watch the logs to see:
   - Azure CLI login successful
   - Your subscription information
   - Your resource groups listed

## What Happens Next

Once you complete these 5 steps, you can:

- ✅ Run Azure CLI commands in any GitHub Actions workflow
- ✅ Run Azure PowerShell commands (enable with `enable-AzPSSession: true`)
- ✅ Deploy to Azure from GitHub Actions
- ✅ Use OIDC without storing any secrets
- ✅ Credentials rotate automatically

## Example Workflow Usage

After setup, use Azure commands in your workflows:

```yaml
- name: Azure login
  uses: azure/login@v3
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

- name: List resources
  run: az resource list --output table
```

## Need Help?

**Bootstrap workflow failed?**
- Check the workflow run logs: Actions → Azure Login Bootstrap → click the failed run
- Verify the JSON secret is valid
- Ensure the service principal has Owner role on your subscription

**Demo workflow failed?**
- Verify the three secrets exist in Settings → Secrets
- Re-run the bootstrap workflow
- Check that your GitHub account has Actions enabled

**Scripts not executing?**
- Ensure you're on a supported OS (ubuntu-latest works)
- Check that Azure CLI is installed (it is in ubuntu-latest)

## Account Details

| Item | Value |
|------|-------|
| Azure Account | chefbog420@outlook.com |
| GitHub Repository | chefbog615-oss/login |
| Bootstrap App Name | github-actions-bootstrap |
| Authentication Method | OIDC (no secrets stored) |

## Additional Resources

- [SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md) - Detailed step-by-step guide
- [BOOTSTRAP_QUICKSTART.md](BOOTSTRAP_QUICKSTART.md) - Quick reference
- [README.md](README.md#bootstrap-github-actions-azure-login) - Original bootstrap docs
- [Azure Login Action](https://github.com/Azure/login) - Full documentation

---

**Status**: ✅ Ready to use. Follow the 5 action items above to connect your Azure account.

**Questions?** Check the workflow logs or the guides above first.
