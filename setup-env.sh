#!/usr/bin/env bash
set -euo pipefail

# Sets up the working environment after a devcontainer rebuild.
# Run this script once after the container starts to restore tools and keys.

# ── SSH key ──────────────────────────────────────────────────────────────────
SSH_KEY="$HOME/.ssh/id_ed25519"

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

# ── Node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
export NVM_DIR="/usr/local/share/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm i 24

# ── GitHub Copilot CLI ────────────────────────────────────────────────────────
if command -v copilot >/dev/null 2>&1; then
  echo "Copilot CLI already installed: $(which copilot)"
else
  echo "Installing @github/copilot CLI..."
  npm install -g @github/copilot
  echo "Copilot CLI installed."
fi

# ── mempalace ────────────────────────────────────────────────────────────────
echo "Installing mempalace..."
pip install mempalace
echo "mempalace installed."

echo ""
echo "Setup complete."
