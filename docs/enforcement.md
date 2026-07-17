# ADR: Enforce quality with native permission + husky, not a custom gate plugin

**Status:** accepted · **Context:** opencode Go multi-agent workflow

## Context

The two review subagents (spec, code-quality) are meant to be *gates* — work should not proceed until they pass. OpenCode's core is LLM-driven: a subagent's PASS/FAIL is prose the controller may or may not honor. We evaluated how to make the gates actually block.

The obvious design was a custom OpenCode plugin: gate agents write a PASS marker keyed to a git tree hash, and a `tool.execute.before` hook throws to abort `git commit`/`push` unless a fresh marker exists. A cross-model adversarial review (Claude Fable 5) found this holed:

- **TOCTOU:** `git write-tree` hashes the *index*, not the working tree; agents commit as `git add -A && git commit`, so the hook validates the tree before the `add` stages the unreviewed change.
- **Self-attested marker:** the gate LLM writes its own PASS marker, and the implementer shares the same bash — a misaligned/lazy agent (the exact adversary the gate exists to catch) can forge it, and the hook's error message documents the bypass.
- **Factual miss:** a custom plugin is *not* the only deterministic block. OpenCode supports native per-agent `permission.bash` deny with glob patterns.

An LLM review therefore cannot be honestly hard-gated: the reviewer produces the verdict, so any marker it writes for itself is theater. The hard block must live where it is objective.

## Decision

Two layers.

**Hard gate — deterministic, zero custom code:**
- Native `permission.bash` deny: implementer/debug subagents deny `git commit`/`git push` (commit becomes the controller's exclusive act); the controller denies `--no-verify` and `git push --force` so it cannot dodge the toolchain.
- **husky** on the controller's commit runs `tsc --noEmit` + `eslint --max-warnings 0` (pre-commit) and `commitlint` (commit-msg). Scaffolded per-repo by `scripts/setup-husky.sh`.

**Prose gate — LLM, run by the controller before committing:**
- Spec then code-quality review, delta-scoped to the pinned three-dot diff, `file:line` evidence required, PASS/FAIL. Single reviewer per axis; second opinion on high-stakes diffs is manual with a human tie-break, not an automated 3-model jury (which laundered confidence and burned the rate-limit window without raising bug recall). Debug capped at 3 attempts, then escalate.

## Consequences

- **+** The deterministic layer is honest, free (zero tokens, no plugin), and reuses the team's existing husky/lint-staged discipline — moved onto the agents' commit boundary.
- **+** Far less to build and maintain than the marker plugin; nothing custom in the commit critical path.
- **−** LLM review quality rests on prompt quality, not a mechanical block — acceptable because the objective breakage (types, lint, format) is what a hard gate can actually catch, and that is covered.
- **Revisit** a plugin only if the controller is observed committing without running the review gates.

## Rejected alternatives

Marker/tree-hash hook plugin (holed, above) · in-hook static analysis (a worse reinvented pre-commit hook: regex false-positives, no-tsconfig bootstrap deadlock, synchronous multi-minute tool calls) · 3-model jury on the quality axis (correlated blind spots, rate-limit cost, false-positive union on security rules).
