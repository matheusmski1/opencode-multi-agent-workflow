# Cost-Benefit Analysis: OpenRouter Coding Agents (July 2026)

**Date:** 2026-07-12  
**Sources:** OpenRouter API/models pages, official provider docs / blogs, SWE-bench / Aider / LiveCodeBench / BigCodeBench leaderboards where data exists.  

## TL;DR Summary

This note compares current OpenRouter-hosted LLMs that are relevant to multi-agent software engineering. Prices are shown per 1M tokens in USD, computed from the OpenRouter `/api/v1/models` endpoint on 2026-07-12. Benchmarks are taken from official provider pages or from OpenRouter's published `artificial_analysis` and `design_arena` indexes when an independent public score is not yet available.

### Selected models at a glance

| OpenRouter ID | Provider | Capabilities | Input / Cache read / Cache write / Output ($/1M) | Coding Idx | Agentic Idx | Best-fit roles | Value note |
|---|---|---|---|---|---|---|---|
| `deepseek/deepseek-v4-pro` | DeepSeek | text->text; 1,048,576 ctx; max out 384,000; reasoning optional; efforts: xhigh,high; tools ✓ | $0.435 / $0.00363 / — / $0.87 | 59.4 | 36.4 | Implementer-complex, controller/orchestrator, spec reviewer | Extremely cheap for top-tier agentic coding; best dollar-for-dollar for complex implementation. |
| `deepseek/deepseek-v4-flash` | DeepSeek | text->text; 1,048,576 ctx; max out 384,000; reasoning optional; efforts: xhigh,high; tools ✓ | $0.077 / $0.0154 / — / $0.154 | 56.2 | 31.1 | Implementer-mechanical, high-volume pre-filter, light controller | Among cheapest non-free models; good for mechanical tasks and simple agents. |
| `moonshotai/kimi-k2.5` | MoonshotAI | text+image->text; 262,144 ctx; reasoning default; tools ✓ | $0.375 / $0.203 / — / $2.025 | — | — | Implementer-complex, visual/debug specialist, code-quality reviewer | Mid-price coding+vision option; strong for front-end and visual debugging. |
| `moonshotai/kimi-k2.6` | MoonshotAI | text+image->text; 262,144 ctx; max out 262,144; reasoning default; tools ✓ | $0.66 / $0.15 / — / $3.41 | 61.8 | 30.3 | Implementer-complex, planner/brainstorming, controller/orchestrator | Strong open-source-class coding/agent scores at moderate price; good default for long-horizon coding agents. |
| `moonshotai/kimi-k2.7-code` | MoonshotAI | text+image->text; 262,144 ctx; max out 262,144; reasoning mandatory; tools ✓ | $0.72 / $0.15 / — / $3.5 | 60.8 | 29.6 | Implementer-complex, debug specialist, controller for coding tasks | Purpose-built coding model; moderate premium over K2.6 but higher efficiency. |
| `z-ai/glm-5` | Z.ai | text->text; 202,752 ctx; reasoning default; tools ✓ | $0.6 / $0.12 / — / $1.92 | — | — | Planner/brainstorming, long-horizon architect | Cheapest GLM entry with 202K context; use for long-context planning/system design, but upgrade to GLM-5.2 for 1M context and stronger coding. |
| `z-ai/glm-5.1` | Z.ai | text->text; 202,752 ctx; max out 128,000; reasoning default; tools ✓ | $0.966 / $0.1794 / — / $3.036 | 55.8 | 29.9 | Implementer-complex, spec reviewer | Step-up coding model; cheaper than frontier closed models. |
| `z-ai/glm-5.2` | Z.ai | text->text; 1,048,576 ctx; max out 131,072; reasoning default; efforts: xhigh,high; tools ✓ | $0.42 / $0.078 / — / $1.32 | 68.8 | 43.1 | Controller/orchestrator, implementer-complex, high-stakes review value | Best GLM coding score and still far cheaper than Claude Fable/GPT Sol; excellent price/performance. |
| `qwen/qwen3.5-397b-a17b` | Qwen | text+image+video->text; 256,000 ctx; reasoning optional; tools ✓ | $0.385 / $0.111 / — / $2.45 | 48.2 | 19.8 | Implementer-complex, controller/orchestrator | Strong open MoE with high SWE score; low per-token API cost. |
| `qwen/qwen3.5-122b-a10b` | Qwen | text+image+video->text; 262,144 ctx; max out 262,144; reasoning optional; tools ✓ | $0.26 / — / — / $2.08 | 45.7 | 20.7 | Implementer-complex, generalist | Competent generalist; verify price/performance empirically. |
| `qwen/qwen3.5-35b-a3b` | Qwen | text+image+video->text; 262,144 ctx; max out 81,920; reasoning optional; tools ✓ | $0.14 / $0.05 / — / $1 | — | — | Implementer-complex | Competent generalist; verify price/performance empirically. |
| `qwen/qwen3.5-27b` | Qwen | text+image+video->text; 262,144 ctx; max out 65,536; reasoning optional; tools ✓ | $0.195 / — / — / $1.56 | — | — | Implementer-mechanical/complex | Competent generalist; verify price/performance empirically. |
| `qwen/qwen3.5-9b` | Qwen | text+image+video->text; 262,144 ctx; max out 262,144; reasoning optional; tools ✓ | $0.1 / — / — / $0.15 | 28.7 | 7.4 | Implementer-mechanical | Competent generalist; verify price/performance empirically. |
| `qwen/qwen3.5-flash-02-23` | Qwen | text+image+video->text; 1,000,000 ctx; max out 65,536; reasoning optional; tools ✓ | $0.065 / — / — / $0.26 | — | — | Implementer-mechanical, high-volume | Competent generalist; verify price/performance empirically. |
| `qwen/qwen3.6-27b` | Qwen | text+image+video->text; 262,144 ctx; max out 262,140; reasoning default; tools ✓ | $0.285 / $0.15 / — / $2.4 | 53.7 | 27.0 | Implementer-mechanical/complex, debug specialist | Very cheap dense model; good for mechanical tasks and small agents. |
| `qwen/qwen3.6-35b-a3b` | Qwen | text+image+video->text; 262,144 ctx; max out 262,144; reasoning default; tools ✓ | $0.14 / — / — / $1 | 41.9 | 21.4 | Implementer-complex, controller/orchestrator | Best open Qwen coding option by official chart; low price. |
| `qwen/qwen3.6-plus` | Qwen | text+image+video->text; 1,000,000 ctx; max out 65,536; reasoning optional; tools ✓ | $0.325 / — / $0.4062 / $1.95 | 54.5 | 27.6 | Implementer-complex, generalist | Competent generalist; verify price/performance empirically. |
| `qwen/qwen3.6-flash` | Qwen | text+image+video->text; 1,000,000 ctx; max out 65,536; reasoning optional; tools ✓ | $0.1875 / — / $0.2344 / $1.125 | — | — | Implementer-mechanical, high-volume | Competent generalist; verify price/performance empirically. |
| `qwen/qwen3.6-max-preview` | Qwen | text->text; 262,144 ctx; max out 65,536; reasoning default; tools ✓ | $1.04 / — / $1.3 / $6.24 | — | — | Implementer-complex, controller | Competent generalist; verify price/performance empirically. |
| `qwen/qwen3.7-plus` | Qwen | text+image->text; 1,000,000 ctx; max out 65,536; reasoning default; tools ✓ | $0.32 / $0.064 / $0.4 / $1.28 | 55.9 | 20.8 | Implementer-complex, generalist | Latest Qwen iteration; competitive indexes, limited public benchmark details. |
| `qwen/qwen3.7-max` | Qwen | text->text; 1,000,000 ctx; max out 65,536; reasoning default; tools ✓ | $1.25 / $0.25 / $1.5625 / $3.75 | 66.0 | 30.6 | Implementer-complex, controller | Competent generalist; verify price/performance empirically. |
| `anthropic/claude-sonnet-5` | Anthropic | text+image+file->text; 1,000,000 ctx; max out 128,000; reasoning optional; efforts: max,xhigh,high,medium,low; tools ✓ | $2 / $0.2 / $2.5 / $10 | 71.5 | 46.7 | Controller/orchestrator, implementer-complex, code-quality reviewer | Best Anthropic price/performance for coding agents; OpenRouter currently reflects intro pricing ($2 in / $10 out). Standard pricing rises to $3/$15 after 2026-08-31. |
| `anthropic/claude-fable-5` | Anthropic | text+image+file->text; 1,000,000 ctx; max out 128,000; reasoning mandatory; efforts: max,xhigh,high,medium,low; tools ✓ | $10 / $1 / $12.5 / $50 | 76.5 | 52.8 | High-stakes review/architecture, planner/brainstorming | Premium capability for high-stakes review and architecture; not for high-volume generation. |
| `openai/gpt-5.6-sol` | OpenAI | text+image+file->text; 1,050,000 ctx; max out 128,000; reasoning default; efforts: max,xhigh,high,medium,low,none; tools ✓ | $5 / $0.5 / $6.25 / $30 | 77.4 | 54.0 | High-stakes review/architecture, controller/orchestrator | Top benchmark scores but premium pricing; use when results matter more than cost. |
| `openai/gpt-5.6-sol-pro` | OpenAI | text+image+file->text; 1,050,000 ctx; max out 128,000; reasoning default; efforts: max,xhigh,high,medium,low,none; tools ✓ | $5 / $0.5 / $6.25 / $30 | — | — | Same as Sol; use when reasoning.mode=pro is needed | Same underlying model as Sol, forced Pro reasoning; pay only if your harness needs reasoning.mode=pro. |
| `openai/gpt-5.6-terra` | OpenAI | text+image+file->text; 1,050,000 ctx; max out 128,000; reasoning default; efforts: max,xhigh,high,medium,low,none; tools ✓ | $2.5 / $0.25 / $3.125 / $15 | 76.7 | 47.4 | Implementer-complex, controller/orchestrator | Near-Sol scores at half cost; best GPT-5.6 family value. |
| `openai/gpt-5.6-terra-pro` | OpenAI | text+image+file->text; 1,050,000 ctx; max out 128,000; reasoning default; efforts: max,xhigh,high,medium,low,none; tools ✓ | $2.5 / $0.25 / $3.125 / $15 | — | — | Same as Terra; use when reasoning.mode=pro is needed | Same underlying model as Terra with Pro reasoning mode. |
| `openai/gpt-5.6-luna` | OpenAI | text+image+file->text; 1,050,000 ctx; max out 128,000; reasoning default; efforts: max,xhigh,high,medium,low,none; tools ✓ | $1 / $0.1 / $1.25 / $6 | 71.4 | 45.6 | Implementer-mechanical, high-volume steps | Cheapest GPT option; reserve for mechanical tasks and high-volume inference. |
| `openai/gpt-5.6-luna-pro` | OpenAI | text+image+file->text; 1,050,000 ctx; max out 128,000; reasoning default; efforts: max,xhigh,high,medium,low,none; tools ✓ | $1 / $0.1 / $1.25 / $6 | — | — | Same as Luna; use when reasoning.mode=pro is needed | Same underlying model as Luna with Pro reasoning mode. |
| `x-ai/grok-4.5` | xAI | text+image+file->text; 500,000 ctx; reasoning mandatory; efforts: high,medium,low; tools ✓ | $2 / $0.5 / — / $6 | 72.4 | 45.7 | Controller/orchestrator, generalist implementer | Fast frontier generalist; coding value lower than DeepSeek/GLM/Qwen open models. |
| `x-ai/grok-4.3` | xAI | text+image+file->text; 1,000,000 ctx; reasoning default; efforts: high,medium,low,none; tools ✓ | $1.25 / $0.2 / — / $2.5 | 42.2 | 24.1 | Generalist implementer | Lower-cost Grok; suitable for generalist chat and light coding. |
| `x-ai/grok-4.20` | xAI | text+image+file->text; 2,000,000 ctx; reasoning optional; tools ✓ | $1.25 / $0.2 / — / $2.5 | — | — | Controller/orchestrator | Large-context Grok with multi-agent support. |
| `x-ai/grok-4.20-multi-agent` | xAI | text+image+file->text; 2,000,000 ctx; reasoning mandatory; efforts: xhigh,high,medium,low; tools ✗ | $1.25 / $0.2 / — / $2.5 | — | — | Controller/orchestrator | 2M context variant; strong context but premium input price. |
| `google/gemini-3.1-pro-preview` | Google | text+image+file+audio+video->text; 1,048,576 ctx; max out 65,536; reasoning mandatory; efforts: high,medium,low; tools ✓ | $2 / $0.2 / $0.375 / $12 | 68.8 | 21.4 | Implementer-complex, controller/orchestrator | Mid-price generalist with strong context; coding value decent but not top. |
| `google/gemini-3.1-flash-lite` | Google | text+image+file+audio+video->text; 1,048,576 ctx; max out 65,536; reasoning default; efforts: high,medium,low,minimal; tools ✓ | $0.25 / $0.025 / $0.0833 / $1.5 | — | — | Implementer-mechanical, high-volume | Fast, cheap Gemini for high-volume simple tasks. |
| `google/gemini-3.1-flash-lite-preview` | Google | text+image+file+audio+video->text; 1,048,576 ctx; max out 65,536; reasoning default; efforts: high,medium,low,minimal; tools ✓ | $0.25 / $0.025 / $0.0833 / $1.5 | 34.7 | 6.2 | Implementer-mechanical, high-volume | Competent generalist; verify price/performance empirically. |
| `google/gemini-3.5-flash` | Google | text+image+file+audio+video->text; 1,048,576 ctx; max out 65,536; reasoning mandatory; efforts: high,medium,low,minimal; tools ✓ | $1.5 / $0.15 / $0.0833 / $9 | 70.1 | 37.4 | Implementer-complex, vision+code generalist | Low-cost long-context multimodal model; good generalist agent. |
| `nvidia/nemotron-3-ultra-550b-a55b` | NVIDIA | text->text; 1,000,000 ctx; max out 16,384; reasoning default; efforts: high,medium; tools ✓ | $0.5 / $0.1 / — / $2.2 | 49.3 | 27.4 | Orchestrator/controller | Very cheap large MoE; suitable for orchestration experiments. |
| `nvidia/nemotron-3-super-120b-a12b` | NVIDIA | text->text; 1,000,000 ctx; reasoning default; efforts: medium,low; tools ✓ | $0.08 / — / — / $0.45 | 37.7 | 8.7 | Implementer-mechanical, orchestrator | Cheapest large-context model on list; good for mechanical summarization/routing. |
| `nvidia/nemotron-3-nano-30b-a3b` | NVIDIA | text->text; 262,144 ctx; max out 228,000; reasoning optional; tools ✓ | $0.05 / — / — / $0.2 | 14.4 | 2.0 | Implementer-mechanical | Ultra-cheap small model for routing and mechanical extraction. |
| `poolside/laguna-m.1` | Poolside | text->text; 262,144 ctx; max out 32,768; reasoning default; tools ✓ | $0.2 / $0.1 / — / $0.4 | — | — | Implementer-complex (coding-agent specialized) | Coding-agent specialized; very cheap but limited public benchmarks. |
| `poolside/laguna-xs-2.1` | Poolside | text->text; 262,144 ctx; max out 32,768; reasoning default; tools ✓ | $0.06 / $0.03 / — / $0.12 | — | — | Implementer-mechanical/coding | Cheapest non-free coding model on list; use for mechanical coding tasks. |
| `tencent/hy3` | Tencent | text->text; 262,144 ctx; reasoning optional; efforts: high,low,none; tools ✓ | $0.14 / $0.035 / — / $0.58 | — | — | Generalist agent/orchestrator | Ultra-cheap MoE for agentic workflows; benchmark claims not publicly detailed. |
| `nex-agi/nex-n2-pro` | Nex AGI | text+image->text; 262,144 ctx; max out 262,144; reasoning optional; tools ✓ | $0.25 / $0.025 / — / $1 | — | — | Generalist agent/orchestrator | Competitively priced 397B MoE; benchmark table not published. |
| `nex-agi/nex-n2-mini` | Nex AGI | text+image->text; 262,144 ctx; max out 262,144; reasoning optional; tools ✓ | $0.025 / $0.0025 / — / $0.1 | — | — | Light mechanical coding/agent | Competent generalist; verify price/performance empirically. |
| `cohere/north-mini-code:free` | Cohere | text->text; 256,000 ctx; max out 64,000; reasoning optional; tools ✓ | $0 / — / — / $0 | 36.5 | — | Implementer-mechanical coding | Zero API cost; best for experimentation, heavy pre-filtering, low-stakes mechanical tasks. Rate limits/reliability unknown. |

