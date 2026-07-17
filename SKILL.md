---
name: multi-agent-workflow
description: Multi-agent software development workflow for OpenCode. Routes work to specialized subagents (implementer, spec reviewer, code-quality reviewer, debug specialist) with per-agent model routing for cost-efficiency. Use when the user wants to develop features, fix bugs, or run a structured development workflow with multiple agents. Covers the full pipeline: planning (wayfinder, brainstorming, grill-with-docs) through implementation (subagent-driven-development) to review (code-review) and completion.
---

# Multi-Agent Workflow

A skill-based development workflow that routes work to specialized subagents, each running on the cheapest model that can reliably do the job. Built for OpenCode with the OpenCode Zen provider (`opencode Go` plan), but adaptable to any provider or multi-agent environment.

## Prerequisites

This skill assumes the following are already installed and configured:

1. **OpenCode** with an OpenCode Zen provider connected (`/connect` → OpenCode Zen). The `opencode Go` plan gives flat-rate access to the open-model pool used below.
2. **Subagents installed** via `scripts/setup.sh` (see README)
3. **Skill library** — the router below references skills from **[mattpocock/skills](https://github.com/mattpocock/skills)** (wayfinder, to-spec, to-tickets, implement, tdd, code-review, diagnosing-bugs, triage, prototype, grill-with-docs, ask-matt, handoff). Install that collection first, or adapt the router to your own skills. `brainstorming` is the one row sourced from [obra/superpowers](https://github.com/obra/superpowers) and is optional.

## Workflow router

Route work to the skill that fits the situation. Load skills with the skill tool when triggered.

| Situation | Skill | Why |
|---|---|---|
| Huge, foggy, multi-session effort (destination unclear; a plan written now would have TBDs) | `wayfinder` | Chart a map of investigation tickets, resolve ONE per session, produce decisions not deliverables. When the way is clear, merge into `to-spec`. |
| Idea from scratch, fits one session, repo exists | `brainstorming` | Explores context, asks clarifying questions one at a time, proposes approaches, writes design doc, then invokes `writing-plans`. |
| Sharpening an existing plan/design and producing docs (ADRs, glossary) | `grill-with-docs` | Relentless interview that sharpens the plan and produces domain documentation. |
| Multi-session build with a clear plan | `to-spec` → `to-tickets` | Turn the conversation into a spec, then break it into tracer-bullet tickets with blocking edges. |
| Implementation per ticket | `implement` | Drives `tdd` internally and closes with `code-review` before committing. Fresh context per ticket. |
| Something is broken | `diagnosing-bugs` | Build a tight feedback loop first (one command that goes red on this bug), then fix with a regression test. |
| Raw incoming issues/requests | `triage` | Categorise, verify, grill if needed, write agent-ready briefs. Never use for tickets `to-tickets` created — those are already agent-ready. |
| Design question that needs a runnable answer | `prototype` | Throwaway code, bridged with `handoff` in both directions. |
| Unsure which skill fits | `ask-matt` | Router over the skill collection. |

**Sizing rule:** if an implementation plan could be written right now with no unknowns, it is not a wayfinder case. When in doubt, suggest `wayfinder` — its charting step aborts on its own if no fog surfaces.

**Context hygiene:** keep grill → spec → tickets in one unbroken session. Do not compact mid-phase. Use `handoff` to fork into a fresh session.

## Multi-agent model routing

All IDs below are OpenCode Zen (`opencode/<id>`) models in the `opencode Go` open-model pool, so the whole pipeline runs inside the flat-rate plan. On a flat plan the scarce resource is the **rate limit**, not per-token price — so route for **best cost-benefit per role**: spend capability where it decides the outcome (gates, debugging), stay cheap on volume (bulk + mechanical). Full rationale, cost basis, and escalation levers in **`docs/model-selection.md`**. Rankings change — reconfirm with `/models` before freezing.

| Role | Model | reasoningEffort | Why (CxB) |
|---|---|---|---|
| Controller / planner | `opencode/glm-5.2` | high | Best capability-per-dollar all-round open coder, 1M context |
| Implementer — complex | `opencode/glm-5.2` | high | Highest-token role; GLM-5.2 wins CxB there |
| Implementer — mechanical | `opencode/deepseek-v4-flash` | — | Cheapest capable; `-free` variant for throwaway work |
| Debug specialist | `opencode/deepseek-v4-pro` | high | Pool's best hard-reasoner **and** cheap — standout CxB; different family |
| Spec gate | `opencode/qwen3.7-plus` | high | Careful reading is cheap; different family |
| Quality gate | `opencode/kimi-k2.7-code` | high | Highest-stakes, low-volume gate → coding-specialist, different family; escalate to `grok-4.5` / `claude-sonnet-5` for critical PRs |

**Rules of thumb:**
- Four distinct model families across the pipeline, so every gate is a genuine second opinion — never a model grading its own output.
- Gates and debugging run occasionally: paying for a stronger model there is cheap. Bulk implementation runs constantly: keep it lean.
- `grok-4.5` is the strongest raw coder in the pool but the worst CxB — reserve it (or metered `claude-sonnet-5`) for the quality gate on critical changes, not routine work.
- Raise `reasoningEffort` to `xhigh` for the hardest debug/review passes where the model supports it (DeepSeek V4 family, GLM-5.2).

## Subagents

The following subagents are installed by `scripts/setup.sh` and live in `~/.config/opencode/agents/`. Invoke them by mentioning `@agent-name` in a message.

| Agent | Model | Use when |
|---|---|---|
| `@implementer-complex` | `opencode/glm-5.2` | Multi-file implementation, integration |
| `@implementer-mechanical` | `opencode/deepseek-v4-flash` | Small isolated edits, boilerplate, formatting |
| `@spec-reviewer` | `opencode/qwen3.7-plus` | Spec-compliance gate (blocks until PASS) |
| `@code-quality-reviewer` | `opencode/kimi-k2.7-code` | Code-quality gate (blocks until PASS) |
| `@debug-specialist` | `opencode/deepseek-v4-pro` | Root-cause analysis |

**Workflow order per ticket:** `@implementer-complex` → `@spec-reviewer` → `@code-quality-reviewer`. Only move forward after each agent reports approval. If the spec reviewer finds gaps, the implementer fixes them and the spec reviewer re-reviews. If the code-quality reviewer finds issues, the implementer fixes them and the code-quality reviewer re-reviews.

**Never** dispatch two implementers in parallel on the same worktree — they will conflict. If tasks are independent and touch separate files, use `dispatching-parallel-agents` with isolated worktrees.

## Enforcement — what actually blocks vs what is prose

Two layers, by design. An LLM review cannot be *truly* hard-gated — the reviewer produces the verdict, so a PASS marker it writes for itself is theater against a misaligned agent. So the hard block lives where it is honest (the objective toolchain), and the LLM review stays prose.

**Hard gate (deterministic, no plugin — native permission + husky):**
- Commit is the controller's exclusive act. The implementer and debug subagents `deny` `git commit`/`git push` in their frontmatter; only the controller commits.
- The controller cannot dodge the toolchain either: `--no-verify` and `git push --force`/`-f` are denied for it.
- On the controller's commit, the target project's **husky** hooks run: `tsc --noEmit` + `eslint --max-warnings 0` (pre-commit, via lint-staged) and `commitlint` (commit-msg). Non-zero exit aborts the commit — the agent's work is gated by the same objective checks a human's is. Scaffold them into a repo with `scripts/setup-husky.sh`.

**Prose gate (LLM, run by the controller before it commits):**
- Spec gate (`@spec-reviewer`) then quality gate (`@code-quality-reviewer`), each delta-scoped to the pinned three-dot diff, each requiring `file:line` evidence, each returning PASS/FAIL. The controller commits only on PASS; on FAIL the implementer fixes and the gate re-reviews.
- Quality review is a **single** reviewer. For a high-stakes diff (auth, payments, migrations, public API), get a second opinion from a different-family model and break the tie yourself — no automated jury (2-of-3 mid-tier models launder confidence and burn the rate-limit window without raising bug recall).
- The debug specialist is capped at 3 failed fix attempts, then escalates to architecture review instead of thrashing.

## Code standards

- TypeScript strict, const-first, async/await over callbacks, template literals.
- No comments in code — self-explanatory naming instead.
- Proper error handling on every async operation. SOLID and clean code.

## Verify, don't assume

Never assume where data or flows come from. Chase the real source — repo code, git history, live API — and cite `file:line` before asserting. If you can't verify, say so and ask.
