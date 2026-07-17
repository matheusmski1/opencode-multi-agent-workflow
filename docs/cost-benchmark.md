# Cost benchmark — measure the workflow's real cost

Estimates are estimates. This runs a fixed task suite through the actual OpenCode multi-agent workflow (on the Go plan) and captures the **real metered cost**, so you can compare task sizes, see the iteration overhead for real, and find where the money goes.

## How the Go plan meters (what you're actually measuring)

The Go plan does **not** cap on requests or tokens — it caps on **dollar-equivalent at OpenCode Zen prices**:

- **$12 per rolling 5-hour window · $30 per week · $60 per month.**

So "the cost of a task" = the **Zen dollars** it consumes. The models this workflow uses, at Zen prices (input / output per 1M tokens):

| Role | Model | in $/1M | out $/1M |
|---|---|---|---|
| Controller / implementer-complex | `glm-5.2` | 1.40 | 4.40 |
| Implementer-mechanical | `deepseek-v4-flash` | 0.14 | 0.28 |
| Debug specialist | `deepseek-v4-pro` | 1.74 | 3.48 |
| Spec gate | `qwen3.7-plus` | 0.40 | 1.60 |
| Quality gate | `kimi-k2.7-code` | 0.95 | 4.00 |

(Prices as of the research note; reconfirm with `/models` and the Zen docs. None of these charge a long-context premium.)

## Setup (once)

```bash
cd bench/fixture
npm install                 # or: pnpm install
```

> If `pnpm run <script>` errors with a corepack/deps-status trace, run the binaries directly
> (`./node_modules/.bin/tsc --noEmit`, `./node_modules/.bin/vitest run`) or use npm.

Confirm the baseline is green (it is by design — one bug is *intentionally* seeded for task L2 and is documented in `src/service.ts`; leave it):

```bash
./node_modules/.bin/tsc --noEmit      # no type errors
./node_modules/.bin/vitest run        # 3 tests pass
```

Wire the free objective gate (husky: tsc + commitlint) into the fixture, and make sure the workflow itself is installed and Zen is connected:

```bash
../../scripts/setup-husky.sh .        # from bench/fixture — tsc + commitlint on commit
../../scripts/setup.sh                 # installs the skill + subagents + controller config
# in OpenCode: /connect → OpenCode Zen (Go plan)
```

Commit the fixture so you can reset between runs:

```bash
git add -A && git commit -m "chore: bench fixture baseline"
```

## Measurement protocol (per task)

The Go plan bills every Zen call — including subagents — to your account, so the **Zen usage dollar delta is the authoritative per-task cost** (no need to sum per-agent). Steps:

1. **Fresh session** per task (so cost is isolated). Run OpenCode in `bench/fixture`.
2. Note your **Zen usage $** in the OpenCode Zen account portal (opencode.ai/auth) — the value *before* the task.
3. Give the task's prompt (below, verbatim) to the **controller** (the `build` agent). Let it dispatch the gates; don't intervene.
4. When it reports done (or commits), note the **Zen usage $** *after*. **Delta = the task's cost.**
5. Record, from the run: number of review rounds (bounces), which gate(s) FAILed, whether husky caught anything, wall-clock, and the per-session token count OpenCode shows (secondary cross-check).
6. **Reset the fixture** before the next run: `git checkout -- bench/fixture && git clean -fd bench/fixture` (discard the change so every run starts from the same baseline).
7. Run each task **3×** (models are non-deterministic) and take the **median**.

## Task suite

Give each prompt to the controller verbatim. Sizes are calibrated to the fixture (`src/{types,repository,service,index}.ts` + one test file).

| ID | Size | Prompt to give the controller | Touches | Expectation |
|---|---|---|---|---|
| **S1** | small | *"Add a `priority` field to Task (values `'low' \| 'medium' \| 'high'`, default `'medium'`) and thread it through `createTask` and `CreateTaskInput`. Update the tests."* | types, service, test | Clean first pass |
| **S2** | small (mechanical) | *"Rename `completeTask` to `markDone` everywhere — the method, its callers, and the tests. No behavior change."* | service, index, test | Mechanical; should route to the cheap implementer |
| **M1** | medium | *"Add an optional `dueDate` (ISO-8601 string) to tasks. `createTask` must reject a `dueDate` in the past with a clear error. Add tests for both the accepted and rejected cases."* | types, service, test | Real validation + tests; maybe 1 bounce |
| **M2** | medium (bounce-prone) | *"Add a `mergeTasks(ids: string[]): Task` method that combines several tasks into one and removes the originals."* | service, test | Edge-heavy (empty array, unknown id, status conflicts) — the quality gate should catch missing cases |
| **L1** | large | *"Introduce a `TaskStore` interface, make `InMemoryTaskRepository` implement it, add a `JsonFileTaskStore` implementation backed by a JSON file, let `TaskService` take any `TaskStore`, and add tests for both stores."* | new interface, repo, new file, service, tests | Multi-file feature; expect 1–2 bounces |
| **L2** | large (debug) | *"Archived tasks are showing up in `listOpen()` — they shouldn't. Reproduce it, find the root cause, fix it, and add a regression test."* | service, test | Exercises the debug specialist; targets the seeded gap in `listOpen` |

Notes:
- **M2** and **L1** are the iteration probes — they're written so a first pass usually misses an edge case, so you measure a real bounce. If a run passes clean, that's a valid data point too (record it).
- **L2** is the debug probe — the bug is real and reproducible (`archiveTask` sets `'archived'`, but `listOpen` only excludes `'done'`).

## Results template

Copy this, fill it in as you run:

```
Task | Run | Zen $ delta | Session tokens | Rounds | Gate FAILs (spec/qual) | husky FAIL | Wall-clock
S1   | 1   |             |                |        |                        |            |
S1   | 2   |             |                |        |                        |            |
S1   | 3   |             |                |        |                        |            |
...
```

Then summarize:

| Size | Median $ | Median tokens | Median rounds | Tasks per $12 / 5h | Tasks per $60 / month |
|---|---|---|---|---|---|
| Small (S1, S2) | | | | `12 / median$` | `60 / median$` |
| Medium clean (M1) | | | | | |
| Medium bounced (M2) | | | | | |
| Large (L1) | | | | | |
| Large debug (L2) | | | | | |

## Analysis

- **Iteration overhead** = `bounced $ / clean $` for a comparable size (e.g. M2 vs M1). This is the real number behind "a task that comes back costs more."
- **Throughput on the flat plan** = `$12 / median$` (per 5h burst) and `$60 / median$` (per month). Below that, the $10/mo plan is pure savings; above it you drop to free models or spend Zen balance.
- **Where the money concentrates** — break the Zen delta down mentally by role (the portal or session tokens help). The implementer on `glm-5.2` ($4.40 out) is expected to dominate; the gates are cheap; husky is $0.
- **Compare to the estimate** in this repo's cost analysis to calibrate how far off the paper numbers were.

## Levers to test (does the measured cost confirm them?)

- Route the implementer for **mechanical** tickets (like S2) to `deepseek-v4-flash` (~16× cheaper output than glm) and re-measure — how much does it save?
- Does catching an error at the **spec gate** (cheap) vs letting the **quality gate** or a human catch it later change the total? (Compare M2 runs that bounce early vs late.)
- Confirm **husky** (free, local) catching a type/lint error is cheaper than any model round.
