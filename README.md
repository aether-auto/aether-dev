# aether-dev

A Claude Code plugin that provides a complete software development workflow — from ideation to code review — as reusable slash commands.

## Install

### One-liner

```bash
curl -fsSL https://raw.githubusercontent.com/aether-auto/aether-dev/main/install.sh | bash
```

### Manual

```bash
# Add the marketplace
claude plugin marketplace add aether-auto/aether-dev

# Install the plugin
claude plugin install aether-dev@aether-dev
```

## Commands

The plugin adds 7 slash commands that follow a sequential workflow:

| Command | Phase | What it does |
|---------|-------|-------------|
| `/ideate` | 1 | Interactive interview to produce a full product spec (`spec.md`) |
| `/setup` | 2 | Generate `CLAUDE.md` and `.agent-docs/` from the spec |
| `/gen-tasks` | 3 | Decompose the spec into vertical-slice task files in `.tasks/` |
| `/ui-specs` | 4 | Generate UI specifications, design tokens, and a component gallery |
| `/scaffold` | 5 | Scaffold project structure, configs, CI/CD, and testing infra |
| `/build` | 6 | Pick a ticket and build it using TDD with parallel agent teams |
| `/review` | 7 | Run parallel specialist agents for code review before pushing |

### Workflow

```
/ideate  →  /setup  →  /gen-tasks  →  /ui-specs  →  /scaffold  →  /build  →  /review
                                                                      ↑          |
                                                                      └──────────┘
                                                                     (repeat per ticket)
```

## What Gets Generated

| Phase | Artifacts |
|-------|-----------|
| Ideation | `spec.md` — full product requirements specification |
| Setup | `CLAUDE.md`, `.agent-docs/` (data-models, api-specs, product-goals, user-flows, ui-vision, code-style) |
| Tasks | `.tasks/TASK-NNN.md` files + `.tasks/INDEX.md` with dependency graph |
| UI Specs | `ui-specs/` with design tokens, page specs, component gallery |
| Scaffold | Project directories, configs, package.json, CI/CD, test setup |
| Build | Implemented features with tests (TDD: red → green → refactor) |
| Review | Reviewed code, pushed to remote |

## Requirements

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated

## Update

```bash
claude plugin update aether-dev@aether-dev
```

## Uninstall

```bash
claude plugin uninstall aether-dev@aether-dev
```

## License

MIT
