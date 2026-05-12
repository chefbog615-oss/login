# Azure Login Setup - Next Steps for chefbog420@outlook.com

Your bootstrap automation is ready. Follow these steps to connect your Azure account.

## What You Need to Do Now

### 1. Create Bootstrap Service Principal (5 minutes)

Run this in Azure CLI or Cloud Shell:

```bash
az ad sp create-for-rbac --name "github-actions-bootstrap" --role "Owner"
```

**Save the entire JSON output** - you'll need it in step 2.

### 2. Add GitHub Secret (2 minutes)

1. Go to: https://github.com/chefbog615-oss/login/settings/secrets/actions
2. Click "New repository secret"
3. **Name**: `AZURE_BOOTSTRAP_CREDENTIALS`
4. **Value**: Paste the JSON from step 1
5. Click "Add secret"

### 3. Run Bootstrap Workflow (2 minutes)

1. Go to: https://github.com/chefbog615-oss/login/actions
2. Find "Azure Login Bootstrap" in the left sidebar
3. Click "Run workflow" 
4. Fill in the inputs:
   - **github-repo**: `chefbog615-oss/login`
   - **github-ref**: `refs/heads/master` (or your working branch)
   - Leave other fields at defaults
5. Click "Run workflow" button
6. Wait for it to complete (should take < 1 minute)

### 4. Verify (2 minutes)

After the workflow completes:

1. Go to Settings > Secrets and variables > Actions
2. You should see three new secrets created:
   - `AZURE_CLIENT_ID`
   - `AZURE_TENANT_ID`
   - `AZURE_SUBSCRIPTION_ID`

If you don't see them, check the workflow run logs for errors.

### 5. Test Azure Connection (1 minute)

1. Go to Actions tab
2. Click "Azure Login Demo"
3. Click "Run workflow"
4. In the logs, verify you see:
   - `az account show` output with your subscription
   - `az group list` showing your resource groups

---

## Estimated Total Time: ~15 minutes

Your Azure login will then be fully configured for GitHub Actions!

## Troubleshooting

If the bootstrap workflow fails:

1. **Check the error logs** - Go to Actions > Azure Login Bootstrap > click the failed run > expand "Run bootstrap script"
2. **Verify AZURE_BOOTSTRAP_CREDENTIALS** - Make sure the JSON is valid and from step 1
3. **Check permissions** - The service principal needs Owner role on your subscription
4. **Contact support** - If still stuck, share the error message from the workflow logs

## Your Account

**Email**: chefbog420@outlook.com  
**Repository**: chefbog615-oss/login  
**Bootstrap Service Principal**: github-actions-bootstrap

---

Once complete, you'll have:
✅ OIDC-based Azure authentication (no secrets stored)  
✅ Two demo workflows ready to use  
✅ Automated credential rotation capability  
✅ Access to run Azure CLI and PowerShell commands in GitHub Actions  

