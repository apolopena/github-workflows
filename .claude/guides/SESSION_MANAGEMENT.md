# Session Management Guide

## Session Primers vs Development Guides

### Session Primers
- **Purpose**: Emergency context recovery for incomplete work
- **When to use**: Context exhausted but task not finished
- **Lifecycle**: Temporary bridge, can become obsolete when work completes
- **Location**: `.claude/session_primers/session_NNNN.md`
- **Content**: Current state, recent decisions, next steps for specific work

### Development Guides
- **Purpose**: Permanent institutional knowledge
- **When to use**: Always - foundational principles for all work
- **Lifecycle**: Living documents that evolve with project learning
- **Location**: `.claude/guides/TOPIC_NAME.md`
- **Content**: Distilled patterns, rules, and wisdom from all sessions

## Workflow
1. **During work**: Follow development guides for consistent behavior
2. **Context full + work incomplete**: Generate session primer for handoff
3. **After work complete**: Update guides with new patterns learned
4. **Fresh session**: Read guides for foundational knowledge, primers only if continuing incomplete work

## Session Primer Generation

When context approaches capacity (97%+), generate a session primer:

**Prompt:**
Generate a comprehensive session primer covering our current work, key decisions made. Structure it in 2-3 focused paragraphs that would allow a fresh Claude instance to continue this work seamlessly." Add a final paragraph for next steps if they were concretely defined. Format with headers and bullets (if needed)

**Save location:** `.claude/session_primers/session_NNNN.md` (increment number)

## Key Principle
**Session primers are for continuity, guides are for competency.**

Guides are the source of truth for how to work in this project. Session primers are temporary scaffolding when work spans multiple context windows.