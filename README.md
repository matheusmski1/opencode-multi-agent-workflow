# opencode-multi-agent-workflow

Skill multi-agente para [OpenCode](https://opencode.ai) que roteia trabalho pra subagents especializados, cada um no modelo mais barato que dá conta do recado. Pipeline completo: planejamento, implementação, revisão e entrega.

## Diagrama do fluxo

![Diagrama do workflow](docs/workflow.png)

> Arquivo editável: [docs/workflow.drawio](docs/workflow.drawio) (abra em [app.diagrams.net](https://app.diagrams.net))

## O que você ganha

- **Workflow router (auto-carregado)** — escolhe a skill certa pra cada situação (wayfinder, brainstorming, grill-with-docs, implement, diagnosing-bugs, triage, prototype). Carrega sozinho quando você pede pra desenvolver feature ou corrigir bug.
- **Model routing por CxB** — tudo no pool open-source do **opencode Go** (Zen), roteado por custo-benefício por papel (não "o mais barato", não "sempre o mais forte"): controller/implementer no GLM-5.2, mecânico no DeepSeek V4 Flash, debug no DeepSeek V4 Pro (melhor raciocínio duro por dólar), e os gates em família diferente do implementer (Qwen 3.7 Plus / Kimi K2.7 Code) pra 2ª opinião real. Análise completa em [`docs/model-selection.md`](docs/model-selection.md).
- **5 subagents especializados** — implementer-complex, implementer-mechanical, spec-reviewer, code-quality-reviewer, debug-specialist.
- **Loop de revisão estruturado** — implementer → spec gate → code-quality gate, com re-review quando encontra problema (prosa, disparado pelo controller).
- **Enforcement honesto (sem plugin)** — o objetivo (tipos/lint/formato de commit) trava de verdade via permission deny nativo + husky no commit do controller; o review de LLM fica prosa porque não dá pra hard-gatear julgamento sem virar teatro. Racional em [`docs/enforcement.md`](docs/enforcement.md); scaffold do husky num repo alvo via `scripts/setup-husky.sh`.

## Como funciona automaticamente

Depois de rodar `setup.sh` e reiniciar o OpenCode, três camadas trabalham juntos sem intervenção manual:

| Camada | O que faz | Como carrega |
|---|---|---|
| **Skill** (`SKILL.md`) | Diz pro controller o workflow: qual skill usar quando, tabela de model routing, ordem dos subagents, padrões de código, verify-don't-assume | OpenCode escaneia `~/.config/opencode-go/skills/` no startup e auto-carrega quando a description matcha com seu pedido (model-invoked) |
| **Subagents** (`agents/*.md`) | 5 agentes especializados com seus próprios modelos e permissões, em `~/.config/opencode-go/agents/` | OpenCode carrega tudo no startup; invoca via `@agent-name` ou o controller dispatcha automaticamente seguindo a skill |
| **Config** (`opencode.json`) | Seta o `build` (controller) pra `opencode-go/glm-5.2`, habilita permissão `task` pra poder dispatchar subagents, seta `small_model` pra `opencode-go/deepseek-v4-flash` | Carregado uma vez no startup |

**Fluxo:** você pede pro OpenCode implementar feature → a skill auto-carrega → o controller (GLM-5.2) lê o router → escolhe a abordagem (brainstorming, implement, etc.) → dispatcha os subagents na ordem certa (implementer → spec-reviewer → code-quality-reviewer) → cada subagent roda no seu modelo → resultado volta pra você.

**Não precisa invocar `@agent-name` manualmente** — o controller faz sozinho seguindo as instruções da skill. Mas você pode invocar manualmente se quiser.

## Pré-requisitos

1. **[OpenCode](https://opencode.ai)** instalado
2. **OpenCode Zen** conectado — roda `/connect` no OpenCode e escolhe OpenCode Zen. O plano **[opencode Go](https://opencode.ai/br/go)** dá acesso flat ao pool de modelos open-source usado aqui. Confirma os IDs com `/models`.
3. **Coleção de skills do Matt Pocock** — o router referencia skills de [mattpocock/skills](https://github.com/mattpocock/skills) (wayfinder, to-spec, to-tickets, implement, tdd, code-review, diagnosing-bugs, triage, prototype, grill-with-docs, ask-matt, handoff). Instala antes, ou adapta o router no `SKILL.md` pras suas skills. `brainstorming` é a única linha vinda do [obra/superpowers](https://github.com/obra/superpowers) e é opcional. O setup script checa isso e avisa se faltar.

## Instalação

```bash
git clone https://github.com/matheusmski1/opencode-multi-agent-workflow.git
cd opencode-multi-agent-workflow
chmod +x scripts/setup.sh
./scripts/setup.sh
```

Depois **reinicia o OpenCode** pra carregar tudo.

O setup script:
1. Checa pré-requisitos (python3, OpenCode, skills do Matt Pocock)
2. Copia `SKILL.md` pra `~/.config/opencode-go/skills/multi-agent-workflow/SKILL.md`
3. Copia 5 templates de subagents pra `~/.config/opencode-go/agents/`
4. Injeta model routing e config do agente `build` no `~/.config/opencode-go/opencode.json`

## Uso

Depois do setup, basta usar o OpenCode normalmente. A skill auto-carrega quando você pede pra desenvolver feature, corrigir bug ou rodar workflow estruturado. O controller roteia o trabalho pros subagents certos automaticamente.

Você também pode invocar subagents manualmente:

```
@implementer-complex implementa a feature de autenticação de usuário
@spec-reviewer revisa as mudanças contra a spec
@code-quality-reviewer revisa o código em arquitetura e segurança
```

### Workflow completo por ticket

```
1. @implementer-complex   → implementa a task
2. @spec-reviewer         → confere spec compliance
3. @code-quality-reviewer → revisa qualidade do código
```

Só avança quando cada agente aprova. Se o reviewer encontrar problema, o implementer corrige e o reviewer re-revisa.

## Customização

### Modelos

Edita `SKILL.md` e os templates em `agents/` pra trocar os modelos. A análise de custo-benefício que motivou os defaults tá em `research/llm-coding-agents-cost-benefit.md`. Reconfirma o pool disponível com `/models` no OpenCode antes de fixar roteamento de longo prazo.

### Skills

O router em `SKILL.md` referencia skills da coleção superpowers. Se você usa outro conjunto de skills, edita a tabela do router pra bater com suas skills.

### Prompts dos agentes

Cada agente em `agents/` é um arquivo markdown com frontmatter (`model`, `mode`, `permission`, `temperature`) e um system prompt. Edita pra bater com seus padrões de código e workflow.

## Modelos por papel

Tudo no pool open-source do plano **opencode Go** (flat-rate), roteado por **custo-benefício por papel** — gasta capacidade onde decide o resultado (gates, debug), economiza no volume. Racional completo + custo por papel em [`docs/model-selection.md`](docs/model-selection.md).

| Papel | Modelo (opencode Zen) | Nota (CxB) |
|---|---|---|
| Controller / planner | `opencode-go/glm-5.2` | melhor capacidade/dólar all-round, 1M ctx |
| Implementer complexo | `opencode-go/glm-5.2` | papel que mais gasta token → CxB importa mais aqui |
| Implementer mecânico | `opencode-go/deepseek-v4-flash` | mais barato capaz; variante `-free` p/ throwaway |
| Debug specialist | `opencode-go/deepseek-v4-pro` | melhor raciocínio duro do pool **e** barato — CxB destaque |
| Spec gate | `opencode-go/qwen3.7-plus` | leitura cuidadosa é barata; família diferente |
| Code-quality gate | `opencode-go/kimi-k2.7-code` | gate de maior aposta, baixo volume → coding-specialist; escala p/ `grok-4.5` / `claude-sonnet-5` em PR crítico |

## Estrutura

```
opencode-multi-agent-workflow/
├── SKILL.md                                # router + model routing + subagents + princípios
├── agents/                                  # templates dos subagents
│   ├── implementer-complex.md              # opencode-go/glm-5.2
│   ├── implementer-mechanical.md           # opencode-go/deepseek-v4-flash
│   ├── spec-reviewer.md                    # opencode-go/qwen3.7-plus (gate)
│   ├── code-quality-reviewer.md            # opencode-go/kimi-k2.7-code (gate)
│   └── debug-specialist.md                 # opencode-go/deepseek-v4-pro
├── docs/
│   ├── model-selection.md                  # análise de custo-benefício por papel
│   ├── enforcement.md                      # ADR: por que permission deny + husky em vez de plugin
│   ├── workflow.drawio                     # diagrama editável
│   └── workflow.png                        # diagrama renderizado
├── scripts/
│   ├── setup.sh                            # instalador (skill + agents + config)
│   └── setup-husky.sh                      # scaffold do gate objetivo (husky + commitlint + lint-staged) num repo alvo
├── research/
│   └── llm-coding-agents-cost-benefit.md   # análise custo-benefício dos modelos
└── README.md
```

## Licença

MIT