### Role definitions used in this note

- **Controller / orchestrator** – plans task decomposition, picks tools, routes sub-tasks to other agents.
- **Planner / brainstorming** – explores design space, writes specs, evaluates trade-offs.
- **Implementer-complex** – multi-file changes, integration, debugging, repository-level reasoning.
- **Implementer-mechanical** – isolated, small edits, formatting, boilerplate, lint fixes.
- **Spec reviewer** – checks plans and requirements against constraints.
- **Code-quality reviewer** – deep review, architecture criticism, security/edge-case analysis.
- **Debug specialist** – root-cause analysis, test-driven repair.

## Methodology & caveats

- **Prices:** computed from OpenRouter's per-token prices on 2026-07-12. Currencies are USD. Providers may run promotions (e.g., Anthropic Sonnet 5 intro pricing) or offer regional/usage discounts.
- **Context / completion / tool claims:** from the OpenRouter model metadata (`supported_parameters`, `reasoning`, `top_provider`).
- **Benchmarks:** Where an official provider table exists, it is cited directly with a URL. Some official tables are images; approximate numbers were extracted by OCR and labelled as such. The canonical SWE-bench, Aider, LiveCodeBench and BigCodeBench leaderboards do not yet list every 2026 model variant; in those cases the OpenRouter `artificial_analysis` coding/agentic index and `design_arena` ELO/rank are used as the best available proxy.
- **Best-fit roles and value notes:** judgement based on price × capability × context window; verify with your own workload.

