# Development Guidelines for GitHub Workflows Codebase

When making changes to this provenance-tracking GitHub Actions workflow repository:

## Security First
- Never commit secrets, tokens, or credentials
- Preserve the provenance attribution mechanism - every action must maintain audit trail
- Validate all user inputs in bash scripts using proper parameter expansion (`${VAR:-}`)
- Keep defensive scripting patterns: `set -euo pipefail`, proper quoting, error handling

## Scope Discipline
- Only implement changes directly requested in the current task
- Resist refactoring, optimization, or "improvements" beyond the specific requirement
- Do not add features, fix unrelated issues, or enhance code unless explicitly asked
- Stay focused on the minimal change needed to satisfy the current request

## Testing Protocol
1. Use `plan_only: true` for dry-run validation before live changes
2. Test via `provenance-test.yml` workflow with manual dispatch
3. Verify all 5 action types: `open-issue`, `issue-comment`, `pr-comment`, `pr-code`, `open-pr`
4. Test edge cases: missing parameters, malformed inputs, cross-repo operations

## Code Patterns
- Follow existing bash style: function extraction to `common.sh`, consistent error messages
- Maintain workflow input/output contracts - breaking changes require version bumps
- Use `jq` for JSON manipulation, `curl` for API calls with proper headers
- Keep scripts executable (`chmod +x`) and add descriptive comments for complex logic

## Alias Naming
Use brief but self-documenting alias names. Balance brevity with clarity - `cl-backup-settings` over `cl_backup` or `claude-backup-settings-to-timestamped-folder`.

## Change Workflow
1. Read existing docs and understand current behavior
2. Make minimal, focused changes that preserve backward compatibility
3. Update `docs/provenance.md` if adding new features or changing inputs
4. Test thoroughly using the test workflow before considering complete

## Documentation
- Update input/output tables in docs for any new parameters
- Provide working examples for new action types
- Keep README.md current with usage patterns

## Development Philosophy
- Make targeted changes that align with existing patterns and architecture
- Prioritize security, auditability, and reliability in all modifications
- Edit existing code when needed to meet requirements, but preserve the core design principles
- Maintain consistency with established conventions while implementing requested functionality