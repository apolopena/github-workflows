# MANDATORY RULES - NO EXCEPTIONS
- NEVER use direct GitHub CLI commands (gh issue, gh pr, etc.)
- ALL GitHub operations MUST use: gh workflow run provenance.yml
- This includes: open-issue, issue-comment, pr-comment, pr-code, open-pr

  # Code Analysis and Trouble Shooting
  - READ the code logic before proposing tests
  - Think more carefully through each step before proposing solutions, look at code in depth when troubleshooting.

# Git
- keep commit messages very brief while remaning informative. Never add attribution of any kind in a git commit!
- If you have not already, read guides/GIT.md

# Git Personas (AI Usage)
- ALWAYS start git work with: `source scripts/git-personas.zsh && persona_ai`
- Stay as AI for entire git workflow (commits/pushes/pulls, Etc.)
- ALWAYS end git work: `source scripts/git-personas.zsh && persona_human`
- Claude Code uses snapshot shell environment - MUST use inline sourcing pattern above

# IDE Code Editor Diff Tool
- Always use your MutiEdit tool. Know that the MultiEditTool can fail to open the diff tool in the users IDE.
- If no diff opens, retry with different edit tool or ask user to reload the IDE
- Remind the user inline edits are only preserved when using IDE "Accept Changes" button (not terminal prompts) - see issue #1317 in the github.com/anthropics repository
- This behavior may change in future Claude Code updates