# provenance.yml — A Reusable GitHub Workflow for Provenance Stamping 

Reusable GitHub Actions workflow that lets any repo perform **GitHub App–attributed** actions (issues, PRs, comments) via a single, generic App.  
It mints an installation token, sanity-checks access, and executes the requested action through helper scripts.

---

## Key Purpose

This workflow enforces **transparent attribution of activity**.  
- Every action must declare a `provenance_label` to show who or what performed the work.  
- Examples: `Claude_AI` (Claude, Codex, etc.) or `human`.  
- By requiring this label, AI agents cannot perform GitHub actions disguised under a human username — provenance is always explicit.

---

## How it works (quick flow)

1) `tibdex/github-app-token@v2` mints a short-lived **installation token** for your App.  
2) `.github/scripts/sanity.sh` verifies token validity and that the target repo is visible.  
3) `.github/scripts/dispatch_action.sh` performs the requested action (issue/PR/comment), tagging provenance.

---

## Inputs

| Name            | Type    | Required | Description |
|-----------------|---------|----------|-------------|
| `action`        | string  | yes      | One of: `open-issue`, `issue-comment`, `pr-comment`, `pr-code`, `open-pr` |
| `provenance_label` | string | yes   | Caller-supplied provenance marker (e.g., `AI_CODING_ASSISTANT`) |
| `target_repo`   | string  | no       | `owner/repo`. Defaults to the **caller** repo if omitted. |
| `number`        | string  | no       | Issue/PR number for comment actions. |
| `title`         | string  | no       | Title for `open-issue` or `open-pr`. |
| `body`          | string  | no       | Body text for issues/comments/PRs. |
| `base`          | string  | no       | Base branch for `open-pr`. |
| `head`          | string  | no       | Head branch for `open-pr` (e.g., `user:feature-branch`). |
| `draft`         | string  | no       | `"true"` or `"false"` for draft PRs (defaults to `"false"`). |
| `plan_only`     | boolean | no       | When `true`, prints the intended call and **exits without changes**. |

---

## Required Secrets (in the **caller** repo/org)

| Secret                 | Meaning |
|------------------------|---------|
| `AI_APP_ID`            | Your GitHub App ID (integer). |
| `AI_APP_PRIVATE_KEY`   | The App’s PEM private key (multi-line). |
| `AI_INSTALLATION_ID`   | The installation ID for the org/repo. |

> These are **labels only** in YAML; the secret values live in the caller’s settings.

---

## Permissions

The job requests:
- `contents: read`
- `issues: write`
- `pull-requests: write`

Your GitHub App must also have the corresponding **App permissions** enabled and be **installed** on the target repository/org.

---

## Environment passed to scripts

`ai-dispatch.yml` sets:

- `TOKEN` — GitHub App installation token (via tibdex action)
- `REPO` — `inputs.target_repo` or defaults to `${{ github.repository }}`
- `ACT`, `NUM`, `TITLE`, `BODY`, `BASE`, `HEAD`, `DRAFT`, `ACTOR`, `PROV_LABEL`

The scripts source `.github/scripts/common.sh` for shared helpers.

---

## Supported actions & examples

### 1) Open an issue
- **Input**: `action=open-issue`, `title`, optional `body`, optional `target_repo`
- **Effect**: `POST /repos/{repo}/issues` (labels with `"ai"`), provenance block prepended.

**Caller example:**

```yaml
jobs:
  call:
    uses: apolopena/github-workflows/.github/workflows/ai-dispatch.yml@main
    with:
      action: open-issue
      provenance_label: AI_CODING_ASSISTANT
      title: "Investigate flaky CI"
      body: "Repro steps..."
```

**Equivalent gh CLI call:**
```bash
gh workflow run ai-dispatch.yml \
 -f action=open-issue \
 -f provenance_label=AI_CODING_ASSISTANT \
 -f title="Investigate flaky CI" \
 -f body="Repro steps..."
```

### 2) Comment on an issue
- **Input**: `action=issue-comment`, `number`, `body`
- **Effect**: `POST /repos/{repo}/issues/{number}/comments`

**Caller example:**

```yaml
with:
  action: issue-comment
  provenance_label: AI_CODING_ASSISTANT
  number: "42"
  body: "Thanks for the report — queued for triage."
```

