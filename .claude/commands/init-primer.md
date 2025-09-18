---
description: Load project context efficiently with minimal output
---

Silent context loading for fresh Claude sessions. Reads guides, latest primer, core files, and git state without verbose terminal output.

**Process:**
1. Load `.claude/guides/*.md`
2. Read latest session primer
3. Scan core workflows and docs
4. Check git status/commits

**Benefits:**
- Full project understanding
- Current work context
- Clean terminal output
- Ready to continue work

Use `/init-primer` to quietly establish complete project context.