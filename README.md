<div align="center">
  <h1>AgentTeacher</h1>
  <p><b>Good concepts deserve good code.</b></p>
  <p><a href="README.md"><b>English</b></a> · <a href="README.zh-CN.md">中文</a></p>
  <a href="https://github.com/JackyYang258/AgentTeacher/stargazers"><img src="https://img.shields.io/github/stars/JackyYang258/AgentTeacher?style=flat-square" alt="Stars"></a>
  <a href="https://github.com/JackyYang258/AgentTeacher/releases"><img src="https://img.shields.io/github/v/tag/JackyYang258/AgentTeacher?label=version&style=flat-square" alt="Version"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square" alt="License"></a>
</div>

## Why

I read AI papers all the time, and the gap between "skimmed it" and "got it" is largest when the concept is dense — group-relative advantage in GRPO, expert routing in MoE, attention tiling in FlashAttention. The default LLM explanation hits one of two failure modes: prose with no code to anchor it, or code buried under 60 lines of model and dataloader setup before the actual algorithm appears.

AgentTeacher gives it a shape: every concept gets the same six-part spine — intuition, example, walkthrough, trap, pointers, test questions — and the example is either a 10-line runnable REPL snippet or PyTorch pseudocode with shape annotations on every line that matters. Once the structure is locked in, the quality of explanations levels up the moment the model stops improvising.

Built primarily for AI/ML concepts: training algorithms (GRPO, PPO, DPO, RLHF), architectures (MoE, FlashAttention, Mamba, attention variants). Works the same on general programming concepts when needed — closures, generators, channels, ownership.

## See it

The actual frozen output from running the skill on two AI/ML concepts:

<table>
<tr>
  <td align="center" width="50%">
    <a href="assets/examples/grpo-en.md"><b>GRPO</b></a>
    <br><sub>Group-Relative Policy Optimization</sub>
    <br><sub>"PPO without the critic" — group-relative advantage, shape-traced training step, k3 KL estimator</sub>
    <br><sub><a href="assets/examples/grpo-en.md">English</a> · <a href="assets/examples/grpo-zh.md">中文</a></sub>
  </td>
  <td align="center" width="50%">
    <a href="assets/examples/moe-en.md"><b>Mixture of Experts</b></a>
    <br><sub>Sparse architecture</sub>
    <br><sub>Gate → top-K → dispatch → combine, with every shape transition <code>[B,T,D] → [B,T,E] → [N,D]</code> annotated</sub>
    <br><sub><a href="assets/examples/moe-en.md">English</a> · <a href="assets/examples/moe-zh.md">中文</a></sub>
  </td>
</tr>
</table>

Each answer comes with a lightweight pseudocode file ([`grpo-pseudocode.py`](assets/examples/grpo-pseudocode.py), [`moe-pseudocode.py`](assets/examples/moe-pseudocode.py)) so you can open the code in an editor with syntax highlighting while reading the explanation.

## Usage

**Claude Code**

```bash
npx skills add JackyYang258/AgentTeacher -a claude-code -g -y
```

**Claude Code plugin marketplace** (requires Claude Code v2.1.142+)

```bash
/plugin marketplace add JackyYang258/AgentTeacher
/plugin install agent-teacher@agent-teacher
```

**Generic agents** (Codex, OpenCode, Pi, and other tools that read from `~/.agents/`)

```bash
npx skills add JackyYang258/AgentTeacher -a '*' -g -y
```

**Claude Desktop**

