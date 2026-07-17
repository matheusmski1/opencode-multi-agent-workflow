---
name: multi-agent-workflow
description: Multi-agent software development workflow for OpenCode. Routes work to specialized subagents (implementer, spec reviewer, code-quality reviewer, debug specialist) with per-agent model routing for cost-efficiency. Use when the user wants to develop features, fix bugs, or run a structured development workflow with multiple agents. Covers the full pipeline: planning (wayfinder, brainstorming, grill-with-docs) through implementation (subagent-driven-development) to review (code-review) and completion.
---

# Multi-Agent Workflow

A skill-based development workflow that routes work to specialized subagents, each running on the cheapest model that can reliably do the job. Built for OpenCode with OpenRouter, but adaptable to any multi-agent environment.

## Prerequisites

This skill assumes the following are already installed and configured:

1. **OpenCode** with OpenRouter connected (`/connect` → OpenRouter)
2. **Subagents installed** via `scripts/setup.sh` (see README)
3. **Skill library** — the workflow references skills from the `superpowers` skill collection (wayfinder, brainstorming, grill-with-docs, implement, tdd, code-review, etc.). Install them first or adapt the router to your own skills.

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

When delegating to subagents, pick the cheapest model that can reliably do the job. Prices and rankings change — recheck the research note (`research/llm-coding-agents-cost-benefit.md`) before freezing long-term routing.

| Role | Primary model | Fallback | Rationale |
|---|---|---|---|
| Controller / planner / brainstorming | `z-ai/glm-5.2` | `deepseek/deepseek-v4-pro` | Best price/performance + 1M context |
| Implementer — complex tasks | `z-ai/glm-5.2` | `deepseek/deepseek-v4-pro` | Strongest open-model coding scores at low cost |
| Implementer — mechanical tasks | `deepseek/deepseek-v4-flash` | `poolside/laguna-xs-2.1` | Cheapest models with 1M context |
| Spec reviewer | `z-ai/glm-5.2` | `anthropic/claude-sonnet-5` | Strong reasoning for spec gaps; promote for high-stakes specs |
| Code-quality reviewer | `anthropic/claude-sonnet-5` | `z-ai/glm-5.2` | Sharper for architecture/security critique |
| Debug specialist | `anthropic/claude-sonnet-5` | `z-ai/glm-5.2` | Reasoning + large context for root-cause analysis |
| High-volume / low-stakes | `deepseek/deepseek-v4-flash` | `poolside/laguna-xs-2.1` | Minimize spend on mechanical, throwaway work |

**Rules of thumb:**
- Prefer GLM-5.2 for any reasoning-heavy role where context fits in 1M tokens.
- Use DeepSeek V4 Pro as a cheaper alternative with the same 1M context.
- Reserve Claude Sonnet 5 for review, debugging, or architecture when quality matters more than cost (watch intro-pricing expiration).
- Start mechanical implementers on DeepSeek V4 Flash; promote to stronger models only if the task fails.

## Subagents

The following subagents are installed by `scripts/setup.sh` and live in `~/.config/opencode/agents/`. Invoke them by mentioning `@agent-name` in a message.

| Agent | Model | Use when |
|---|---|---|
| `@implementer-complex` | `openrouter/z-ai/glm-5.2` | Multi-file implementation, integration, debugging |
| `@implementer-mechanical` | `openrouter/deepseek/deepseek-v4-flash` | Small isolated edits, boilerplate, formatting |
| `@spec-reviewer` | `openrouter/z-ai/glm-5.2` | Check spec compliance |
| `@code-quality-reviewer` | `openrouter/anthropic/claude-sonnet-5` | Deep architecture/security review |
| `@debug-specialist` | `openrouter/anthropic/claude-sonnet-5` | Root-cause analysis |

**Workflow order per ticket:** `@implementer-complex` → `@spec-reviewer` → `@code-quality-reviewer`. Only move forward after each agent reports approval. If the spec reviewer finds gaps, the implementer fixes them and the spec reviewer re-reviews. If the code-quality reviewer finds issues, the implementer fixes them and the code-quality reviewer re-reviews.

**Never** dispatch two implementers in parallel on the same worktree — they will conflict. If tasks are independent and touch separate files, use `dispatching-parallel-agents` with isolated worktrees.

## Code standards

- TypeScript strict, const-first, async/await over callbacks, template literals.
- No comments in code — self-explanatory naming instead.
- Proper error handling on every async operation. SOLID and clean code.

## Verify, don't assume

Never assume where data or flows come from. Chase the real source — repo code, git history, live API — and cite `file:line` before asserting. If you can't verify, say so and ask.
