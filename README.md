# GitHub Workflows

Reusable GitHub Actions workflows and helper scripts for automation.

## Structure

.github/workflows/   # Reusable workflows (workflow_call)  
.github/scripts/     # Helper shell scripts used by workflows  
examples/            # Example caller workflows (templates, not active here)  
docs/                # Usage docs and input/output references  

## Usage

Reference a workflow from this repo in another repository:

```yaml
jobs:
  dispatch:
    uses: apolopena/github-workflows/.github/workflows/ai-dispatch.yml@main
    with:
      # example input
      action: "open-issue"
    secrets:
      AI_APP_PRIVATE_KEY: ${{ secrets.AI_APP_PRIVATE_KEY }}
```

See `examples/caller.ai.yml` for a minimal template.

## Notes

- Workflows here are **reusable only** — they won’t run automatically in this repo.  
- Helper scripts under `.github/scripts/` must remain executable (`chmod +x`).  
- Secrets are **never stored in this repo**. Only secret _labels_ appear in workflows; values must be configured in the caller repo.  
- Docs live in `docs/` for each workflow with usage details and input/output references.  

## License

[MIT](LICENSE)
