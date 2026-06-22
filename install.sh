#!/usr/bin/env bash
# Full setup for anticrab.nvim. Idempotent — safe to re-run.
#
# Default run does, in order:
#   1. system dependencies via apt (Debian/Ubuntu)
#   2. ensure Neovim >= 0.11 (snap, since apt is usually too old)
#   3. add a `zvim` shell alias
#   4. pre-install plugins (lazy.nvim sync) so the first launch is quick
#
# Mason tools (formatters/linters/DAP), LSP servers and Treesitter parsers
# install automatically on the first interactive launch — doing that step
# headlessly is unreliable (the Mason registry isn't ready), so we don't.
#
# On non-apt distros step 1 is skipped with a note (install the equivalents by
# hand); everything else still runs.
#
# Usage: ./install.sh [--alias-only] [--no-bootstrap] [-h|--help]

set -euo pipefail

ALIAS_ONLY=0
BOOTSTRAP=1
for arg in "$@"; do
    case "$arg" in
        --alias-only)   ALIAS_ONLY=1 ;;
        --no-bootstrap) BOOTSTRAP=0 ;;
        -h|--help)
            cat <<EOF
Usage: ./install.sh [options]
  (no flags)       system deps + Neovim + zvim alias + plugins/tools
  --alias-only     only add the zvim shell alias (no apt, no bootstrap)
  --no-bootstrap   system deps + alias, but skip the headless plugin/tool install
  -h, --help       show this help
EOF
            exit 0 ;;
        *) echo "Unknown argument: $arg (try --help)" >&2; exit 1 ;;
    esac
done

# Run privileged commands via sudo unless we're already root.
if [ "$(id -u)" -eq 0 ]; then SUDO=""; else SUDO="sudo"; fi

# ---------------------------------------------------------------------------
# 1. System dependencies (Debian/Ubuntu)
# ---------------------------------------------------------------------------
install_system_deps() {
    if ! command -v apt-get >/dev/null 2>&1; then
        echo "==> Skipping apt deps: apt-get not found (non-Debian system)."
        echo "    Install equivalents of: git curl build-essential ripgrep fd-find"
        echo "    xclip/wl-clipboard nodejs npm python3-pip python3-venv libxml2-utils"
        return
    fi

    # Clipboard tool depends on the session type.
    local clip="xclip"
    [ -n "${WAYLAND_DISPLAY:-}" ] && clip="wl-clipboard"

    local pkgs=(
        git curl build-essential ripgrep fd-find "$clip"
        nodejs npm python3-pip python3-venv libxml2-utils
    )
    echo "==> Installing system packages: ${pkgs[*]}"
    $SUDO apt-get update -qq
    $SUDO apt-get install -y "${pkgs[@]}"
}

# ---------------------------------------------------------------------------
# 2. Neovim itself — config needs >= 0.11 (native LSP API). apt is usually too
#    old, so prefer snap; act only if nvim is missing or outdated.
# ---------------------------------------------------------------------------
ensure_neovim() {
    local need="0.11"
    if command -v nvim >/dev/null 2>&1; then
        local ver
        ver=$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
        if [ "$(printf '%s\n%s\n' "$need" "$ver" | sort -V | head -1)" = "$need" ]; then
            echo "==> Neovim $ver present (>= $need) — ok."
            return
        fi
        echo "==> Neovim $ver is older than $need (native LSP API needed)."
    else
        echo "==> Neovim not found."
    fi
    if command -v snap >/dev/null 2>&1; then
        echo "    Installing latest Neovim via snap..."
        $SUDO snap install nvim --classic
    else
        echo "    Please install Neovim >= $need (e.g. 'sudo snap install nvim --classic'"
        echo "    or the official AppImage) and re-run."
    fi
}

# ---------------------------------------------------------------------------
# 3. zvim shell alias (idempotent): add to existing rc files only, never dup.
# ---------------------------------------------------------------------------
ALIAS_NAME="zvim"
ALIAS_LINE="alias zvim='nvim'"
MARKER="# Added by anticrab.nvim — launch Neovim with \`zvim\`"

ensure_alias() {
    local rc="$1"
    [[ -f "$rc" ]] || return 0  # only touch rc files that already exist
    if grep -qE "alias[[:space:]]+${ALIAS_NAME}=" "$rc"; then
        echo "==> Skipped: '${ALIAS_NAME}' alias already present in $rc"
        return 0
    fi
    printf '\n%s\n%s\n' "$MARKER" "$ALIAS_LINE" >> "$rc"
    echo "==> Added '${ALIAS_NAME}' alias to $rc"
}

add_alias() {
    for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do ensure_alias "$rc"; done
}

# ---------------------------------------------------------------------------
# 4. Pre-install plugins headlessly so the first launch is quick. Mason tools,
#    LSP servers and Treesitter parsers auto-install on first interactive launch.
# ---------------------------------------------------------------------------
bootstrap_nvim() {
    if ! command -v nvim >/dev/null 2>&1; then
        echo "==> Skipping plugin bootstrap: nvim not available."
        return
    fi
    echo "==> Installing plugins (lazy.nvim sync)…"
    nvim --headless "+Lazy! sync" +qa || echo "    (lazy sync hiccupped; first launch will retry)"
    echo "==> Plugins ready. Mason tools, LSP servers and Treesitter parsers"
    echo "    install automatically the first time you launch nvim."
}

# --- run ---
if [ "$ALIAS_ONLY" -eq 1 ]; then
    add_alias
else
    install_system_deps
    ensure_neovim
    add_alias
    [ "$BOOTSTRAP" -eq 1 ] && bootstrap_nvim
fi

cat <<EOF

Done. Open a new shell (or 'source' your rc) and launch Neovim with: ${ALIAS_NAME}
EOF
