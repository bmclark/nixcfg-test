# Development Features

Development tooling, language runtimes, IaC tools, container tools, database clients, and editor configuration. Designed for AI-agent-forward infrastructure-as-code workflows.

## Modules

| Module | Flag | Description |
|--------|------|-------------|
| `git.nix` | `features.development.git.enable` | Git with delta pager, difftastic, git-absorb, Dracula syntax theme |
| `vscode.nix` | `features.development.vscode.enable` | VS Code with switchable theme, layered extensions, AI-agent-first settings |

## Always-On Tools (default.nix)

These are enabled for all hosts that import the development feature directory.

### SSH Configuration

Managed via `programs.ssh` with `enableDefaultConfig = false` (we define all defaults explicitly via `matchBlocks."*"`):
- **Connection multiplexing**: Reuses SSH connections (`ControlMaster auto`) for faster subsequent connections
- **Socket path**: `~/.ssh/sockets/%r@%h-%p`
- **Persist time**: 10 minutes after last connection
- **Key agent**: Auto-adds keys to ssh-agent
- **IdentitiesOnly**: Only offers explicitly configured keys

Add host-specific config to `~/.ssh/config.d/` or extend `matchBlocks` in the module.

### Nix Development

| Tool | Command | Description |
|------|---------|-------------|
| `nil` | (LSP) | Nix language server for VS Code and editors |
| `alejandra` | `alejandra file.nix` | Nix code formatter (opinionated, deterministic) |
| `statix` | `statix check .` | Nix linter — catches common mistakes and antipatterns |
| `deadnix` | `deadnix .` | Find unused code in .nix files |

### AI Coding Tools

| Tool | Command | Description |
|------|---------|-------------|
| `claude-code` | `claude` | Claude AI coding assistant CLI |
| `codex` | `codex` | OpenAI Codex CLI |
| `aider-chat` | `aider` | AI pair programming — works with any LLM provider |

### Build Tools

| Tool | Command | Description |
|------|---------|-------------|
| `gnumake` | `make` | GNU Make — required by codex CLI and general build automation |
| `go-task` | `task check`, `task switch` | Taskfile runner for a smaller wrapper layer over common local workflows |

### Dev Environments

| Tool | Command | Description |
|------|---------|-------------|
| `devenv` | `devenv shell`, `devenv up` | Declarative dev environments with devcontainer generation |

### Code Quality

| Tool | Command | Description |
|------|---------|-------------|
| `pre-commit` | `pre-commit install` | Git hook framework — run linters/formatters on commit |
| `shellcheck` | `shellcheck script.sh` | Shell script static analysis |
| `ast-grep` | `sg -p 'pattern' .` | Structural code search and rewrite (syntax-aware) |

### Git Power Tools

| Tool | Command | Description |
|------|---------|-------------|
| `github-cli` | `gh pr create`, `gh issue list` | GitHub CLI for PRs, issues, actions |
| `git-absorb` | `git absorb` (alias: `git absorb --and-rebase`) | Auto-fixup staged changes into the right prior commits |
| `difftastic` | `git dft` or `difft file1 file2` | Syntax-aware structural diff |

### Infrastructure as Code

| Tool | Alias | Command | Description |
|------|-------|---------|-------------|
| `opentofu` | `tf` | `tofu plan`, `tofu apply` | Terraform-compatible open-source IaC |
| `terraform-ls` | — | (LSP) | Terraform language server for editors |
| `tflint` | — | `tflint` | Terraform linter |
| `terragrunt` | `tg` | `terragrunt run-all plan` | Terraform wrapper for DRY configs |
| `tfsec` | — | `tfsec .` | Terraform security scanner |
| `trivy` | — | `trivy config .` | Vulnerability scanner for IaC, containers, filesystems |
| `ansible` | — | `ansible-playbook site.yml` | Configuration management |

### Kubernetes

| Tool | Alias | Command | Description |
|------|-------|---------|-------------|
| `kubectl` | `k` | `kubectl get pods` | Kubernetes CLI |
| `k9s` | — | `k9s` | Kubernetes TUI — manage clusters interactively |
| `helm` | — | `helm install` | Kubernetes package manager |

Kubernetes aliases (in `cli/zsh.nix`):
- `kgp` — get pods
- `kgs` — get services
- `kga` — get all resources
- `kns <namespace>` — switch namespace
- `kctx <context>` — switch context

### Cloud CLIs

| Tool | Command | Description |
|------|---------|-------------|
| `awscli2` | `aws s3 ls`, `aws sts get-caller-identity` | AWS CLI v2 |

### Secrets Management

| Tool | Command | Description |
|------|---------|-------------|
| `sops` | `sops secrets.yaml` | Encrypt/decrypt secrets files (supports age, AWS KMS, GCP KMS) |
| `age` | `age -e -r <key> file` | Modern file encryption with small explicit keys |
| `rbw` | `rbw login`, `rbw get <item>` | Bitwarden CLI with local cache for terminal secret retrieval |
| `gpg` / `gpg-agent` | `gpg --list-secret-keys`, `git cs -m ...` | Terminal signing flow with curses pinentry and cached agent |

