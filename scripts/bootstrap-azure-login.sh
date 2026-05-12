#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${GITHUB_REPO:-}" ]]; then
  echo "ERROR: GITHUB_REPO environment variable is required. Example: owner/repo"
  exit 1
fi
if [[ -z "${GITHUB_REF:-}" ]]; then
  GITHUB_REF="refs/heads/main"
fi
if [[ -z "${AZURE_BOOTSTRAP_APP_NAME:-}" ]]; then
  AZURE_BOOTSTRAP_APP_NAME="azure-login-github-actions"
fi
if [[ -z "${AZURE_BOOTSTRAP_AUDIENCE:-}" ]]; then
  AZURE_BOOTSTRAP_AUDIENCE="api://AzureADTokenExchange"
fi
if [[ -z "${AZURE_BOOTSTRAP_CREDENTIAL_NAME:-}" ]]; then
  AZURE_BOOTSTRAP_CREDENTIAL_NAME="github-actions-oidc"
fi

command -v az >/dev/null 2>&1 || { echo "ERROR: Azure CLI (az) is required."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "ERROR: jq is required."; exit 1; }

echo "Logging current Azure account and subscription..."
subscriptionId=$(az account show --query id -o tsv)
tenantId=$(az account show --query tenantId -o tsv)

echo "Subscription: $subscriptionId"
echo "Tenant: $tenantId"

existingApp=$(az ad app list --display-name "$AZURE_BOOTSTRAP_APP_NAME" --query '[0]' -o json)
if [[ "$existingApp" == "null" || -z "$existingApp" ]]; then
  echo "Creating app registration '$AZURE_BOOTSTRAP_APP_NAME'..."
  createdApp=$(az ad app create --display-name "$AZURE_BOOTSTRAP_APP_NAME" --sign-in-audience AzureADMyOrg --query '{appId:appId,id:id}' -o json)
  appId=$(echo "$createdApp" | jq -r '.appId')
  appObjectId=$(echo "$createdApp" | jq -r '.id')
else
  appId=$(echo "$existingApp" | jq -r '.appId')
  appObjectId=$(echo "$existingApp" | jq -r '.id')
  echo "Using existing app registration with appId=$appId"
fi

if ! az ad sp show --id "$appId" >/dev/null 2>&1; then
  echo "Creating service principal for appId $appId..."
  az ad sp create --id "$appId" >/dev/null
else
  echo "Service principal already exists for appId $appId"
fi

roleAssignment=$(az role assignment list --assignee "$appId" --scope "/subscriptions/$subscriptionId" --query '[0]' -o json)
if [[ "$roleAssignment" == "null" || -z "$roleAssignment" ]]; then
  echo "Assigning Contributor role to the service principal..."
  az role assignment create --assignee "$appId" --role "Contributor" --scope "/subscriptions/$subscriptionId" >/dev/null
else
  echo "Role assignment already exists for the service principal."
fi

existingCredential=$(az rest --method GET --uri "https://graph.microsoft.com/v1.0/applications/$appObjectId/federatedIdentityCredentials" --query "value[?name=='$AZURE_BOOTSTRAP_CREDENTIAL_NAME'] | [0]" -o json)
if [[ "$existingCredential" == "null" || -z "$existingCredential" ]]; then
  echo "Creating federated identity credential '$AZURE_BOOTSTRAP_CREDENTIAL_NAME'..."
  credentialBody=$(jq -n \
    --arg name "$AZURE_BOOTSTRAP_CREDENTIAL_NAME" \
    --arg issuer "https://token.actions.githubusercontent.com" \
    --arg subject "repo:$GITHUB_REPO:ref:$GITHUB_REF" \
    --arg audience "$AZURE_BOOTSTRAP_AUDIENCE" \
    '{name:$name, issuer:$issuer, subject:$subject, audiences:[$audience]}')
  az rest --method POST --uri "https://graph.microsoft.com/v1.0/applications/$appObjectId/federatedIdentityCredentials" \
    --headers '{"Content-Type":"application/json"}' --body "$credentialBody" >/dev/null
else
  echo "Federated identity credential already exists."
fi

echo
cat <<EOF
Bootstrap complete.

Set the following GitHub secrets for OIDC login:
  AZURE_CLIENT_ID=$appId
  AZURE_TENANT_ID=$tenantId
  AZURE_SUBSCRIPTION_ID=$subscriptionId

Use the demo workflows:
  .github/workflows/azure-login-demo.yml
  .github/workflows/azure-login-demo-powershell.yml
  .github/workflows/azure-login-demo-service-principal.yml
EOF

ghSupported=true
if command -v gh >/dev/null 2>&1 && [[ -n "${GH_TOKEN:-}" ]]; then
  echo "Configuring GitHub secrets using gh..."
  export GH_TOKEN
  gh auth status >/dev/null 2>&1 || true
  gh secret set AZURE_CLIENT_ID --repo "$GITHUB_REPO" --body "$appId"
  gh secret set AZURE_TENANT_ID --repo "$GITHUB_REPO" --body "$tenantId"
  gh secret set AZURE_SUBSCRIPTION_ID --repo "$GITHUB_REPO" --body "$subscriptionId"
  echo "GitHub secrets AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID created."
else
  echo "Skipping GitHub secret sync: gh CLI not found or GH_TOKEN is missing."
fi
