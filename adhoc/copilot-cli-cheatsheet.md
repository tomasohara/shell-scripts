# GitHub Copilot CLI Cheatsheet

## Global Shortcuts

| Shortcut | Description |
|----------|-------------|
| `@` | Mention files, include contents in context |
| `Ctrl+S` | Run command while preserving input |
| `Shift+Tab` | Cycle modes (interactive → plan) |
| `Ctrl+T` | Toggle model reasoning display |
| `Ctrl+O` | Expand recent timeline (when no input) |
| `Ctrl+E` | Expand all timeline (when no input) |
| `↑` / `↓` | Navigate command history |
| `!` | Execute command in local shell (bypass Copilot) |
| `Esc` | Cancel the current operation |
| `Ctrl+C` | Cancel operation / clear input / exit |
| `Ctrl+D` | Shutdown |
| `Ctrl+L` | Clear the screen |
| `Ctrl+X → Ctrl+E` | Edit prompt in `$VISUAL`/`$EDITOR` |

## Editing Shortcuts

| Shortcut | Description |
|----------|-------------|
| `Ctrl+A` | Move to beginning of line |
| `Ctrl+E` | Move to end of line |
| `Ctrl+H` | Delete previous character |
| `Ctrl+W` | Delete previous word |
| `Ctrl+U` | Delete from cursor to beginning of line |
| `Ctrl+K` | Delete from cursor to end of line |
| `Meta+←` / `Meta+→` | Move cursor by word |

## Slash Commands

### Agent Environment

| Command | Description |
|---------|-------------|
| `/init` | Initialize Copilot instructions for this repository |
| `/agent` | Browse and select from available agents |
| `/skills` | Manage skills for enhanced capabilities |
| `/mcp` | Manage MCP server configuration |
| `/plugin` | Manage plugins and plugin marketplaces |

### Models and Subagents

| Command | Description |
|---------|-------------|
| `/model` | Select AI model to use |
| `/fleet` | Enable fleet mode for parallel subagent execution |
| `/tasks` | View and manage background tasks (subagents and shell sessions) |

### Code

| Command | Description |
|---------|-------------|
| `/ide` | Connect to an IDE workspace |
| `/diff` | Review the changes made in the current directory |
| `/review` | Run code review agent to analyze changes |
| `/lsp` | Manage language server configuration |
| `/terminal-setup` | Configure terminal for multiline input support |

### Permissions

| Command | Description |
|---------|-------------|
| `/allow-all` | Enable all permissions (tools, paths, and URLs) |
| `/add-dir` | Add a directory to the allowed list for file access |
| `/list-dirs` | Display all allowed directories for file access |
| `/cwd` | Change working directory or show current directory |
| `/reset-allowed-tools` | Reset the list of allowed tools |

### Session

| Command | Description |
|---------|-------------|
| `/resume` | Switch to a different session (optionally specify session ID) |
| `/rename` | Rename the current session |
| `/context` | Show context window token usage and visualization |
| `/usage` | Display session usage metrics and statistics |
| `/session` | Show session info and workspace summary |
| `/compact` | Summarize conversation history to reduce context window usage |
| `/share` | Share session or research report to markdown file or GitHub gist |

### Help and Feedback

| Command | Description |
|---------|-------------|
| `/help` | Show help for interactive commands |
| `/changelog` | Display changelog for CLI versions |
| `/feedback` | Provide feedback about the CLI |
| `/theme` | View or configure terminal theme |
| `/update` | Update the CLI to the latest version |
| `/experimental` | Show/enable/disable experimental features |
| `/clear` | Clear the conversation history |
| `/instructions` | View and toggle custom instruction files |
| `/streamer-mode` | Toggle streamer mode (hides preview model names and quota details) |

### Other Commands

| Command | Description |
|---------|-------------|
| `/exit`, `/quit` | Exit the CLI |
| `/login` | Log in to Copilot |
| `/logout` | Log out of Copilot |
| `/plan` | Create an implementation plan before coding |
| `/research` | Run deep research investigation using GitHub search and web sources |
| `/user` | Manage GitHub user list |

## Custom Instructions Locations

Copilot reads instructions from these files (in order):

- `CLAUDE.md` (in git root & cwd)
- `GEMINI.md` (in git root & cwd)
- `AGENTS.md` (in git root & cwd)
- `.github/instructions/**/*.instructions.md` (in git root & cwd)
- `.github/copilot-instructions.md`
- `$HOME/.copilot/copilot-instructions.md`
- `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` (additional directories via env var)

## Credits

Via Github copilot using Claude Opus 4.6

## TODO

Get Claude to flesh this out!
