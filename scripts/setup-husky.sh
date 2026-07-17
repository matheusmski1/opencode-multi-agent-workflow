#!/usr/bin/env bash
set -euo pipefail

# Scaffold the deterministic objective gate into a TARGET project (per-repo, not global):
# husky + commitlint (conventional commits) + lint-staged (tsc --noEmit + eslint).
# This is the hard gate that runs on the controller's commit — the agent's work is
# checked by the same objective toolchain a human's would be.
#
# Usage: scripts/setup-husky.sh [target-repo-dir]   (defaults to the current directory)

TARGET_DIR="${1:-$(pwd)}"
cd "$TARGET_DIR"

echo "=== Husky quality-gate scaffold → $TARGET_DIR ==="

if [ ! -d .git ]; then
  echo "ERROR: $TARGET_DIR is not a git repository (husky hooks need one). Run 'git init' first." >&2
  exit 1
fi
if [ ! -f package.json ]; then
  echo "ERROR: no package.json here. Run 'npm init -y' (or your PM's init) first." >&2
  exit 1
fi

# Detect package manager from the lockfile.
if [ -f pnpm-lock.yaml ]; then PM="pnpm"; ADD="pnpm add -D"; DLX="pnpm exec"
elif [ -f yarn.lock ]; then PM="yarn"; ADD="yarn add -D"; DLX="yarn"
else PM="npm"; ADD="npm install -D"; DLX="npx"; fi
echo "Package manager: $PM"

echo "1. Installing dev dependencies..."
$ADD husky @commitlint/cli @commitlint/config-conventional lint-staged

echo "2. Initializing husky..."
$DLX husky init  # creates .husky/ and a pre-commit stub we overwrite below

echo "3. Writing commitlint config (conventional commits)..."
if [ ! -f commitlint.config.js ] && [ ! -f .commitlintrc.js ] && [ ! -f .commitlintrc.json ]; then
  cat > commitlint.config.js <<'EOF'
module.exports = { extends: ['@commitlint/config-conventional'] };
EOF
  echo "   wrote commitlint.config.js"
else
  echo "   commitlint config already exists — left as-is"
fi

echo "4. Writing lint-staged config (eslint on staged TS/JS)..."
if [ ! -f .lintstagedrc.json ]; then
  cat > .lintstagedrc.json <<'EOF'
{
  "*.{ts,tsx,js,jsx}": ["eslint --max-warnings 0"]
}
EOF
  echo "   wrote .lintstagedrc.json"
else
  echo "   .lintstagedrc.json already exists — left as-is"
fi

echo "5. Writing hooks..."
# pre-commit: project-wide tsc (only if a tsconfig exists, so a fresh repo can still
# land its first tsconfig), then eslint on staged files via lint-staged.
cat > .husky/pre-commit <<'EOF'
if [ -f tsconfig.json ]; then
  echo "· tsc --noEmit"
  npx tsc --noEmit || exit 1
fi
npx lint-staged
EOF

# commit-msg: enforce conventional-commit format.
cat > .husky/commit-msg <<'EOF'
npx --no-install commitlint --edit "$1"
EOF

chmod +x .husky/pre-commit .husky/commit-msg

echo ""
echo "Done. The objective gate now runs on every commit in $TARGET_DIR:"
echo "  - pre-commit : tsc --noEmit (if tsconfig.json) + eslint --max-warnings 0 on staged files"
echo "  - commit-msg : commitlint (conventional commits)"
echo ""
echo "Note: agents can't bypass this — the workflow denies 'git commit --no-verify' and"
echo "'git push --force' for the controller, and denies commit/push entirely for implementers."