### Python

| Tool | Command | Description |
|------|---------|-------------|
| `python3` | `python3` | Python 3 interpreter |
| `uv` | `uv pip install`, `uv run`, `uv init` | Extremely fast Python package manager (replaces pip/venv) |
| `ruff` | `ruff check .`, `ruff format .` | Fast Python linter + formatter (replaces flake8/black/isort) |

### TypeScript / JavaScript

| Tool | Command | Description |
|------|---------|-------------|
| `nodejs` | `node` | Node.js runtime |
| `pnpm` | `pnpm install`, `pnpm dev` | Fast, disk-efficient package manager |
| `typescript` | `tsc` | TypeScript compiler |
| `prettier` | `prettier --write .` | Code formatter for JS/TS/JSON/YAML/MD/CSS |

### Container Tools

| Tool | Command | Description |
|------|---------|-------------|
| `docker-compose` | `docker-compose up` | Docker Compose v1 |
| `dive` | `dive <image>` | Explore Docker image layers — find bloat |
| `ctop` | `ctop` | Real-time container metrics TUI (like top for containers) |

Note: `lazydocker` (Docker TUI) is in `cli/default.nix` and aliased to `ld` in zsh.

### Database Clients

| Tool | Command | Description |
|------|---------|-------------|
| `pgcli` | `pgcli -h localhost -d mydb` | PostgreSQL client with autocomplete + syntax highlighting |
| `litecli` | `litecli mydb.sqlite` | SQLite client with autocomplete + syntax highlighting |
| `usql` | `usql postgres://localhost/mydb` | Universal SQL client — connects to any database |

### Data Format Tools

| Tool | Alias | Command | Description |
|------|-------|---------|-------------|
| `jnv` | — | `jnv file.json` | Interactive JSON filter using jq (TUI) |
| `yq-go` | `yq` | `yq '.key' file.yaml` | YAML/XML/TOML processor (like jq for YAML) |

### API / Network Tools

| Tool | Command | Description |
|------|---------|-------------|
| `grpcurl` | `grpcurl -plaintext localhost:50051 list` | gRPC client (like curl for gRPC) |
| `websocat` | `websocat ws://localhost:8080` | WebSocket client (like netcat for WebSockets) |

## VS Code Extension Layers

Extensions are organized in two layers:

### Global Layer (vscode.nix)

Installed via Nix for all projects:
- **Theme**: Dracula (switchable via `NIXCFG_THEME`)
- **Editor**: Emacs MCX, EditorConfig, ErrorLens, markdownlint
- **AI**: Copilot (inline autocomplete), Claude Code
- **Git**: GitLens, GitHub PRs, GitHub Actions
- **Remote**: Dev Containers, Remote SSH
- **Data formats**: YAML, TOML
- **Nix**: nix-ide (nil LSP + alejandra)

### Project Layer (.vscode/extensions.json)

Recommended per-project via devenv templates — VS Code prompts to install these:

| Template | Extensions |
|----------|-----------|
| Python | ms-python.python, charliermarsh.ruff, ms-python.debugpy |
| TypeScript | dbaeumer.vscode-eslint, esbenp.prettier-vscode |
| Rust | rust-lang.rust-analyzer |
| Go | golang.go |
| Terraform | hashicorp.terraform, redhat.vscode-yaml |

## devenv Templates

Scaffold new projects with devenv-powered dev environments:

```bash
# Create a project with a template
mkproject myapp python      # Python + uv + ruff
mkproject myapp typescript  # Node + pnpm + TypeScript
mkproject myapp rust        # Rust + cargo + clippy
mkproject myapp go          # Go + gopls + golangci-lint
mkproject myapp terraform   # OpenTofu + tflint + tfsec

# Or use nix flake init directly
nix flake init -t ~/nixcfg#python
```

Each template provides:
- **`devenv.nix`** — language config, packages, devcontainer generation
- **`flake.nix`** — devenv flake wrapper (cachix binary cache pre-configured)
- **`.vscode/extensions.json`** — per-language extension recommendations

### Using devenv

```bash
# Enter the dev shell
devenv shell

# Or use direnv for auto-activation
echo "use devenv" > .envrc
direnv allow

# Generate a devcontainer.json for team use
devenv container generate
```

devenv bridges Nix dev environments and devcontainers — use `devenv shell` locally and generate `devcontainer.json` for teammates who don't use Nix.

## Pre-commit Configuration

A default `.pre-commit-config.yaml` is provided at `templates/pre-commit-config.yaml`. To use:

```bash
cp ~/nixcfg/templates/pre-commit-config.yaml .pre-commit-config.yaml
pre-commit install
```

Includes hooks for: trailing whitespace, YAML/JSON/TOML validation, private key detection, alejandra (Nix), statix (Nix), deadnix (Nix), shellcheck. Python and TypeScript hooks are included but commented out.

