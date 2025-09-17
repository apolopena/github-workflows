# Git Operations Guide

## Commits
- **MANDATORY**: Claude attribution:
  ```bash
  GIT_AUTHOR_NAME="Claude (via USERNAME)" GIT_AUTHOR_EMAIL="USER_GITHUB_EMAIL" GIT_COMMITTER_NAME="Claude (via USERNAME)" GIT_COMMITTER_EMAIL="USER_GITHUB_EMAIL" git commit --no-gpg-sign -m "commit message"
  ```
- Review with `git diff --staged` before committing
- Tell user "Ready to push" after committing

## Workflow Testing
- Test workflows from branch: `gh workflow run NAME.yml --ref BRANCH_NAME -f param=value`
- Check results: `gh run list --workflow=NAME.yml --limit=1`
- View issues: `gh issue view NUMBER`

## GitHub Operations
- **MANDATORY**: Use provenance workflow for all GitHub operations (issues, PRs, comments) instead of direct `gh` commands
- Always specify `--ref BRANCH_NAME` to use current branch implementation

## Key Learning
Without `--ref BRANCH_NAME`, workflows run from main branch even when you're on different branch locally.