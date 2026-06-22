#!/usr/bin/env bash
# Post-clone setup for anticrab.nvim.
# Idempotent — safe to run repeatedly.
#
# Adds a `zvim` shell alias (launches Neovim) to your shell rc (~/.bashrc and
# ~/.zshrc if present) so you can start the editor with `zvim`. An existing
# `alias zvim=` line — added here on a previous run or by hand — is left
# untouched, so re-running never duplicates it. rc files you don't already have
# are never created.

set -euo pipefail

ALIAS_NAME="zvim"
ALIAS_LINE="alias zvim='nvim'"
MARKER="# Added by anticrab.nvim — launch Neovim with \`zvim\`"

ensure_alias() {
    local rc="$1"
    [[ -f "$rc" ]] || return 0  # only touch rc files that already exist
    if grep -qE "alias[[:space:]]+${ALIAS_NAME}=" "$rc"; then
        echo "Skipped: '${ALIAS_NAME}' alias already present in $rc"
        return 0
    fi
    # Blank line before our block keeps it readable when appended.
    printf '\n%s\n%s\n' "$MARKER" "$ALIAS_LINE" >> "$rc"
    echo "Added '${ALIAS_NAME}' alias to $rc"
}

for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    ensure_alias "$rc"
done

cat <<EOF

Done. Open a new shell (or 'source' your rc) and launch Neovim with: ${ALIAS_NAME}
EOF
