# Reusable GitHub Workflows

Collection of reusable GitHub Actions workflows for automation across repositories.

## Available Workflows

- **[provenance.yml](docs/provenance.md)** - GitHub App-authenticated actions with transparent AI attribution

### Complete Provenance Workflow / GitHub App Setup Guide

  Step 1: Create a GitHub App

  1. Go to https://github.com/settings/apps → New GitHub App
  2. Fill in: App name, Homepage URL, uncheck "Webhook Active"
  3. Set Permissions (Repository permissions):
    - Contents: Read
    - Issues: Read & write
    - Pull requests: Read & write
  4. Click Create GitHub App
  5. Save your App ID (shown on the About page)

  Step 2: Generate & Save Private Key

  1. Scroll to "Private keys" → "Generate a private key"
  2. Open the downloaded .pem file, copy ALL contents
  3. Store contents in password manager (you'll reuse for all repos)
  4. Delete the .pem file

 Step 3: Install the App & Choose Repo Access

  1. Go to https://github.com/settings/apps
  2. Click on your app name in the list
  3. In the left sidebar menu (on the app's settings page), click "Install App"
  4. You'll see your account/org listed - click the "Install" button next to it
  5. Choose repository access:
    - ⭕ All repositories (app works in all current & future repos), OR
    - ⭕ Only select repositories (check the boxes for specific repos)
  6. Click "Install" (green button at bottom)

  To modify later: https://github.com/settings/installations → Configure → change "Repository access"

  Step 4: Find Installation ID

  1. Go to https://github.com/settings/installations
  2. Click gear icon ⚙️ next to your app
  3. Copy the number from URL: https://github.com/settings/installations/XXXXXX

  Step 5: Add Secrets to Each Repo

  Go to repo → Settings → Secrets and variables → Actions → New repository secret:

  - PROVENANCE_APP_ID → App ID from Step 1
  - PROVENANCE_APP_PRIVATE_KEY → PEM contents from Step 2 (same for all repos)
  - PROVENANCE_INSTALLATION_ID → Installation ID from Step 4

  Step 6: Copy Workflow Files

  ### Copy scripts
  mkdir -p .github/scripts
  cp /path/to/github-workflows/.github/scripts/* .github/scripts/
  chmod +x .github/scripts/*.sh

  ### Copy workflow (works as-is)
  mkdir -p .github/workflows
  cp /path/to/github-workflows/.github/examples/caller.ai.yml .github/workflows/ai-dispatch.yml

  Step 7: Test with Dry Run

  ### Dry run test - previews without making changes
  gh workflow run ai-dispatch.yml \
    -f action=open-issue \
    -f provenance_label=AI_CODING_ASSISTANT \
    -f title="Test Issue" \
    -f body="Testing workflow" \
    -f plan_only=true

  ### Watch the run
  gh run watch

  ✅ Done! Once dry run succeeds, use plan_only=false (or omit it) to create actual issues/PRs.

  ---
 #### Quick Reference

  - Reuse across repos: Same App ID, PEM, and Installation ID for all reposModify 
  - repo access: https://github.com/settings/installations → Configure → Repository
  - Access troubleshooting 403: App not installed on repo or missing permissions troubleshooting
    - 401: Check all three secrets match the same appSecurity
    - Store PEM in password manager, never commit secrets

## License

[MIT](LICENSE)