## Git Configuration (git.nix)

- **Identity**: Bryan Clark <bryan@bclark.net>
- **Signing key hint**: `user.signingkey = bryan@bclark.net`
- **Default branch**: main
- **Delta pager**: Side-by-side diffs with Dracula syntax highlighting
- **Difftastic**: Syntax-aware diff via `git dft`
- **Git-absorb**: Auto-fixup via `git absorb`
- **Auto-setup remote**: `push.autoSetupRemote = true`
- **Rebase on pull**: `pull.rebase = true`
- **Editor**: emacs
- **Rerere**: Remembers conflict resolutions
- **GPG program**: `gpg` with OpenPGP format; signed tags by default and signed commits available via aliases

### Git Aliases (git.nix)

| Alias | Command |
|-------|---------|
| `git st` | `git status` |
| `git sb` | `git status --short --branch` |
| `git co` | `git checkout` |
| `git br` | `git branch` |
| `git ci` | `git commit` |
| `git cs` | `git commit -S` |
| `git csa` | `git commit -S --amend` |
| `git lg` | Pretty log graph |
| `git unstage` | `git reset HEAD --` |
| `git last` | `git log -1 HEAD` |
| `git amend` | `git commit --amend --no-edit` |
| `git absorb` | `git absorb --and-rebase` |

### Signing and Secrets Workflow

Use this flow on `maverick`:

```bash
# Verify the secret key is present
gpgkeys

# Check git's signing-related settings
just git-signing-status

# Make a signed commit without enabling global sign-on-every-commit
git cs -m "your message"

# Log into Bitwarden for terminal retrieval
rbw login
rbw get <item-name>
```

`gpg-agent` is configured with a curses pinentry and a short cache TTL, so terminal signing prompts stay inside Ghostty/tmux instead of spawning a GUI prompt.
| `git dft` | Syntax-aware diff via difftastic |

Additional shell-level git aliases (`g`, `gs`, `ga`, etc.) are in `cli/zsh.nix`.

## Starship Prompt Context

The Starship prompt (configured in `cli/zsh.nix`) shows IaC-relevant context on the right side:
- **Terraform workspace** — when in a directory with `.tf` files
- **Kubernetes context** — when `kubectl` config or Helmfile is present
- **AWS profile** — when `AWS_PROFILE` is set
- **Docker context** — when Docker is active
- **Nix shell** — when inside a nix develop/nix-shell

## VS Code Keybindings (Emacs MCX)

Emacs MCX provides standard Emacs keybindings (Ctrl+A/E/K/N/P/F/B) in the editor. VS Code commands are mapped to avoid conflicts:

### Emacs MCX Conflict Resolution

| Keybinding | In Editor (Emacs MCX) | Outside Editor (VS Code) |
|------------|-----------------------|--------------------------|
| `Ctrl+B` | backward-char | Toggle sidebar |
| `Ctrl+P` | previous-line | Quick open |

### Emacs-style VS Code Keybindings

| Keybinding | Command | Emacs Equivalent |
|------------|---------|------------------|
| `Alt+X` | Command palette | `M-x` |
| `Alt+P` | Quick open (from anywhere) | — |
| `Ctrl+X Ctrl+F` | Open file | `find-file` |
| `Ctrl+X Ctrl+S` | Save | `save-buffer` |
| `Ctrl+X K` | Close editor | `kill-buffer` |
| `Ctrl+X 2` | Split editor below | `split-window-below` |
| `Ctrl+X 3` | Split editor right | `split-window-right` |
| `Ctrl+X O` | Focus next group | `other-window` |
| `Ctrl+X 1` | Close other editors | `delete-other-windows` |

### Standard VS Code Keybindings

| Keybinding | Command |
|------------|---------|
| `` Ctrl+` `` | Toggle terminal |
| `Ctrl+\` | Split editor |
| `Ctrl+Shift+F` | Find in files |
| `Ctrl+1` / `Ctrl+2` | Focus editor group 1/2 |

## Key Design Decisions

- **OpenTofu over Terraform**: Open-source fork, identical CLI, avoids BSL license concerns
- **VS Code FHS wrapper**: Required on Linux (`pkgs.vscode.fhs`), not on macOS (`pkgs.vscode`)
- **SSH multiplexing**: Reuses connections to avoid repeated authentication
- **devenv over raw flake shells**: Declarative config, devcontainer generation, cachix binary cache
- **Layered VS Code extensions**: Global base in Nix (always available), per-project in `.vscode/extensions.json` (language-specific)
- **AI-agent-first**: Copilot for inline autocomplete, CLI agents (claude, codex, opencode) for heavy lifting
- **Pre-commit**: Installed globally, configured per-project — AI agents should run `pre-commit install` in new repos
- **Emacs MCX conflicts**: Ctrl+B/P resolve by context — Emacs in editor, VS Code outside editor
- See [ADR-005](../../../docs/adr/ADR-005-development-environment-approach.md)
