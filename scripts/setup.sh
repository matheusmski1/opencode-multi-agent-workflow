#!/usr/bin/env bash
set -euo pipefail

# Multi-Agent Workflow setup script
# Installs skill, subagents, and injects config into opencode.json (non-destructive).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
AGENTS_SRC="$REPO_DIR/agents"
AGENTS_DEST="${HOME}/.config/opencode/agents"
SKILL_SRC="$REPO_DIR/SKILL.md"
SKILL_DEST="${HOME}/.config/opencode/skills/multi-agent-workflow"
CONFIG_FILE="${HOME}/.config/opencode/opencode.json"

# Model routing (OpenCode Zen — opencode Go open-model pool). Edit here to retune.
# Reconfirm the current pool with `/models` in the OpenCode TUI before freezing.
CONTROLLER_MODEL="opencode/glm-5.2"
SMALL_MODEL="opencode/deepseek-v4-flash"

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

# The router references skills from mattpocock/skills (wayfinder, to-spec, to-tickets,
# implement, tdd, code-review, ...). OpenCode discovers skills under these dirs.
SKILL_SEARCH_DIRS=(
  "${HOME}/.config/opencode/skills"
  "${HOME}/.claude/skills"
  "${HOME}/.agents/skills"
)
SKILLS_FOUND=false
for d in "${SKILL_SEARCH_DIRS[@]}"; do
  if [ -f "$d/wayfinder/SKILL.md" ] || [ -f "$d/to-spec/SKILL.md" ]; then
    SKILLS_FOUND=true
    echo "   Found router skills at $d"
    break
  fi
done
if [ "$SKILLS_FOUND" = false ]; then
  echo "   WARNING: router skill collection not found."
  echo "   The router references skills from https://github.com/mattpocock/skills"
  echo "   (wayfinder, to-spec, to-tickets, implement, tdd, code-review, diagnosing-bugs,"
  echo "   triage, prototype, grill-with-docs, ask-matt, handoff). Install that collection"
  echo "   into one of: ${SKILL_SEARCH_DIRS[*]}"
  echo "   (brainstorming is optional, from https://github.com/obra/superpowers)."
  echo ""
fi

# 1. Install skill (SKILL.md)
echo "1. Installing skill..."
mkdir -p "$SKILL_DEST"
cp "$SKILL_SRC" "$SKILL_DEST/SKILL.md"
echo "   Installed SKILL.md to $SKILL_DEST"
echo "   (model-invoked: OpenCode auto-loads it via the skill tool when the description matches)"
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

# 3. Configure opencode.json (non-destructive: back up first, report what changes)
echo "3. Configuring opencode.json..."
if [ ! -f "$CONFIG_FILE" ]; then
  echo "   Creating $CONFIG_FILE"
  echo '{}' > "$CONFIG_FILE"
else
  BACKUP="${CONFIG_FILE}.bak.$(date +%Y%m%d%H%M%S)"
  cp "$CONFIG_FILE" "$BACKUP"
  echo "   Backed up existing config to $BACKUP"
fi

echo "   Injecting model routing and build agent config..."
CONTROLLER_MODEL="$CONTROLLER_MODEL" SMALL_MODEL="$SMALL_MODEL" python3 << 'PYEOF'
import json, sys, os

config_path = os.path.expanduser("~/.config/opencode/opencode.json")
controller = os.environ["CONTROLLER_MODEL"]
small = os.environ["SMALL_MODEL"]

with open(config_path) as f:
    try:
        config = json.load(f)
    except json.JSONDecodeError:
        print("   ERROR: opencode.json is not valid JSON. Please fix it manually.")
        sys.exit(1)

def note_override(key, new):
    old = config.get(key)
    if old is not None and old != new:
        print(f"   NOTE: overwriting '{key}': {old!r} -> {new!r} (old value is in the .bak file)")

config.setdefault("$schema", "https://opencode.ai/config.json")
note_override("model", controller)
config["model"] = controller
note_override("small_model", small)
config["small_model"] = small

config.setdefault("agent", {})
config["agent"].setdefault("build", {})
config["agent"]["build"]["mode"] = "primary"
config["agent"]["build"]["model"] = controller
config["agent"]["build"]["reasoningEffort"] = "high"
config["agent"]["build"]["description"] = "Controller for the multi-agent development workflow; routes tasks to specialized subagents."
config["agent"]["build"].setdefault("permission", {})
config["agent"]["build"]["permission"]["task"] = "allow"
# Commit is the controller's exclusive act (implementers/debug deny it natively).
# Block the two ways an agent could dodge the husky pre-commit / commit-msg gate.
config["agent"]["build"]["permission"]["bash"] = {
    "*": "allow",
    "*--no-verify*": "deny",
    "git push --force*": "deny",
    "git push -f *": "deny",
}

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
echo "   - Connect OpenCode Zen: /connect in OpenCode (subscribe to the Go plan for flat-rate open models)"
echo "   - Confirm the routed model IDs exist in your pool: /models in OpenCode"
echo "   - Restart OpenCode for changes to take effect"
echo "   - The skill auto-loads when you ask to develop features or fix bugs"
echo "   - Subagents are invoked via @agent-name or automatically by the controller"
echo ""
