#!/bin/bash
# This script validates the bootstrap automation without requiring actual Azure credentials
# Run this locally to verify everything is configured correctly

set -euo pipefail

echo "================================"
echo "Azure Login Bootstrap Validator"
echo "================================"
echo ""

# Check 1: Script exists and is executable
echo "[Check 1] Bootstrap script exists..."
if [[ -x "scripts/bootstrap-azure-login.sh" ]]; then
    echo "✅ scripts/bootstrap-azure-login.sh exists and is executable"
else
    echo "❌ Bootstrap script missing or not executable"
    exit 1
fi

# Check 2: Workflow file exists and is valid YAML
echo "[Check 2] Bootstrap workflow exists..."
if [[ -f ".github/workflows/azure-login-bootstrap.yml" ]]; then
    echo "✅ .github/workflows/azure-login-bootstrap.yml exists"
else
    echo "❌ Bootstrap workflow missing"
    exit 1
fi

# Check 3: Validate YAML syntax
echo "[Check 3] Validating YAML syntax..."
if command -v python3 &> /dev/null; then
    if python3 -c "import yaml; yaml.safe_load(open('.github/workflows/azure-login-bootstrap.yml'))" 2>/dev/null; then
        echo "✅ YAML is valid"
    else
        echo "❌ YAML syntax error"
        exit 1
    fi
else
    echo "⚠️  Python3 not available, skipping YAML validation"
fi

# Check 4: Bash script syntax
echo "[Check 4] Validating bash syntax..."
if bash -n scripts/bootstrap-azure-login.sh 2>/dev/null; then
    echo "✅ Bash script syntax is valid"
else
    echo "❌ Bash syntax error"
    exit 1
fi

# Check 5: Documentation files
echo "[Check 5] Documentation files..."
docs=(
    "AZURE_CONNECTION_GUIDE.md"
    "SETUP_INSTRUCTIONS.md"
    "BOOTSTRAP_QUICKSTART.md"
)
for doc in "${docs[@]}"; do
    if [[ -f "$doc" ]]; then
        echo "✅ $doc found"
    else
        echo "❌ $doc missing"
        exit 1
    fi
done

# Check 6: Demo workflows
echo "[Check 6] Demo workflows..."
demos=(
    ".github/workflows/azure-login-demo.yml"
    ".github/workflows/azure-login-demo-powershell.yml"
    ".github/workflows/azure-login-demo-service-principal.yml"
)
for demo in "${demos[@]}"; do
    if [[ -f "$demo" ]]; then
        echo "✅ $demo found"
    else
        echo "⚠️  $demo not found (optional)"
    fi
done

# Check 7: Git status
echo "[Check 7] Git repository..."
if git rev-parse --git-dir > /dev/null 2>&1; then
    status=$(git status --porcelain)
    if [[ -z "$status" ]]; then
        echo "✅ Working tree is clean"
    else
        echo "⚠️  Uncommitted changes detected"
    fi
    
    # Show recent commits
    echo "Recent commits:"
    git log --oneline -3 | sed 's/^/  /'
else
    echo "⚠️  Not a git repository"
fi

echo ""
echo "================================"
echo "✅ All checks passed!"
echo "================================"
echo ""
echo "Next steps:"
echo "1. Read AZURE_CONNECTION_GUIDE.md"
echo "2. Follow the 5 action items"
echo "3. Run 'Azure Login Bootstrap' workflow"
echo "4. Test with 'Azure Login Demo' workflow"
echo ""
