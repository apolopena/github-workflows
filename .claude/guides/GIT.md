# Git Operations Guide

## Commits
- **MANDATORY**: Claude attribution:
  ```bash
  GIT_AUTHOR_NAME="Claude (via $(git config --get user.name))" GIT_AUTHOR_EMAIL="$(git config --get user.email)" GIT_COMMITTER_NAME="Claude (via $(git config --get user.name))" GIT_COMMITTER_EMAIL="$(git config --get user.email)" git commit --no-gpg-sign -m "commit message"
  ```
- Review with `git diff --staged` before committing
- Tell user "Ready to push" after committing
- Tell user "Ready to pull"  when a pull is needed

## Workflow Testing
- Test workflows from branch: `gh workflow run NAME.yml --ref BRANCH_NAME -f param=value`
- Check results: `gh run list --workflow=NAME.yml --limit=1`
- View issues: `gh issue view NUMBER`

## GitHub Operations
- **MANDATORY**: Use `gh workflow run provenance.yml` for these actions:
  - `open-issue`, `issue-comment`, `pr-comment`, `pr-code`, `open-pr`
- Never use direct `gh issue`, `gh pr` commands
- Always include `--ref BRANCH_NAME` and `-f provenance_label=Claude_AI`

## Key Learning
Without `--ref BRANCH_NAME`, workflows run from main branch even when you're on different branch locally.