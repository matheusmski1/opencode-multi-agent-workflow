# Model selection — cost/benefit per role (opencode Go pool)

How each subagent's model was chosen. The rule is **best cost-benefit for the role**, not "cheapest that works" and not "always the strongest".

## Why the optimization changed

The original repo routed for **price per token** — correct when billing is metered (OpenRouter). On the **opencode Go** plan the model access is **flat-rate**, so per-token price no longer bills directly. What is still scarce is the **rate limit** (generous requests per rolling 5-hour window). So the real cost of a model is *how much of that window it burns*, which tracks its underlying compute (a proxy: its per-token price elsewhere).

That flips the heuristic:

> Spend capability where it decides the outcome (gates, debugging). Save on volume (bulk implementation, mechanical edits). A strong model on a gate that runs occasionally is cheap; the same model writing every line burns the whole window.

## Cost basis (proxy for rate-limit weight)

Output $/1M tokens from `research/llm-coding-agents-cost-benefit.md` (dated 2026-07-12) as a stand-in for how heavily each model draws down the Go window. **Reconfirm with `/models` and your own usage — these are proxies, not the Go plan's actual weights.**

| Model (opencode Zen) | Out $/1M (proxy) | Coding idx | Standout signal |
|---|---|---|---|
| `deepseek-v4-flash` | 0.15 | 56.2 | cheapest capable; `-free` variant exists |
| `deepseek-v4-pro` | 0.87 | 59.4 | **Codeforces 3206 · LiveCodeBench 93.5 · SWE-bench Verified 80.6** — best hard-reasoning per dollar |
| `qwen3.7-plus` | 1.28 | 55.9 | cheap, careful reader |
| `glm-5.2` | 1.32 | 68.8 | agentic 43.1 · **Terminal-Bench 81.0** · 1M ctx — best all-round open coder per dollar |
| `kimi-k2.7-code` | 3.50 | 60.8 | coding-specialized, mandatory reasoning |
| `qwen3.7-max` | 3.75 | 66.0 | strong generalist coder |
| `grok-4.5` | 6.00 | 72.4 | agentic 45.7 — strongest raw, worst CxB |
| `claude-sonnet-5` | 10.00 | 71.5 | **outside the Go flat plan** (metered Zen) |

## Assignment and rationale

| Role | Model | reasoningEffort | Why this is the best CxB for the role |
|---|---|---|---|
| Implementer — complex | `glm-5.2` | high | Highest-token role, so CxB matters most. GLM-5.2 gives the best capability-per-dollar of the strong coders, with the 1M context multi-file work needs. |
| Implementer — mechanical | `deepseek-v4-flash` | — | High volume, trivial edits → cheapest capable model. Use the `-free` variant for throwaway work to spend zero window. |
| Debug specialist | `deepseek-v4-pro` | high | Debugging is low-volume but high-value and reasoning-bound. This model is the pool's best hard-reasoner **and** cheap ($0.87) — the standout CxB pick. Different family from the implementer. |
| Spec gate | `qwen3.7-plus` | high | Spec review is careful reading, not heavy coding — no need to overpay. Cheap, reliable, different family. Bump to `qwen3.7-max` for large/complex specs. |
| Quality gate | `kimi-k2.7-code` | high | The highest-stakes gate, but low-volume — worth spending on a coding-specialist, different family. Not `grok-4.5` by default: 6% more capability for ~70% more window burn is poor routine CxB. |

Four distinct model families across the pipeline, so every gate is a genuine second opinion, never a model grading its own output.

## Escalation levers (spend more only when stakes justify it)

- **Quality gate on critical changes** (auth, payments, migrations, public API): switch the code-quality reviewer to `opencode-go/grok-4.5` (still inside Go) or `opencode-go/claude-sonnet-5` (sharpest, bills outside the flat plan).
- **Complex spec review**: bump the spec gate to `opencode-go/qwen3.7-max`.
- **Deeper reasoning on any role**: raise `reasoningEffort` (`high` → `xhigh` where the model supports it: DeepSeek V4 family, GLM-5.2).

## Caveats

- Benchmark indexes here are proxies (Artificial Analysis / provider tables), not ground truth for *your* codebase. Treat the assignment as a strong prior, then A/B two models on a real ticket before freezing.
- The Go pool changes. Newer entries (Kimi K3, MiniMax M3, MiMo-V2.5) had no independent benchmarks at time of writing — validate them on your own work before trusting them on a gate.
