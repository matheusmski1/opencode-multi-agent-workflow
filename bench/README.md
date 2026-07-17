# bench — cost benchmark fixture

A small, self-contained TypeScript project used to measure the real cost of the multi-agent workflow on the OpenCode Go plan.

- **`fixture/`** — a tiny in-memory task-tracker (types, repository, service, tests). Compiles clean and its 3 tests pass at baseline. `src/service.ts` contains **one intentionally seeded bug** (documented in a comment) that the L2 debug task targets — don't pre-fix it.
- The task suite, measurement protocol, and results template live in **[`../docs/cost-benchmark.md`](../docs/cost-benchmark.md)**.

Quick baseline check:

```bash
cd fixture
npm install
./node_modules/.bin/tsc --noEmit   # clean
./node_modules/.bin/vitest run     # 3 pass
```

Then follow `docs/cost-benchmark.md` to run the tasks through the workflow and record the Zen dollar delta per task.
