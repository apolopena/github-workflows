# git-personas vs provenance.yml Integration Analysis

## Current State

### git-personas System
- **Purpose**: AI/human attribution through git identity and signing
- **Method**: Switches git config (user.name, user.email, signing keys, SSH transport)
- **Attribution**: Built into git commits via author/committer/signer metadata
- **Scope**: Per-repository configuration
- **Usage**: Direct git operations (commit, push, pull)

### provenance.yml Workflow
- **Purpose**: GitHub operations through standardized workflow calls
- **Method**: GitHub Actions workflow that handles issue/PR/comment operations
- **Attribution**: Handled by GitHub Actions context and workflow logs
- **Scope**: Repository-wide GitHub automation
- **Usage**: `gh workflow run provenance.yml` for all GitHub ops

## Integration Scenarios

### Scenario 1: Pure git-personas (Local Git Work)
**Use git-personas when**:
- Making direct commits and pushes
- Working with local git history
- Need immediate git operations without workflow overhead
- Want commit-level attribution in git log

**Pros**:
- Immediate, no workflow delay
- Clear git-level attribution
- Works offline
- Direct SSH key usage

**Cons**:
- No GitHub operation audit trail
- Manual git operations
- Bypasses repository governance workflows

### Scenario 2: Pure provenance.yml (GitHub Operations)
**Use provenance.yml when**:
- Creating issues, PRs, comments
- Need audit trail of GitHub operations
- Want standardized workflow governance
- Working within established repository processes

**Pros**:
- Complete audit trail in GitHub Actions
- Consistent operation patterns
- Repository governance compliance
- Centralized GitHub API usage

**Cons**:
- Workflow execution overhead
- Not suitable for direct git commits
- Requires GitHub Actions environment

### Scenario 3: Hybrid Approach (Recommended)
**git-personas for**: Local development and commits
```bash
# AI does development work
source ~/.zsh/git-personas.zsh && persona_ai
git add feature.md
git commit -m "Add new feature"
git push
```

**provenance.yml for**: GitHub operations
```bash
# AI creates PR after pushing commits
gh workflow run provenance.yml -f action=open-pr -f title="New feature" -f body="Description"
```

## Decision Matrix

| Operation | git-personas | provenance.yml | Recommended |
|-----------|--------------|----------------|-------------|
| git commit | ✅ Perfect fit | ❌ Not applicable | git-personas |
| git push | ✅ Direct | ❌ Not applicable | git-personas |
| Create PR | ❌ Manual process | ✅ Automated | provenance.yml |
| Issue comments | ❌ Manual | ✅ Standardized | provenance.yml |
| Local development | ✅ Essential | ❌ Not applicable | git-personas |
| Audit requirements | ⚠️ Git log only | ✅ Full trail | provenance.yml |

## Workflow Integration Patterns

### Pattern 1: Sequential (AI Development → GitHub Operations)
```bash
# 1. AI development work
source ~/.zsh/git-personas.zsh && persona_ai
# ... make commits and push ...

# 2. GitHub operations via workflow
source ~/.zsh/git-personas.zsh && persona_human
gh workflow run provenance.yml -f action=open-pr

# 3. Back to human for review/approval
```

### Pattern 2: Role-Based
- **AI persona + git-personas**: All development commits
- **Human persona + provenance.yml**: All GitHub management operations
- **Clear separation**: AI codes, human manages

### Pattern 3: Context-Aware
- **Internal development**: git-personas for speed
- **External contributions**: provenance.yml for governance
- **Audit-heavy repos**: Always use provenance.yml
- **Personal repos**: git-personas sufficient

## Pros and Cons Analysis

### git-personas Advantages
- **Speed**: Immediate git operations
- **Clarity**: Direct git attribution
- **Simplicity**: Standard git workflow
- **Offline capable**: Works without GitHub
- **Token efficient**: Minimal overhead

### git-personas Disadvantages
- **Limited scope**: Only git operations
- **No GitHub audit**: Missing workflow logs
- **Manual process**: No automation for GitHub ops
- **Bypass governance**: Skips repository workflows

### provenance.yml Advantages
- **Complete audit**: Full GitHub Actions logs
- **Standardized**: Consistent operation patterns
- **Governance**: Enforces repository rules
- **Automation**: Can trigger other workflows
- **GitHub native**: Proper API usage

### provenance.yml Disadvantages
- **Overhead**: Workflow execution time
- **Complexity**: Additional abstraction layer
- **GitHub dependent**: Requires Actions environment
- **Not for git**: Doesn't handle commits/pushes

## Recommendations

### Primary Decision: Use Both, Different Purposes
- **git-personas**: For all git operations (commit, push, pull, merge)
- **provenance.yml**: For all GitHub operations (issues, PRs, comments)

### Implementation Strategy
1. **Always start with git-personas** for commit attribution
2. **Use provenance.yml** for subsequent GitHub management
3. **Document the pattern** in CLAUDE.md for consistency
4. **Consider repo governance** - some repos may require provenance.yml for everything

### CLAUDE.md Integration
```markdown
# Git Operations Strategy
- Direct git work: Use git-personas for clear attribution
- GitHub management: Use provenance.yml for audit trail
- AI commits: Always use persona_ai before commits
- Human oversight: Use persona_human + provenance.yml for PR/issue management
```

## Open Questions

1. **Should provenance.yml handle git commits too?**
   - Pro: Complete audit trail
   - Con: Workflow overhead, complexity

2. **How to handle emergency situations?**
   - Direct git-personas for speed vs provenance.yml for governance

3. **Repository-specific policies?**
   - Some repos may mandate provenance.yml for everything
   - Others may prefer git-personas efficiency

4. **Automation integration?**
   - Can git-personas trigger provenance.yml workflows?
   - Should commit hooks enforce persona usage?

## Next Steps

1. **Test hybrid patterns** with real development scenarios
2. **Document decision criteria** for when to use each approach
3. **Create workflow templates** that combine both systems
4. **Establish repository governance** guidelines
5. **Consider automation** to bridge the two systems