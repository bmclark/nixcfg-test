# Development tools module. Git, SSH, language runtimes, container tools,
# code quality, database clients, and AI coding assistants.
# Designed for AI-agent-forward development workflows.
{pkgs, ...}: {
  imports = [
    ./git.nix
    ./vscode.nix
  ];

  # --- SSH with sane defaults ------------------------------------------------
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    extraConfig = ''
      AddKeysToAgent yes
      IdentitiesOnly yes
    '';
    # Default match block: connection multiplexing for speed
    matchBlocks."*" = {
      controlMaster = "auto";
      controlPath = "~/.ssh/sockets/%r@%h-%p";
      controlPersist = "10m";
    };
  };

  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    maxCacheTtl = 7200;
    enableZshIntegration = true;
    pinentry.package = if pkgs.stdenv.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-curses;
  };

  home.packages = with pkgs; [
    # --- Nix development -----------------------------------------------------
    nil # Nix LSP for VS Code / editors
    alejandra # Nix formatter (opinionated, deterministic)
    statix # Nix linter: statix check .
    deadnix # Find unused code in .nix files: deadnix .

    # --- AI coding tools -----------------------------------------------------
    claude-code # Claude AI coding assistant CLI
    codex # OpenAI Codex CLI
    aider-chat # AI pair programming: aider

    # --- Build tools -----------------------------------------------------------
    gnumake # make (required by codex CLI)

    # --- Dev environments ------------------------------------------------------
    devenv # Declarative dev environments with devcontainer generation

    # --- Code quality / pre-commit -------------------------------------------
    pre-commit # Git hook framework: pre-commit install
    shellcheck # Shell script linter: shellcheck script.sh

    # --- Git power tools -----------------------------------------------------
    github-cli # GitHub CLI: gh pr create, gh issue list
    git-absorb # Auto-fixup commits: git absorb
    difftastic # Syntax-aware diff: difft file1 file2

    # --- Data formats --------------------------------------------------------
    jnv # Interactive JSON filter with jq: jnv file.json
    yq-go # YAML/XML/TOML processor: yq '.key' file.yaml

    # --- Code search / refactoring -------------------------------------------
    ast-grep # Structural code search/rewrite: sg -p 'pattern' .

    # --- Python --------------------------------------------------------------
    python3
    uv # Fast Python package manager: uv pip install, uv run, uv init
    ruff # Python linter + formatter: ruff check ., ruff format .

    # --- TypeScript / JavaScript ---------------------------------------------
    nodejs
    pnpm # Fast package manager: pnpm install, pnpm dev
    typescript # TypeScript compiler: tsc
    nodePackages.prettier # Code formatter: prettier --write .

    # --- Container tools -----------------------------------------------------
    docker-compose # Docker Compose v1
    dive # Explore Docker image layers: dive <image>
    ctop # Container metrics TUI: ctop

    # --- Database clients ----------------------------------------------------
    pgcli # PostgreSQL with autocomplete: pgcli -h localhost -d mydb
    litecli # SQLite with autocomplete: litecli mydb.sqlite
    usql # Universal SQL client: usql postgres://localhost/mydb
    dbmate # Simple database migrations: dbmate up

    # --- Infrastructure as Code ----------------------------------------------
    opentofu # Terraform-compatible IaC: tofu init, tofu plan, tofu apply
    terraform-ls # Terraform LSP for editors
    tflint # Terraform linter: tflint
    terragrunt # Terraform wrapper for DRY configs: terragrunt run-all plan
    tfsec # Terraform security scanner: tfsec .
    trivy # Container/IaC vulnerability scanner: trivy config .
    ansible # Configuration management: ansible-playbook site.yml

    # --- Kubernetes ----------------------------------------------------------
    kubectl # Kubernetes CLI: kubectl get pods
    k9s # Kubernetes TUI: k9s
    helm # Kubernetes package manager: helm install

    # --- Cloud CLIs ----------------------------------------------------------
    awscli2 # AWS CLI v2: aws s3 ls, aws sts get-caller-identity

    # --- Secrets management --------------------------------------------------
    sops # Encrypted secrets: sops secrets.yaml
    age # Modern encryption: age -e -r <key> file
    rbw # Bitwarden CLI client with local cache: rbw get item
    pinentry-curses # Terminal pinentry for gpg-agent and signing flows

    # --- API / network tools -------------------------------------------------
    grpcurl # gRPC client: grpcurl -plaintext localhost:50051 list
    websocat # WebSocket client: websocat ws://localhost:8080
  ];
}
