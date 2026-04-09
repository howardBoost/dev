#!/usr/bin/env bash
set -euo pipefail

# Starts Copilot CLI in YOLO mode and grants access to every folder listed
# in a VS Code multi-root workspace file.
if ! command -v copilot >/dev/null 2>&1; then
  echo "copilot CLI not found in PATH." >&2
  exit 1
fi

echo "Launching: copilot --yolo --config-dir=/workspaces/python/data/copilot"
exec copilot --yolo --config-dir=/workspaces/python/data/copilot