**Equivalent gh CLI call:**
```bash
gh workflow run ai-dispatch.yml \
 -f action=issue-comment \
 -f provenance_label=AI_CODING_ASSISTANT \
 -f number=42 \
 -f body="Thanks for the report — queued for triage."
```

### 3) Comment on a PR
- **Input**: `action=pr-comment`, `number`, `body`
- **Effect**: `POST /repos/{repo}/issues/{number}/comments` (PRs share the Issues API for comments)

**Caller example:**

```yaml
with:
  action: pr-comment
  provenance_label: AI_CODING_ASSISTANT
  number: "128"
  body: "LGTM pending one small tweak."
```

**Equivalent gh CLI call:**
```bash
gh workflow run ai-dispatch.yml \
 -f action=pr-comment \
 -f provenance_label=AI_CODING_ASSISTANT \
 -f number=128 \
 -f body="LGTM pending one small tweak."
```

### 4) Post a code block comment on a PR
- **Input**: `action=pr-code`, `number`, `body`
- **Effect**: Formats `body` inside a fenced code block (diff) with a provenance header.

**Caller example:**

```yaml
with:
  action: pr-code
  provenance_label: AI_CODING_ASSISTANT
  number: "128"
  body: |
    --- a/app.js
    +++ b/app.js
    @@
    - console.log('debug');
    + // removed debug
```

**Equivalent gh CLI call:**
```bash
gh workflow run ai-dispatch.yml \
 -f action=pr-code \
 -f provenance_label=AI_CODING_ASSISTANT \
 -f number=128 \
 -f body=$'--- a/app.js\n+++ b/app.js\n@@\n- console.log(\'debug\');\n+ // removed debug'
```

### 5) Open a PR
- **Input**: `action=open-pr`, `title`, `base`, `head`, optional `body`, optional `draft`
- **Effect**: `POST /repos/{repo}/pulls`

**Caller example:**

```yaml
with:
  action: open-pr
  provenance_label: AI_CODING_ASSISTANT
  title: "feat: add dispatch helpers"
  base: "main"
  head: "user:feature/dispatch-helpers"
  draft: "false"
```

**Equivalent gh CLI call:**
```bash
gh workflow run ai-dispatch.yml \
 -f action=open-pr \
 -f provenance_label=AI_CODING_ASSISTANT \
 -f title="feat: add dispatch helpers" \
 -f base=main \
 -f head=user:feature/dispatch-helpers \
 -f draft=false
```

---

## Dry-run planning

Set `plan_only: true` to preview the exact API endpoints that would be called.  
The workflow prints the plan and stops before making changes.

```yaml
with:
  action: open-issue
  provenance_label: AI_CODING_ASSISTANT
  title: "Test only"
  plan_only: true
```

**Equivalent gh CLI call:**
```bash
gh workflow run ai-dispatch.yml \
 -f action=open-issue \
 -f provenance_label=AI_CODING_ASSISTANT \
 -f title="Test only" \
 -f plan_only=true
```

---

## Caller template

See [`examples/caller.ai.yml`](../examples/caller.ai.yml) for a minimal workflow-dispatch caller.  
Pin to a tag or commit for stability (e.g., `@v1` or `@<sha>`), not `@main`, in production.

---

## Troubleshooting

- **403 / Not Found on repo API calls**  
  Ensure the GitHub App is **installed** on the target repo/org and has the **Issues** / **Pull requests** permissions.

- **401 / Bad credentials**  
  Check that `AI_APP_ID`, `AI_APP_PRIVATE_KEY`, and `AI_INSTALLATION_ID` are correct and belong to the **same** GitHub App.

- **`jq: command not found`**  
  The scripts use `jq`. On `ubuntu-latest` it’s typically available; if not, add a setup step:  
  ```yaml
  - run: sudo apt-get update && sudo apt-get install -y jq
  ```

- **Provenance missing actor or label**  
  Ensure both `ACTOR` and `PROV_LABEL` envs are set (the workflow already does this).

---

## Security Model

- Workflow code here is public; **secrets remain in caller repos**.  
- Actions execute **as your GitHub App** via its installation token.  
- The provenance block records both the `github.actor` and the required `provenance_label` for auditability.

---
