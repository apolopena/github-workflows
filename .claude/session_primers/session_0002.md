Based on my analysis of the repository and recent work, here's a comprehensive session primer:

# Provenance Workflow Development Session Primer

## Current Work Context

We are working on the `provenance_label` branch of a GitHub Actions reusable workflow repository that implements transparent AI provenance stamping for GitHub operations. The main deliverable is `.github/workflows/provenance.yml` - a comprehensive reusable workflow that allows any repository to perform GitHub App-attributed actions (issues, PRs, comments) while maintaining explicit provenance tracking. The workflow enforces transparent attribution by requiring a `provenance_label` input that identifies whether actions are performed by AI agents or humans, preventing AI from operating under disguised human attribution.

## Key Technical Implementation

The workflow architecture consists of three main components: the main workflow file (`provenance.yml`) that handles input validation and orchestration, supporting shell scripts in `.github/scripts/` that perform the actual GitHub API operations, and a comprehensive documentation system in `docs/provenance.md`. The workflow supports five primary actions: `open-issue`, `issue-comment`, `pr-comment`, `pr-code`, and `open-pr`. Authentication is handled through GitHub App installation tokens using `tibdex/github-app-token@v2`, with required secrets `PROVENANCE_APP_ID`, `PROVENANCE_APP_PRIVATE_KEY`, and `PROVENANCE_INSTALLATION_ID`. The `common.sh` script includes a sophisticated `provenance_block()` function that generates different HTML attribution blocks based on whether the provenance label is "human" (simple attribution) or any other value (full AI provenance with HTML comments). Recent commits have focused on enhancing the provenance badging system with conditional HTML formatting, fixing newline handling in body text, and moving provenance blocks to the bottom of content for better visual hierarchy.

## Recent Development Progress  

The latest changes include removing test workflows and consolidating to the main production workflow, implementing robust error handling and input validation, and creating comprehensive documentation. The current git status shows staged deletions of `.claude/DEVELOPMENT.md`, `.claude/GIT.md`, and `.github/workflows/provenance-test.yml`, with modifications to the main workflow file and several untracked `.claude/` directories containing development tooling. The branch has been successfully merged into main via PR #7, indicating the core functionality is stable and production-ready. The workflow now includes a `plan_only` mode for dry-run testing and comprehensive input validation for all supported GitHub operations.
