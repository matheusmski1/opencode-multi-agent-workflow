# opencode-multi-agent-workflow

A skill-based multi-agent development workflow for [OpenCode](https://opencode.ai). Routes work to specialized subagents — each running on the cheapest model that can reliably do the job — through the full pipeline: planning, implementation, review, and completion.

## What this gives you

- **Workflow router** — picks the right skill for each situation (wayfinder, brainstorming, grill-with-docs, implement, diagnosing-bugs, triage, prototype)
- **Multi-agent model routing** — controller on GLM-5.2, implementers on GLM-5.2 / DeepSeek V4 Flash, reviewers on Claude Sonnet 5, with cost-benefit rationale
- **5 specialized subagents** — implementer-complex, implementer-mechanical, spec-reviewer, code-quality-reviewer, debug-specialist
- **Structured review loop** — implementer → spec reviewer → code-quality reviewer, with re-review on failure

## Prerequisites

1. **[OpenCode](https://opencode.ai)** installed
2. **OpenRouter** connected — run `/connect` in OpenCode and add your API key
3. **Superpowers skill collection** — the workflow router references skills from [superpowers](https://github.com/obra/superpowers) (wayfinder, brainstorming, grill-with-docs, implement, tdd, code-review, etc.). Install them first, or adapt the router in `SKILL.md` to your own skills.

## Installation

```bash
git clone https://github.com/matheusmski1/opencode-multi-agent-workflow.git
cd opencode-multi-agent-workflow
chmod +x scripts/setup.sh
./scripts/setup.sh
```

Then **restart OpenCode** for the changes to take effect.

The setup script:
1. Copies 5 subagent templates to `~/.config/opencode/agents/`
2. Injects model routing and `build` agent config into `~/.config/opencode/opencode.json`

## Usage

Once installed, OpenCode's controller (`build` agent) runs on GLM-5.2 and can route work to subagents. Invoke them by mentioning `@agent-name` in your messages:

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

Edit `SKILL.md` and the agent templates in `agents/` to change which models are used. The research note in `research/llm-coding-agents-cost-benefit.md` has the cost-benefit analysis that informed the defaults.

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
│   └── setup.sh               # one-time installer
├── research/
│   └── llm-coding-agents-cost-benefit.md   # model cost-benefit analysis
└── README.md
```

## License

MIT