Download [agent-teacher.zip](https://github.com/JackyYang258/AgentTeacher/releases/latest/download/agent-teacher.zip), open Customize > Skills > "+" > Create skill, and upload the ZIP directly (no need to unzip). The ZIP is ~45KB.

**Local development**

```bash
ln -s /path/to/AgentTeacher ~/.claude/skills/agent-teacher
```

The skill auto-triggers from natural requests, no slash command needed. Example prompts:

- English: `explain GRPO` / `what is mixture of experts` / `teach me FlashAttention with code` / `how does PPO clipping actually work`
- 中文: `讲一下 GRPO` / `MoE 怎么路由 token` / `教我 FlashAttention 的 tiling 思路` / `Python 的 GIL 到底是什么`

## The spine

The spine has six parts; each has its own job.

| Part | Job | Length |
|---|---|---|
| Intuition | Frame the problem the concept solves | 1–2 sentences |
| Example | Runnable code (5–20 lines) **or** structured pseudocode for architectures and training algorithms | one code block |
| Walkthrough | Group the example into purpose units, not line-by-line narration | 2–4 paragraphs |
| Trap | The bug the concept exists to prevent or the wrong intuition newcomers reach for | one snippet + one line |
| Pointers | 2–3 adjacent concepts. **No expansion** | 3 lines |
| Test questions | 2–3 questions at increasing difficulty (recall/contrast → read the code → design/trap). Hints, **no answers** | 3 questions |

**Two example modes:**

- **Mode A — runnable.** Language features, small algorithms, APIs. 5–20 line REPL snippet, prints intermediate state, no external deps.
- **Mode B — structured pseudocode.** Architectures (Transformer, MoE, Mamba), training algorithms (GRPO, PPO, DPO), kernel concepts (FlashAttention, paged attention). Real PyTorch syntax with scaffolding dropped, shape annotations on every line that matters, the difference from a related concept always visible. File auto-written to `/tmp/<concept>-pseudocode.py` for editor viewing.

Full per-layer playbook: [references/teaching-method.md](references/teaching-method.md). Code style rules: [references/code-style-for-teaching.md](references/code-style-for-teaching.md). Concept → language mapping: [references/concept-to-language.md](references/concept-to-language.md).

## Design

Not a tutorial generator; a constraint system for technical explanations. Documents should read as composed lessons, not improvised dumps.

| Element | Rule |
|---|---|
| Form | Six parts, no exceptions. The trap is the section most lessons skip; the test questions are what most lessons omit entirely |
| Code | Real names (`gate_logits`, `expert_outputs`), not abbreviations (`g`, `e`) |
| Shapes | Every transition annotated: `[B, T, D] → [B, T, E] → [B, T, K] → [N, D]`. In Mode B this is non-negotiable |
| Pseudocode | Valid Python/PyTorch with scaffolding removed. Never natural-language `FOR each token DO ...` — that throws away what code form gives you |
| Comments | One `# WHY` comment is worth ten `# WHAT` comments. The walkthrough carries the rest |
| Length | 150–400 words of prose + code blocks + 2–3 test questions. One screen of focused reading |
| Test questions | Hints not answers; framed as questions someone could pose, not as self-checks ("if rewards were all identical, what would happen to the gradient?") |

Code language is picked per concept: PyTorch pseudocode for architectures / training-algos, Python for general CS and algorithms, Go for channels / goroutines, Rust for ownership / borrowing, C for pointers / memory, JavaScript for DOM / event loop, TypeScript or Haskell for type systems / monads. Full mapping in [references/concept-to-language.md](references/concept-to-language.md).

**Eight optional enrichments.** When the concept's nature warrants, the spine opts into up to five extras: math tier (canonical formula or Big-O recurrence), state tracking (tensor shapes for DL / participant state for protocols / data trace for algorithms), design rationale ("why √d and not √2d", "why exponential backoff"), cousin matrix (BN vs LN, GRPO vs PPO, TCP vs UDP), prerequisite + variants map, classic misconception list, visualization (heatmaps, state machines, sequence diagrams), and invariants the concept guarantees (heap property, Raft safety properties, BST invariant). Each fires only when the concept warrants. The framework was tuned for DL/ML but several modules apply across CS: data structures, distributed protocols, complex algorithms. Full decision rules and per-module playbook (DL and non-DL examples) in [references/enrichments.md](references/enrichments.md).

## Support

- If AgentTeacher helped you, give it a star or share it.
- Concept treatments that feel off? Open an issue or PR.

## License

MIT License. Worked examples in `assets/examples/` are illustrative and may be used or modified freely.
