#!/usr/bin/env bash
set -euo pipefail

# Multi-Agent Workflow setup script
# Installs skill, subagents, and injects config into opencode.json

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
AGENTS_SRC="$REPO_DIR/agents"
AGENTS_DEST="${HOME}/.config/opencode/agents"
SKILL_SRC="$REPO_DIR/SKILL.md"
SKILL_DEST="${HOME}/.config/opencode/skills/multi-agent-workflow"
CONFIG_FILE="${HOME}/.config/opencode/opencode.json"

echo "=== Multi-Agent Workflow Setup ==="
echo ""

# 0. Prerequisites check
echo "0. Checking prerequisites..."
if ! command -v opencode &>/dev/null; then
  echo "   WARNING: opencode not found in PATH. Make sure it's installed."
fi
if ! python3 -c "import json" 2>/dev/null; then
  echo "   ERROR: python3 is required. Please install it."
  exit 1
fi

SUPERPOWERS_PATHS=(
  "${HOME}/.agents/skills/wayfinder/SKILL.md"
  "${HOME}/.claude/skills/wayfinder/SKILL.md"
  "${HOME}/.config/opencode/skills/wayfinder/SKILL.md"
)
SUPERPOWERS_FOUND=false
for p in "${SUPERPOWERS_PATHS[@]}"; do
  if [ -f "$p" ]; then
    SUPERPOWERS_FOUND=true
    echo "   Found superpowers skills at $(dirname "$p")"
    break
  fi
done
if [ "$SUPERPOWERS_FOUND" = false ]; then
  echo "   WARNING: Superpowers skill collection not found."
  echo "   The workflow router references skills like wayfinder, brainstorming,"
  echo "   grill-with-docs, implement, tdd, code-review, etc."
  echo "   Install them from https://github.com/obra/superpowers or adapt SKILL.md."
  echo ""
fi

# 1. Install skill (SKILL.md)
echo "1. Installing skill..."
mkdir -p "$SKILL_DEST"
cp "$SKILL_SRC" "$SKILL_DEST/SKILL.md"
echo "   Installed SKILL.md to $SKILL_DEST"
echo "   (model-invoked: OpenCode will auto-load it when the description matches)"
echo ""

# 2. Copy agent templates
echo "2. Installing subagents..."
mkdir -p "$AGENTS_DEST"
for f in "$AGENTS_SRC"/*.md; do
  name=$(basename "$f")
  cp "$f" "$AGENTS_DEST/$name"
  echo "   - $name"
done
echo "   Installed to $AGENTS_DEST"
echo ""

# 3. Check for opencode.json
echo "3. Configuring opencode.json..."
if [ ! -f "$CONFIG_FILE" ]; then
  echo "   Creating $CONFIG_FILE"
  echo '{}' > "$CONFIG_FILE"
fi

# 4. Inject model + agent config using python3
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
echo "4. Setup complete."
echo ""
echo "   What was installed:"
echo "   - Skill:        ~/.config/opencode/skills/multi-agent-workflow/SKILL.md"
echo "   - Subagents:    ~/.config/opencode/agents/*.md (5 agents)"
echo "   - Config:       ~/.config/opencode/opencode.json (model + build agent)"
echo ""
echo "   Next steps:"
echo "   - Make sure OpenRouter is connected: /connect in OpenCode"
echo "   - Restart OpenCode for changes to take effect"
echo "   - The skill auto-loads when you ask to develop features or fix bugs"
echo "   - Subagents are invoked via @agent-name or automatically by the controller"
echo ""