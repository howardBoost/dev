#!/usr/bin/env bash
set -euo pipefail

# Sets up the working environment after a devcontainer rebuild.
# Run this script once after the container starts to restore tools and keys.

# ── SSH key ──────────────────────────────────────────────────────────────────
SSH_KEY="$HOME/.ssh/id_ed25519_sk"

if [[ -f "$SSH_KEY" ]]; then
  echo "SSH key already exists at $SSH_KEY, skipping generation."
else
  echo "Generating SSH key..."
  ssh-keygen -t ed25519 -C "howard@boostcommerce.net" -f "$SSH_KEY" -N ""
  echo "SSH key generated: $SSH_KEY"
  echo ""
  echo "Public key (add this to GitHub → Settings → SSH keys):"
  cat "${SSH_KEY}.pub"
fi

# ── GitHub Copilot CLI ────────────────────────────────────────────────────────
if command -v copilot >/dev/null 2>&1; then
  echo "Copilot CLI already installed: $(which copilot)"
else
  echo "Installing @github/copilot CLI..."
  npm install -g @github/copilot
  echo "Copilot CLI installed."
fi

echo ""
echo "Setup complete."
