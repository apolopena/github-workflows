# Git
- keep commit messages very brief while remaning informative
- If you have not already, read guides/GIT.md
# IDE Code Editor Diff Tool
- Always attempt to trigger IDE diff viewer for edits (try Write tool if Edit/MultiEdit fail)
- Wait for user to either accept/reject changes via IDE interface or terminal prompt
- If no diff opens, retry with different edit tool or ask user to reload the IDE
- User inline edits are only preserved when using IDE "Accept Changes" button (not terminal prompts) - see issue #1317 in the github.com/anthropics repository
- This behavior may change in future Claude Code updates