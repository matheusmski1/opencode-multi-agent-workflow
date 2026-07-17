#!/usr/bin/env bash
set -euo pipefail

# Multi-Agent Workflow setup script
# Installs subagents and injects config into opencode.json

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
AGENTS_SRC="$REPO_DIR/agents"
AGENTS_DEST="${HOME}/.config/opencode/agents"
CONFIG_FILE="${HOME}/.config/opencode/opencode.json"

echo "=== Multi-Agent Workflow Setup ==="
echo ""

# 1. Copy agent templates
echo "1. Installing subagents..."
mkdir -p "$AGENTS_DEST"
for f in "$AGENTS_SRC"/*.md; do
  name=$(basename "$f")
  cp "$f" "$AGENTS_DEST/$name"
  echo "   - $name"
done
echo "   Installed to $AGENTS_DEST"
echo ""

# 2. Check for opencode.json
echo "2. Configuring opencode.json..."
if [ ! -f "$CONFIG_FILE" ]; then
  echo "   Creating $CONFIG_FILE"
  echo '{}' > "$CONFIG_FILE"
fi

# 3. Inject model + agent config using python3
echo "   Injecting model routing and build agent config..."
python3 << 'PYEOF'
import json, sys, os

config_path = os.path.expanduser("~/.config/opencode/opencode.json")
with open(config_path) as f:
    try:
        config = json.load(f)
    except json.JSONDecodeError:
        print("   ERROR: opencode.json is not valid JSON. Please fix it manually.")
        sys.exit(1)

config.setdefault("$schema", "https://opencode.ai/config.json")
config["model"] = "openrouter/z-ai/glm-5.2"
config["small_model"] = "openrouter/deepseek/deepseek-v4-flash"

config.setdefault("agent", {})
config["agent"].setdefault("build", {})
config["agent"]["build"]["mode"] = "primary"
config["agent"]["build"]["model"] = "openrouter/z-ai/glm-5.2"
config["agent"]["build"]["description"] = "Controller for the multi-agent development workflow; routes tasks to specialized subagents."
config["agent"]["build"].setdefault("permission", {})
config["agent"]["build"]["permission"]["task"] = "allow"

with open(config_path, "w") as f:
    json.dump(config, f, indent=2)
    f.write("\n")

print("   Done.")
PYEOF

echo ""
echo "3. Setup complete."
echo ""
echo "   Next steps:"
echo "   - Make sure OpenRouter is connected: /connect in OpenCode"
echo "   - Restart OpenCode for changes to take effect"
echo "   - Invoke subagents with @agent-name in your messages"
echo ""
