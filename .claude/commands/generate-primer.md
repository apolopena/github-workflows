---
description: Generate a session primer in an auto-incremented file with latest.md symlink

First, find the highest numbered session file in .claude/session_primers/ (e.g., session_0005.md), then create the next incremented file (e.g., session_0006.md). After writing the file, create or update a symlink from .claude/session_primers/latest.md to point to the new session file.

Generate a comprehensive session primer covering our current work, key decisions made. Structure it in 2-3 focused paragraphs that would allow a fresh Claude instance to continue this work in an efficient manner. Add a final paragraph for next steps if they were concretely defined. Format with headers and bullets (if needed).

