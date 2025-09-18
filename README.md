# Reusable GitHub Workflows

Collection of reusable GitHub Actions workflows for automation across repositories.

## Available Workflows

- **[provenance.yml](docs/provenance.md)** - GitHub App-authenticated actions with transparent AI attribution

## Quick Start

Reference workflows from your repository:

```yaml
jobs:
  example:
    uses: apolopena/github-workflows/.github/workflows/provenance.yml@main
    with:
      action: "open-issue"
      provenance_label: "Claude_AI"
      title: "Example issue"
    secrets:
      PROVENANCE_APP_ID: ${{ secrets.PROVENANCE_APP_ID }}
      PROVENANCE_APP_PRIVATE_KEY: ${{ secrets.PROVENANCE_APP_PRIVATE_KEY }}
      PROVENANCE_INSTALLATION_ID: ${{ secrets.PROVENANCE_INSTALLATION_ID }}
```

See [examples/](./examples/) for complete templates.

## License

[MIT](LICENSE)