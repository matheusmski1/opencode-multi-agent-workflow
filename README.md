# opencode-multi-agent-workflow

A skill-based multi-agent development workflow for [OpenCode](https://opencode.ai). Routes work to specialized subagents — each running on the cheapest model that can reliably do the job — through the full pipeline: planning, implementation, review, and completion.

## What this gives you

- **Workflow router (auto-loaded)** — picks the right skill for each situation (wayfinder, brainstorming, grill-with-docs, implement, diagnosing-bugs, triage, prototype). The skill auto-loads when you ask OpenCode to develop features or fix bugs.
- **Multi-agent model routing** — controller on GLM-5.2, implementers on GLM-5.2 / DeepSeek V4 Flash, reviewers on Claude Sonnet 5, with cost-benefit rationale.
- **5 specialized subagents** — implementer-complex, implementer-mechanical, spec-reviewer, code-quality-reviewer, debug-specialist.
- **Structured review loop** — implementer → spec reviewer → code-quality reviewer, with re-review on failure.

## How it works automatically

After running `setup.sh` and restarting OpenCode, three layers work together without manual intervention:

| Layer | What it does | How it loads |
|---|---|---|
| **Skill** (`SKILL.md`) | Tells the controller the workflow: which skill to use when, model routing table, subagent order, code standards, verify-don't-assume | OpenCode scans `~/.config/opencode/skills/` on startup and auto-loads the skill when its description matches your request (model-invoked) |
| **Subagents** (`agents/*.md`) | 5 specialized agents with their own models and permissions, installed to `~/.config/opencode/agents/` | OpenCode loads all agent files on startup; invoke via `@agent-name` or the controller dispatches automatically based on the skill's instructions |
| **Config** (`opencode.json`) | Sets the `build` (controller) agent to GLM-5.2, enables `task` permission so it can dispatch subagents, sets `small_model` to DeepSeek V4 Flash | Loaded once on startup |

**Flow:** you ask OpenCode to implement a feature → the skill auto-loads → the controller (GLM-5.2) reads the workflow router → picks the right approach (brainstorming, implement, etc.) → dispatches subagents in the correct order (implementer → spec-reviewer → code-quality-reviewer) → each subagent runs on its configured model → results flow back to you.

**You do not need to manually invoke `@agent-name`** — the controller does it automatically based on the skill's instructions. You can still invoke subagents manually if you want.

## Prerequisites

1. **[OpenCode](https://opencode.ai)** installed
2. **OpenRouter** connected — run `/connect` in OpenCode and add your API key
3. **Superpowers skill collection** — the workflow router references skills from [superpowers](https://github.com/obra/superpowers) (wayfinder, brainstorming, grill-with-docs, implement, tdd, code-review, etc.). Install them first, or adapt the router in `SKILL.md` to your own skills. The setup script checks for these and warns if missing.

## Installation

```bash
git clone https://github.com/matheusmski1/opencode-multi-agent-workflow.git
cd opencode-multi-agent-workflow
chmod +x scripts/setup.sh
./scripts/setup.sh
```

Then **restart OpenCode** for the changes to take effect.

The setup script:
1. Checks prerequisites (python3, OpenCode, superpowers skills)
2. Copies `SKILL.md` to `~/.config/opencode/skills/multi-agent-workflow/SKILL.md`
3. Copies 5 subagent templates to `~/.config/opencode/agents/`
4. Injects model routing and `build` agent config into `~/.config/opencode/opencode.json`

## Usage

After setup, just work normally in OpenCode. The skill auto-loads when you ask to develop features, fix bugs, or run a structured workflow. The controller routes work to the right subagents automatically.

You can also manually invoke subagents:

```
@implementer-complex implement the user authentication feature
@spec-reviewer review the changes against the spec
@code-quality-reviewer review the code for architecture and security
```

### Full workflow per ticket

```
1. @implementer-complex   → implements the task
2. @spec-reviewer         → checks spec compliance
3. @code-quality-reviewer → checks code quality
```

Only move forward after each agent reports approval. If a reviewer finds issues, the implementer fixes them and the reviewer re-reviews.

## Customization

### Models

Edit `SKILL.md` and the agent templates in `agents/` to change which models are used. The research note in `research/llm-coding-agents-cost-benefit.md` has the cost-benefit analysis that informed the defaults. Recheck prices on OpenRouter before freezing long-term routing.

### Skills

The workflow router in `SKILL.md` references skills from the superpowers collection. If you use a different skill set, edit the router table to match your skills.

### Agent prompts

Each agent in `agents/` is a markdown file with frontmatter (`model`, `mode`, `permission`, `temperature`) and a system prompt. Edit them to match your code standards and workflow.

## Structure

```
opencode-multi-agent-workflow/
├── SKILL.md                    # workflow router + model routing + subagents + principles
├── agents/                     # subagent templates
│   ├── implementer-complex.md
│   ├── implementer-mechanical.md
│   ├── spec-reviewer.md
│   ├── code-quality-reviewer.md
│   └── debug-specialist.md
├── scripts/
│   └── setup.sh               # one-time installer (skill + agents + config)
├── research/
│   └── llm-coding-agents-cost-benefit.md   # model cost-benefit analysis
└── README.md
```

## License

MIT