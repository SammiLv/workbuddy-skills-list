# Source Notes

Use these local files as evidence for weekly WorkBuddy summaries:

- `~/.workbuddy/memory/YYYY-MM-DD.md`: Daily memory files. WorkBuddy appends a brief note here after completing substantive work each session. These are the primary source of truth for weekly summaries.
- `~/.workbuddy/memory/MEMORY.md`: Long-term curated memory. Contains user preferences, project conventions, and distilled notes from older daily files. Read this for background context.
- Workspace-specific memory may also exist at `{workspace}/.workbuddy/memory/YYYY-MM-DD.md` if the user works across multiple projects.

Useful content patterns in daily files:

- Task descriptions and outcomes: what was built, fixed, or written.
- File paths and artifact names: deliverables created or modified.
- Technical decisions: which framework, pattern, or approach was chosen.
- User preferences and conventions noted during the session.

Filtering guidance:

- Skip transient information: intermediate search results, temporary file paths, tool errors.
- Only surface information with lasting value: completed work, key decisions, artifacts.
- If a daily file is empty or missing, that date had no substantive WorkBuddy work.
- Treat MEMORY.md as background context, not as a daily activity log.