## DeepSeek V4 family

> OpenRouter currently lists only **V4-Pro** and **V4-Flash**; the names "Max"/"High" in the DeepSeek API map to `reasoning_effort` settings (`high`/`max`) rather than separate endpoints. See DeepSeek docs (https://api-docs.deepseek.com/zh-cn/news/news260424).

### `deepseek/deepseek-v4-pro` — DeepSeek V4 Pro

- **Provider:** DeepSeek
- **Capabilities:** text->text; 1,048,576 ctx; max out 384,000; reasoning optional; efforts: xhigh,high; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.435** | cache-read **$0.00363** | cache-write **—** | output **$0.87**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/deepseek/deepseek-v4-pro
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 44.3, coding 59.4, agentic 36.4
- **Design Arena top coding category:** gamedev ELO 1291 (rank 20, 56% win rate)
- **Other benchmarks:** DeepSeek official V4 benchmark chart (Max/Pro-Max): SWE-bench Verified ~80.6%, SWE-bench Pro ~67.9%, Terminal-Bench 2.0 ~62.0, LiveCodeBench ~93.5, Codeforces rating 3206 — [source](https://api-docs.deepseek.com/zh-cn/news/news260424).
- **Best-fit roles:** Implementer-complex, controller/orchestrator, spec reviewer
- **Cost-benefit positioning:** Extremely cheap for top-tier agentic coding; best dollar-for-dollar for complex implementation.

### `deepseek/deepseek-v4-flash` — DeepSeek V4 Flash

- **Provider:** DeepSeek
- **Capabilities:** text->text; 1,048,576 ctx; max out 384,000; reasoning optional; efforts: xhigh,high; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.077** | cache-read **$0.0154** | cache-write **—** | output **$0.154**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/deepseek/deepseek-v4-flash
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 40.3, coding 56.2, agentic 31.1
- **Design Arena top coding category:** gamedev ELO 1259 (rank 29, 50.7% win rate)
- **Other benchmarks:** DeepSeek positions Flash close to Pro on reasoning but weaker on hard agent tasks; no separate score table published — [source](https://api-docs.deepseek.com/zh-cn/news/news260424).
- **Best-fit roles:** Implementer-mechanical, high-volume pre-filter, light controller
- **Cost-benefit positioning:** Among cheapest non-free models; good for mechanical tasks and simple agents.

## Kimi K2 family

### `moonshotai/kimi-k2.5` — Kimi K2.5

- **Provider:** MoonshotAI
- **Capabilities:** text+image->text; 262,144 ctx; reasoning default; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.375** | cache-read **$0.203** | cache-write **—** | output **$2.025**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/moonshotai/kimi-k2.5
- **Design Arena top coding category:** uicomponent ELO 1285 (rank 21, 54.2% win rate)
- **Other benchmarks:** Kimi K2.5 benchmark table (thinking): SWE-Bench Verified 76.8%, SWE-Bench Pro 50.7%, SWE-Bench Multilingual 73.0%, Terminal-Bench 2.0 50.8, LiveCodeBench v6 85.0 — [source](https://www.kimi.com/blog/kimi-k2-5).
- **Best-fit roles:** Implementer-complex, visual/debug specialist, code-quality reviewer
- **Cost-benefit positioning:** Mid-price coding+vision option; strong for front-end and visual debugging.

### `moonshotai/kimi-k2.6` — Kimi K2.6

- **Provider:** MoonshotAI
- **Capabilities:** text+image->text; 262,144 ctx; max out 262,144; reasoning default; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.66** | cache-read **$0.15** | cache-write **—** | output **$3.41**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/moonshotai/kimi-k2.6
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 44.2, coding 61.8, agentic 30.3
- **Design Arena top coding category:** codecategories ELO 1320 (rank 7, 58% win rate)
- **Other benchmarks:** Kimi K2.6 benchmark table (thinking): SWE-Bench Verified 80.2%, SWE-Bench Pro 58.6%, SWE-Bench Multilingual 76.7%, Terminal-Bench 2.0 66.7, LiveCodeBench v6 89.6 — [source](https://www.kimi.com/blog/kimi-k2-6).
- **Best-fit roles:** Implementer-complex, planner/brainstorming, controller/orchestrator
- **Cost-benefit positioning:** Strong open-source-class coding/agent scores at moderate price; good default for long-horizon coding agents.

### `moonshotai/kimi-k2.7-code` — Kimi K2.7 Code

- **Provider:** MoonshotAI
- **Capabilities:** text+image->text; 262,144 ctx; max out 262,144; reasoning mandatory; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.72** | cache-read **$0.15** | cache-write **—** | output **$3.5**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/moonshotai/kimi-k2.7-code
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 41.9, coding 60.8, agentic 29.6
- **Design Arena top coding category:** website ELO 1307 (rank 10, 56.2% win rate)
- **Other benchmarks:** Kimi K2.7 Code page: Kimi Code Bench v2 62.0 (+21.8% vs K2.6), Program Bench 53.6, MLS Bench Lite 35.1; ~30% fewer thinking tokens than K2.6 — [source](https://www.kimi.com/resources/kimi-k2-7-code).
- **Best-fit roles:** Implementer-complex, debug specialist, controller for coding tasks
- **Cost-benefit positioning:** Purpose-built coding model; moderate premium over K2.6 but higher efficiency.

## GLM-5 family

### `z-ai/glm-5` — GLM 5

- **Provider:** Z.ai
- **Capabilities:** text->text; 202,752 ctx; reasoning default; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.6** | cache-read **$0.12** | cache-write **—** | output **$1.92**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/z-ai/glm-5
- **Design Arena top coding category:** gamedev ELO 1295 (rank 17, 57.4% win rate)
- **Other benchmarks:** GLM-5 targets complex systems engineering / long-horizon agentic tasks; no separately published SWE/Terminal score on repo — [source](https://github.com/zai-org/GLM-5).
- **Best-fit roles:** Planner/brainstorming, long-horizon architect
- **Cost-benefit positioning:** Cheapest GLM entry with 202K context; use for long-context planning/system design, but upgrade to GLM-5.2 for 1M context and stronger coding.

### `z-ai/glm-5.1` — GLM 5.1

- **Provider:** Z.ai
- **Capabilities:** text->text; 202,752 ctx; max out 128,000; reasoning default; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.966** | cache-read **$0.1794** | cache-write **—** | output **$3.036**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/z-ai/glm-5.1
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 40.2, coding 55.8, agentic 29.9
- **Design Arena top coding category:** dataviz ELO 1366 (rank 2, 67% win rate)
- **Other benchmarks:** GLM-5.1 README: Terminal-Bench 2.1 62.0, SWE-bench Pro 58.4 — [source](https://github.com/zai-org/GLM-5).
- **Best-fit roles:** Implementer-complex, spec reviewer
- **Cost-benefit positioning:** Step-up coding model; cheaper than frontier closed models.

### `z-ai/glm-5.2` — GLM 5.2

- **Provider:** Z.ai
- **Capabilities:** text->text; 1,048,576 ctx; max out 131,072; reasoning default; efforts: xhigh,high; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.42** | cache-read **$0.078** | cache-write **—** | output **$1.32**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/z-ai/glm-5.2
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 51.1, coding 68.8, agentic 43.1
- **Design Arena top coding category:** gamedev ELO 1353 (rank 2, 61.3% win rate)
- **Other benchmarks:** GLM-5.2 README: Terminal-Bench 2.1 81.0, SWE-bench Pro 62.1 — [source](https://github.com/zai-org/GLM-5).
- **Best-fit roles:** Controller/orchestrator, implementer-complex, high-stakes review value
- **Cost-benefit positioning:** Best GLM coding score and still far cheaper than Claude Fable/GPT Sol; excellent price/performance.

## Qwen3.5 family

### `qwen/qwen3.5-397b-a17b` — Qwen3.5 397B A17B

- **Provider:** Qwen
- **Capabilities:** text+image+video->text; 256,000 ctx; reasoning optional; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.385** | cache-read **$0.111** | cache-write **—** | output **$2.45**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/qwen/qwen3.5-397b-a17b
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 33.7, coding 48.2, agentic 19.8
- **Design Arena top coding category:** website ELO 1225 (rank 41, 52.6% win rate)
- **Other benchmarks:** Qwen README chart: SWE-bench Verified ~80.9, Terminal-Bench 2 ~59.3, GPQA Diamond 92.4 — [source](https://github.com/QwenLM/Qwen3.6).
- **Best-fit roles:** Implementer-complex, controller/orchestrator
- **Cost-benefit positioning:** Strong open MoE with high SWE score; low per-token API cost.

### `qwen/qwen3.5-122b-a10b` — Qwen3.5-122B-A10B

- **Provider:** Qwen
- **Capabilities:** text+image+video->text; 262,144 ctx; max out 262,144; reasoning optional; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.26** | cache-read **—** | cache-write **—** | output **$2.08**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/qwen/qwen3.5-122b-a10b
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 32.3, coding 45.7, agentic 20.7
- **Other benchmarks:** No separate official score table found; part of Qwen3.5 middle-size family.
- **Best-fit roles:** Implementer-complex, generalist
- **Cost-benefit positioning:** Competent generalist; verify price/performance empirically.

### `qwen/qwen3.5-35b-a3b` — Qwen3.5-35B-A3B

- **Provider:** Qwen
- **Capabilities:** text+image+video->text; 262,144 ctx; max out 81,920; reasoning optional; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.14** | cache-read **$0.05** | cache-write **—** | output **$1**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/qwen/qwen3.5-35b-a3b
- **Other benchmarks:** No separate official score table found; part of Qwen3.5 middle-size family.
- **Best-fit roles:** Implementer-complex
- **Cost-benefit positioning:** Competent generalist; verify price/performance empirically.

### `qwen/qwen3.5-27b` — Qwen3.5-27B

- **Provider:** Qwen
- **Capabilities:** text+image+video->text; 262,144 ctx; max out 65,536; reasoning optional; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.195** | cache-read **—** | cache-write **—** | output **$1.56**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/qwen/qwen3.5-27b
- **Other benchmarks:** No separate official score table found; part of Qwen3.5 middle-size family.
- **Best-fit roles:** Implementer-mechanical/complex
- **Cost-benefit positioning:** Competent generalist; verify price/performance empirically.

### `qwen/qwen3.5-9b` — Qwen3.5-9B

- **Provider:** Qwen
- **Capabilities:** text+image+video->text; 262,144 ctx; max out 262,144; reasoning optional; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.1** | cache-read **—** | cache-write **—** | output **$0.15**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/qwen/qwen3.5-9b
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 21.4, coding 28.7, agentic 7.4
- **Other benchmarks:** No separate official score table found.
- **Best-fit roles:** Implementer-mechanical
- **Cost-benefit positioning:** Competent generalist; verify price/performance empirically.

### `qwen/qwen3.5-flash-02-23` — Qwen3.5-Flash

- **Provider:** Qwen
- **Capabilities:** text+image+video->text; 1,000,000 ctx; max out 65,536; reasoning optional; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.065** | cache-read **—** | cache-write **—** | output **$0.26**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/qwen/qwen3.5-flash-02-23
- **Other benchmarks:** No separate official score table found.
- **Best-fit roles:** Implementer-mechanical, high-volume
- **Cost-benefit positioning:** Competent generalist; verify price/performance empirically.

## Qwen3.6/3.7 family

### `qwen/qwen3.6-27b` — Qwen3.6 27B

- **Provider:** Qwen
- **Capabilities:** text+image+video->text; 262,144 ctx; max out 262,140; reasoning default; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.285** | cache-read **$0.15** | cache-write **—** | output **$2.4**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/qwen/qwen3.6-27b
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 37.1, coding 53.7, agentic 27.0
- **Other benchmarks:** Qwen README chart: SWE-bench Pro ~57.1, Terminal-Bench 2.0 59.3, GPQA Diamond 86.0 — [source](https://github.com/QwenLM/Qwen3.6).
- **Best-fit roles:** Implementer-mechanical/complex, debug specialist
- **Cost-benefit positioning:** Very cheap dense model; good for mechanical tasks and small agents.

### `qwen/qwen3.6-35b-a3b` — Qwen3.6 35B A3B

- **Provider:** Qwen
- **Capabilities:** text+image+video->text; 262,144 ctx; max out 262,144; reasoning default; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.14** | cache-read **—** | cache-write **—** | output **$1**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/qwen/qwen3.6-35b-a3b
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 31.6, coding 41.9, agentic 21.4
- **Other benchmarks:** Qwen README chart: SWE-bench Verified 73.4, SWE-bench Pro 49.5, Terminal-Bench 2.0 51.5, GPQA Diamond 86.0 — [source](https://github.com/QwenLM/Qwen3.6).
- **Best-fit roles:** Implementer-complex, controller/orchestrator
- **Cost-benefit positioning:** Best open Qwen coding option by official chart; low price.

### `qwen/qwen3.6-plus` — Qwen3.6 Plus

- **Provider:** Qwen
- **Capabilities:** text+image+video->text; 1,000,000 ctx; max out 65,536; reasoning optional; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.325** | cache-read **—** | cache-write **$0.4062** | output **$1.95**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/qwen/qwen3.6-plus
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 39.6, coding 54.5, agentic 27.6
- **Design Arena top coding category:** uicomponent ELO 1277 (rank 23, 51.9% win rate)
- **Other benchmarks:** No separate official score table published as of 2026-07-12.
- **Best-fit roles:** Implementer-complex, generalist
- **Cost-benefit positioning:** Competent generalist; verify price/performance empirically.

### `qwen/qwen3.6-flash` — Qwen3.6 Flash

- **Provider:** Qwen
- **Capabilities:** text+image+video->text; 1,000,000 ctx; max out 65,536; reasoning optional; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.1875** | cache-read **—** | cache-write **$0.2344** | output **$1.125**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/qwen/qwen3.6-flash
- **Other benchmarks:** No separate official score table published as of 2026-07-12.
- **Best-fit roles:** Implementer-mechanical, high-volume
- **Cost-benefit positioning:** Competent generalist; verify price/performance empirically.

### `qwen/qwen3.6-max-preview` — Qwen3.6 Max Preview

- **Provider:** Qwen
- **Capabilities:** text->text; 262,144 ctx; max out 65,536; reasoning default; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$1.04** | cache-read **—** | cache-write **$1.3** | output **$6.24**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/qwen/qwen3.6-max-preview
- **Other benchmarks:** No separate official score table published as of 2026-07-12.
- **Best-fit roles:** Implementer-complex, controller
- **Cost-benefit positioning:** Competent generalist; verify price/performance empirically.

### `qwen/qwen3.7-plus` — Qwen3.7 Plus

- **Provider:** Qwen
- **Capabilities:** text+image->text; 1,000,000 ctx; max out 65,536; reasoning default; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.32** | cache-read **$0.064** | cache-write **$0.4** | output **$1.28**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/qwen/qwen3.7-plus
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 39.0, coding 55.9, agentic 20.8
- **Design Arena top coding category:** website ELO 1292 (rank 16, 52.3% win rate)
- **Other benchmarks:** No separate official score table published as of 2026-07-12.
- **Best-fit roles:** Implementer-complex, generalist
- **Cost-benefit positioning:** Latest Qwen iteration; competitive indexes, limited public benchmark details.

### `qwen/qwen3.7-max` — Qwen3.7 Max

- **Provider:** Qwen
- **Capabilities:** text->text; 1,000,000 ctx; max out 65,536; reasoning default; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$1.25** | cache-read **$0.25** | cache-write **$1.5625** | output **$3.75**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/qwen/qwen3.7-max
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 46.0, coding 66.0, agentic 30.6
- **Design Arena top coding category:** uicomponent ELO 1331 (rank 6, 60.4% win rate)
- **Other benchmarks:** No separate official score table published as of 2026-07-12.
- **Best-fit roles:** Implementer-complex, controller
- **Cost-benefit positioning:** Competent generalist; verify price/performance empirically.

## Anthropic Claude 5 family

### `anthropic/claude-sonnet-5` — Claude Sonnet 5

- **Provider:** Anthropic
- **Capabilities:** text+image+file->text; 1,000,000 ctx; max out 128,000; reasoning optional; efforts: max,xhigh,high,medium,low; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$2** | cache-read **$0.2** | cache-write **$2.5** | output **$10**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/anthropic/claude-sonnet-5
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 53.4, coding 71.5, agentic 46.7
- **Design Arena top coding category:** webapps ELO 1345 (rank 1, 62.7% win rate)
- **Other benchmarks:** Anthropic Sonnet 5 table: SWE-bench Pro 80.4%, Terminal-Bench 2.1 43.2%, OSWorld-Verified 81.2%, HLE (no tools) 57.4% — [source](https://www.anthropic.com/news/claude-sonnet-5).
- **Best-fit roles:** Controller/orchestrator, implementer-complex, code-quality reviewer
- **Cost-benefit positioning:** Best Anthropic price/performance for coding agents; OpenRouter currently reflects intro pricing ($2 in / $10 out). Standard pricing rises to $3/$15 after 2026-08-31.

### `anthropic/claude-fable-5` — Claude Fable 5

- **Provider:** Anthropic
- **Capabilities:** text+image+file->text; 1,000,000 ctx; max out 128,000; reasoning mandatory; efforts: max,xhigh,high,medium,low; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$10** | cache-read **$1** | cache-write **$12.5** | output **$50**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/anthropic/claude-fable-5
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 59.9, coding 76.5, agentic 52.8
- **Design Arena top coding category:** uicomponent ELO 1409 (rank 1, 71% win rate)
- **Other benchmarks:** Anthropic Fable 5 table: SWE-Bench Pro 80.3%, Terminal-Bench 2.1 88.0%, FrontierCode (Diamond) 29.3%, GDPval-AA 1932 — [source](https://www.anthropic.com/claude/fable).
- **Best-fit roles:** High-stakes review/architecture, planner/brainstorming
- **Cost-benefit positioning:** Premium capability for high-stakes review and architecture; not for high-volume generation.

## OpenAI GPT-5.6 family

### `openai/gpt-5.6-sol` — GPT-5.6 Sol

- **Provider:** OpenAI
- **Capabilities:** text+image+file->text; 1,050,000 ctx; max out 128,000; reasoning default; efforts: max,xhigh,high,medium,low,none; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$5** | cache-read **$0.5** | cache-write **$6.25** | output **$30**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/openai/gpt-5.6-sol
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 58.9, coding 77.4, agentic 54.0
- **Other benchmarks:** OpenAI GPT-5.6 table: SWE-Bench Pro 64.6%, Terminal-Bench 2.1 88.8%, DeepSWE v1.1 72.7%, Artificial Analysis Coding Agent Index 80, BrowseComp 90.4% — [source](https://openai.com/index/gpt-5-6/).
- **Best-fit roles:** High-stakes review/architecture, controller/orchestrator
- **Cost-benefit positioning:** Top benchmark scores but premium pricing; use when results matter more than cost.

### `openai/gpt-5.6-sol-pro` — GPT-5.6 Sol Pro

- **Provider:** OpenAI
- **Capabilities:** text+image+file->text; 1,050,000 ctx; max out 128,000; reasoning default; efforts: max,xhigh,high,medium,low,none; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$5** | cache-read **$0.5** | cache-write **$6.25** | output **$30**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/openai/gpt-5.6-sol-pro
- **Other benchmarks:** Same model as Sol with reasoning.mode=pro; official benchmarks for Sol family apply.
- **Best-fit roles:** Same as Sol; use when reasoning.mode=pro is needed
- **Cost-benefit positioning:** Same underlying model as Sol, forced Pro reasoning; pay only if your harness needs reasoning.mode=pro.

### `openai/gpt-5.6-terra` — GPT-5.6 Terra

- **Provider:** OpenAI
- **Capabilities:** text+image+file->text; 1,050,000 ctx; max out 128,000; reasoning default; efforts: max,xhigh,high,medium,low,none; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$2.5** | cache-read **$0.25** | cache-write **$3.125** | output **$15**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/openai/gpt-5.6-terra
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 55.0, coding 76.7, agentic 47.4
- **Other benchmarks:** OpenAI GPT-5.6 table: SWE-Bench Pro 63.4%, Terminal-Bench 2.1 87.4%, Artificial Analysis Coding Agent Index 77.4 — [source](https://openai.com/index/gpt-5-6/).
- **Best-fit roles:** Implementer-complex, controller/orchestrator
- **Cost-benefit positioning:** Near-Sol scores at half cost; best GPT-5.6 family value.

### `openai/gpt-5.6-terra-pro` — GPT-5.6 Terra Pro

- **Provider:** OpenAI
- **Capabilities:** text+image+file->text; 1,050,000 ctx; max out 128,000; reasoning default; efforts: max,xhigh,high,medium,low,none; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$2.5** | cache-read **$0.25** | cache-write **$3.125** | output **$15**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/openai/gpt-5.6-terra-pro
- **Other benchmarks:** Same model as Terra with reasoning.mode=pro; official benchmarks for Sol family apply.
- **Best-fit roles:** Same as Terra; use when reasoning.mode=pro is needed
- **Cost-benefit positioning:** Same underlying model as Terra with Pro reasoning mode.

### `openai/gpt-5.6-luna` — GPT-5.6 Luna

- **Provider:** OpenAI
- **Capabilities:** text+image+file->text; 1,050,000 ctx; max out 128,000; reasoning default; efforts: max,xhigh,high,medium,low,none; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$1** | cache-read **$0.1** | cache-write **$1.25** | output **$6**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/openai/gpt-5.6-luna
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 51.2, coding 71.4, agentic 45.6
- **Other benchmarks:** OpenAI GPT-5.6 table: SWE-Bench Pro 62.7%, Terminal-Bench 2.1 84.7%, Artificial Analysis Coding Agent Index 74.6 — [source](https://openai.com/index/gpt-5-6/).
- **Best-fit roles:** Implementer-mechanical, high-volume steps
- **Cost-benefit positioning:** Cheapest GPT option; reserve for mechanical tasks and high-volume inference.

### `openai/gpt-5.6-luna-pro` — GPT-5.6 Luna Pro

- **Provider:** OpenAI
- **Capabilities:** text+image+file->text; 1,050,000 ctx; max out 128,000; reasoning default; efforts: max,xhigh,high,medium,low,none; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$1** | cache-read **$0.1** | cache-write **$1.25** | output **$6**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/openai/gpt-5.6-luna-pro
- **Other benchmarks:** Same model as Luna with reasoning.mode=pro; official benchmarks for Sol family apply.
- **Best-fit roles:** Same as Luna; use when reasoning.mode=pro is needed
- **Cost-benefit positioning:** Same underlying model as Luna with Pro reasoning mode.

## xAI Grok 4 family

### `x-ai/grok-4.5` — Grok 4.5

- **Provider:** xAI
- **Capabilities:** text+image+file->text; 500,000 ctx; reasoning mandatory; efforts: high,medium,low; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$2** | cache-read **$0.5** | cache-write **—** | output **$6**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/x-ai/grok-4.5
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 53.8, coding 72.4, agentic 45.7
- **Design Arena top coding category:** codecategories ELO 1327 (rank 5, 58.1% win rate)
- **Other benchmarks:** No independent coding score table found; xAI describes Grok 4.5 as frontier on knowledge/STEM. Use OpenRouter design-arena and artificial-analysis indexes.
- **Best-fit roles:** Controller/orchestrator, generalist implementer
- **Cost-benefit positioning:** Fast frontier generalist; coding value lower than DeepSeek/GLM/Qwen open models.

### `x-ai/grok-4.3` — Grok 4.3

- **Provider:** xAI
- **Capabilities:** text+image+file->text; 1,000,000 ctx; reasoning default; efforts: high,medium,low,none; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$1.25** | cache-read **$0.2** | cache-write **—** | output **$2.5**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/x-ai/grok-4.3
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 37.6, coding 42.2, agentic 24.1
- **Design Arena top coding category:** uicomponent ELO 1243 (rank 32, 48.6% win rate)
- **Other benchmarks:** No independent coding score table found.
- **Best-fit roles:** Generalist implementer
- **Cost-benefit positioning:** Lower-cost Grok; suitable for generalist chat and light coding.

### `x-ai/grok-4.20` — Grok 4.20

- **Provider:** xAI
- **Capabilities:** text+image+file->text; 2,000,000 ctx; reasoning optional; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$1.25** | cache-read **$0.2** | cache-write **—** | output **$2.5**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/x-ai/grok-4.20
- **Design Arena top coding category:** website ELO 1263 (rank 26, 54.8% win rate)
- **Other benchmarks:** No independent coding score table found.
- **Best-fit roles:** Controller/orchestrator
- **Cost-benefit positioning:** Large-context Grok with multi-agent support.

### `x-ai/grok-4.20-multi-agent` — Grok 4.20 Multi-Agent

- **Provider:** xAI
- **Capabilities:** text+image+file->text; 2,000,000 ctx; reasoning mandatory; efforts: xhigh,high,medium,low; tools ✗
- **OpenRouter pricing per 1M tokens:** input **$1.25** | cache-read **$0.2** | cache-write **—** | output **$2.5**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/x-ai/grok-4.20-multi-agent
- **Other benchmarks:** No independent coding score table found.
- **Best-fit roles:** Controller/orchestrator
- **Cost-benefit positioning:** 2M context variant; strong context but premium input price.

## Google Gemini 3.x

### `google/gemini-3.1-pro-preview` — Gemini 3.1 Pro Preview

- **Provider:** Google
- **Capabilities:** text+image+file+audio+video->text; 1,048,576 ctx; max out 65,536; reasoning mandatory; efforts: high,medium,low; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$2** | cache-read **$0.2** | cache-write **$0.375** | output **$12**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/google/gemini-3.1-pro-preview
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 46.5, coding 68.8, agentic 21.4
- **Design Arena top coding category:** uicomponent ELO 1316 (rank 9, 68.1% win rate)
- **Other benchmarks:** No independent coding score table found beyond OpenRouter indexes.
- **Best-fit roles:** Implementer-complex, controller/orchestrator
- **Cost-benefit positioning:** Mid-price generalist with strong context; coding value decent but not top.

### `google/gemini-3.1-flash-lite` — Gemini 3.1 Flash Lite

- **Provider:** Google
- **Capabilities:** text+image+file+audio+video->text; 1,048,576 ctx; max out 65,536; reasoning default; efforts: high,medium,low,minimal; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.25** | cache-read **$0.025** | cache-write **$0.0833** | output **$1.5**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/google/gemini-3.1-flash-lite
- **Other benchmarks:** No independent coding score table found beyond OpenRouter indexes.
- **Best-fit roles:** Implementer-mechanical, high-volume
- **Cost-benefit positioning:** Fast, cheap Gemini for high-volume simple tasks.

### `google/gemini-3.1-flash-lite-preview` — Gemini 3.1 Flash Lite Preview

- **Provider:** Google
- **Capabilities:** text+image+file+audio+video->text; 1,048,576 ctx; max out 65,536; reasoning default; efforts: high,medium,low,minimal; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.25** | cache-read **$0.025** | cache-write **$0.0833** | output **$1.5**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/google/gemini-3.1-flash-lite-preview
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 25.0, coding 34.7, agentic 6.2
- **Design Arena top coding category:** uicomponent ELO 1120 (rank 70, 37.7% win rate)
- **Other benchmarks:** Preview variant; no independent coding score table found beyond OpenRouter indexes.
- **Best-fit roles:** Implementer-mechanical, high-volume
- **Cost-benefit positioning:** Competent generalist; verify price/performance empirically.

### `google/gemini-3.5-flash` — Gemini 3.5 Flash

- **Provider:** Google
- **Capabilities:** text+image+file+audio+video->text; 1,048,576 ctx; max out 65,536; reasoning mandatory; efforts: high,medium,low,minimal; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$1.5** | cache-read **$0.15** | cache-write **$0.0833** | output **$9**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/google/gemini-3.5-flash
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 50.2, coding 70.1, agentic 37.4
- **Design Arena top coding category:** gamedev ELO 1323 (rank 9, 58.8% win rate)
- **Other benchmarks:** No independent coding score table found beyond OpenRouter indexes.
- **Best-fit roles:** Implementer-complex, vision+code generalist
- **Cost-benefit positioning:** Low-cost long-context multimodal model; good generalist agent.

## NVIDIA Nemotron 3

### `nvidia/nemotron-3-ultra-550b-a55b` — Nemotron 3 Ultra

- **Provider:** NVIDIA
- **Capabilities:** text->text; 1,000,000 ctx; max out 16,384; reasoning default; efforts: high,medium; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.5** | cache-read **$0.1** | cache-write **—** | output **$2.2**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/nvidia/nemotron-3-ultra-550b-a55b
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 37.8, coding 49.3, agentic 27.4
- **Design Arena top coding category:** gamedev ELO 1190 (rank 57, 39.2% win rate)
- **Other benchmarks:** NVIDIA positions Nemotron 3 Ultra as frontier-reasoning/orchestration model; no independent coding score table found.
- **Best-fit roles:** Orchestrator/controller
- **Cost-benefit positioning:** Very cheap large MoE; suitable for orchestration experiments.

### `nvidia/nemotron-3-super-120b-a12b` — Nemotron 3 Super

- **Provider:** NVIDIA
- **Capabilities:** text->text; 1,000,000 ctx; reasoning default; efforts: medium,low; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.08** | cache-read **—** | cache-write **—** | output **$0.45**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/nvidia/nemotron-3-super-120b-a12b
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 25.4, coding 37.7, agentic 8.7
- **Other benchmarks:** No independent coding score table found.
- **Best-fit roles:** Implementer-mechanical, orchestrator
- **Cost-benefit positioning:** Cheapest large-context model on list; good for mechanical summarization/routing.

### `nvidia/nemotron-3-nano-30b-a3b` — Nemotron 3 Nano 30B A3B

- **Provider:** NVIDIA
- **Capabilities:** text->text; 262,144 ctx; max out 228,000; reasoning optional; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.05** | cache-read **—** | cache-write **—** | output **$0.2**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/nvidia/nemotron-3-nano-30b-a3b
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence 14.2, coding 14.4, agentic 2.0
- **Other benchmarks:** No independent coding score table found.
- **Best-fit roles:** Implementer-mechanical
- **Cost-benefit positioning:** Ultra-cheap small model for routing and mechanical extraction.

## Specialist / smaller coding models

### `poolside/laguna-m.1` — Laguna M.1

- **Provider:** Poolside
- **Capabilities:** text->text; 262,144 ctx; max out 32,768; reasoning default; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.2** | cache-read **$0.1** | cache-write **—** | output **$0.4**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/poolside/laguna-m.1
- **Other benchmarks:** Poolside positions Laguna as coding-agent MoE family; no public benchmark score table found.
- **Best-fit roles:** Implementer-complex (coding-agent specialized)
- **Cost-benefit positioning:** Coding-agent specialized; very cheap but limited public benchmarks.

### `poolside/laguna-xs-2.1` — Laguna XS 2.1

- **Provider:** Poolside
- **Capabilities:** text->text; 262,144 ctx; max out 32,768; reasoning default; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.06** | cache-read **$0.03** | cache-write **—** | output **$0.12**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/poolside/laguna-xs-2.1
- **Other benchmarks:** Poolside positions Laguna as coding-agent MoE family; no public benchmark score table found.
- **Best-fit roles:** Implementer-mechanical/coding
- **Cost-benefit positioning:** Cheapest non-free coding model on list; use for mechanical coding tasks.

### `tencent/hy3` — Hy3

- **Provider:** Tencent
- **Capabilities:** text->text; 262,144 ctx; reasoning optional; efforts: high,low,none; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.14** | cache-read **$0.035** | cache-write **—** | output **$0.58**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/tencent/hy3
- **Design Arena top coding category:** gamedev ELO 1205 (rank 45, 40.4% win rate)
- **Other benchmarks:** Tencent Hy3 is a 295B-parameter MoE for agentic workflows; no public coding score table found.
- **Best-fit roles:** Generalist agent/orchestrator
- **Cost-benefit positioning:** Ultra-cheap MoE for agentic workflows; benchmark claims not publicly detailed.

### `nex-agi/nex-n2-pro` — Nex-N2-Pro

- **Provider:** Nex AGI
- **Capabilities:** text+image->text; 262,144 ctx; max out 262,144; reasoning optional; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.25** | cache-read **$0.025** | cache-write **—** | output **$1**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/nex-agi/nex-n2-pro
- **Design Arena top coding category:** gamedev ELO 1266 (rank 26, 48.8% win rate)
- **Other benchmarks:** Nex-N2-Pro is a 397B MoE agentic model on Qwen3.5 architecture; no separate official score table found.
- **Best-fit roles:** Generalist agent/orchestrator
- **Cost-benefit positioning:** Competitively priced 397B MoE; benchmark table not published.

### `nex-agi/nex-n2-mini` — Nex-N2-Mini

- **Provider:** Nex AGI
- **Capabilities:** text+image->text; 262,144 ctx; max out 262,144; reasoning optional; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0.025** | cache-read **$0.0025** | cache-write **—** | output **$0.1**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/nex-agi/nex-n2-mini
- **Other benchmarks:** Smaller Nex-N2 variant; no independent score table found.
- **Best-fit roles:** Light mechanical coding/agent
- **Cost-benefit positioning:** Competent generalist; verify price/performance empirically.

### `cohere/north-mini-code:free` — North Mini Code (free)

- **Provider:** Cohere
- **Capabilities:** text->text; 256,000 ctx; max out 64,000; reasoning optional; tools ✓
- **OpenRouter pricing per 1M tokens:** input **$0** | cache-read **—** | cache-write **—** | output **$0**
- **OpenRouter page / source of price & capability data:** https://openrouter.ai/cohere/north-mini-code:free
- **OpenRouter Artificial Analysis indexes (coding / agentic proxy):** intelligence —, coding 36.5, agentic —
- **Other benchmarks:** Cohere describes North Mini Code as first agentic coding model; OpenRouter lists coding_index 36.5.
- **Best-fit roles:** Implementer-mechanical coding
- **Cost-benefit positioning:** Zero API cost; best for experimentation, heavy pre-filtering, low-stakes mechanical tasks. Rate limits/reliability unknown.

## Cross-family observations

- **Cheapest non-free strong coding models:** DeepSeek-V4-Flash, Qwen3.6-27B, Poolside Laguna XS 2.1, Tencent Hy3, and NVIDIA Nemotron 3 Super/Nano all sit below $0.70/M output. DeepSeek-V4-Flash and Qwen3.6-27B carry the strongest published coding/agent scores in this bucket.
- **Best price/performance for complex coding:** DeepSeek-V4-Pro, GLM-5.2, Qwen3.5-397B-A17B and Kimi K2.6 cluster around $0.45–$3.50/M output while posting SWE/TB scores competitive with models that cost 5–20× more.
- **Frontier closed options:** Claude Fable 5, GPT-5.6 Sol, Claude Sonnet 5 (intro), and Kimi K2.7 Code win on absolute benchmark numbers, but output prices range from ~$3.50 (K2.7) up to $50 (Fable). They make sense for high-stakes review, architecture, or long-horizon tasks where failure cost exceeds token cost.
- **Mechanical-task default:** Poolside Laguna XS 2.1 ($0.12/M out), Tencent Hy3 ($0.58/M out), NVIDIA Nemotron 3 Super ($0.45/M out) and the free Cohere North Mini Code are the cheapest competent options for linting, summarisation, formatting and boilerplate.

## Recommendations

### Top 3 overall cost-benefit picks

1. **DeepSeek-V4-Pro** — ~$0.435/M input, ~$0.87/M output, SWE-bench Verified ~80.6%, SWE-Bench Pro ~67.9%, Terminal-Bench 2.0 ~62.0, 1M context, strong tool use. Best dollar-for-dollar general-purpose complex coding agent.
   - Caveat: reasoning defaults to on; use `max`/`high` effort only when needed because tool-agent loops can rack up output tokens quickly.
2. **GLM-5.2** — ~$0.42/M input, ~$1.32/M output, Terminal-Bench 2.1 81.0, SWE-Bench Pro 62.1, 1M context, open weights. Top open-source-class coding option on OpenRouter for cost-sensitive teams that still need repository-scale reasoning.
   - Caveat: reasoning defaults to `max`; explicitly set `high` to trade quality for speed/cost.
3. **Claude Sonnet 5** — at OpenRouter intro pricing ($2 in / $10 out through 2026-08-31) it offers near-Opus coding scores (SWE-Bench Pro 80.4%, OSWorld-Verified 81.2%) with strong tool use, 1M context and Anthropic's safety stack. Best value among frontier closed models while the promotion lasts.
   - Caveat: standard pricing rises to $3/$15 after the intro window, putting it closer to GPT-5.6 Terra territory.

### Cheapest competent model for mechanical coding tasks

- **Poolside Laguna XS 2.1** at **$0.12/M output / $0.06/M input** is the cheapest non-free OpenRouter option explicitly positioned as a coding-agent model. For purely mechanical work, also consider the **free Cohere North Mini Code** endpoint or **NVIDIA Nemotron 3 Nano** ($0.20/M out), but treat these as experimental/routing layers rather than correctness-critical workers.

### Strongest models worth the price for high-stakes review / architecture

- **Claude Fable 5** — $10/$50 per 1M tokens, but state-of-the-art on Anthropic's coding/agent table (SWE-Bench Pro 80.3%, Terminal-Bench 2.1 88.0%) and built for days-long asynchronous work. Use it for final architecture review, complex migrations, or multi-day autonomous sessions where a mistake is expensive. [Source](https://www.anthropic.com/claude/fable)
   - Caveat: large safety margin means some benign coding/security queries may be redirected to Opus 4.8 (you are not charged Fable prices for rerouted requests). 30-day data retention applies.
- **GPT-5.6 Sol** — $5/$30 per 1M tokens, top marks on Terminal-Bench 2.1 (88.8%) and DeepSWE (72.7%), with multi-agent `ultra` mode for the hardest parallel tasks. Best when you need the strongest OpenAI ecosystem integration and are willing to pay for frontier consistency. [Source](https://openai.com/index/gpt-5-6/)
   - Caveat: output is 3–5× more expensive than DeepSeek/GLM/Qwen open-class models; reserve for highest-leverage steps.

## Benchmark data availability note

- **SWE-bench / Aider / LiveCodeBench / BigCodeBench:** the canonical leaderboards were checked on 2026-07-12. They do not yet contain the exact 2026 model variants above (e.g., DeepSeek-V4, GLM-5.2, Kimi K2.7, Qwen3.7). Scores cited here are therefore from official provider pages / tables, or from OpenRouter's internal `artificial_analysis` and `design_arena` proxies. If a row above lists no SWE-bench/Aider/LiveCodeBench/BigCodeBench number, it means no public canonical score was found.
- Older models that *do* appear on the canonical leaderboards (e.g., DeepSeek-V3, Kimi K2, Claude-3.5/4 family, GPT-4.1/o3) can be used as rough proxies, but they understate the capability of the newer models discussed here.

## References

- OpenRouter models API (pricing and metadata), retrieved 2026-07-12: https://openrouter.ai/api/v1/models
- OpenRouter model pages: `https://openrouter.ai/<model_id>` (e.g., https://openrouter.ai/deepseek/deepseek-v4-pro)
- DeepSeek pricing and V4 announcement: https://api-docs.deepseek.com/zh-cn/quick_start/pricing , https://api-docs.deepseek.com/zh-cn/news/news260424
- Kimi K2.5 blog / benchmark table: https://www.kimi.com/blog/kimi-k2-5
- Kimi K2.6 blog / benchmark table: https://www.kimi.com/blog/kimi-k2-6
- Kimi K2.7 Code page: https://www.kimi.com/resources/kimi-k2-7-code
- GLM-5 GitHub README / benchmark charts: https://github.com/zai-org/GLM-5
- Qwen3.5/3.6 GitHub README / benchmark charts: https://github.com/QwenLM/Qwen3.6
- Anthropic Claude Sonnet 5: https://www.anthropic.com/news/claude-sonnet-5
- Anthropic Claude Fable 5: https://www.anthropic.com/claude/fable
- OpenAI GPT-5.6 announcement / benchmarks: https://openai.com/index/gpt-5-6/
- SWE-bench leaderboard: https://www.swebench.com/
- Aider polyglot leaderboard: https://aider.chat/docs/leaderboards/
- LiveCodeBench leaderboard data: https://livecodebench.github.io/performances_generation.json
- BigCodeBench results datasets: https://huggingface.co/datasets/bigcode/bigcodebench-results / https://huggingface.co/datasets/bigcode/bigcodebench-hard-results
