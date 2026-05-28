# Contributing to AgentTeacher

[English](CONTRIBUTING.md) · [中文](CONTRIBUTING.zh-CN.md)

Thanks for thinking about contributing. AgentTeacher is small and opinionated, which makes it easy to get involved — read this once and you'll know where everything lives.

## Bilingual policy

The project supports both English and Chinese, but in different layers:

| Layer | Language | Why |
|---|---|---|
| `SKILL.md`, `AGENTS.md`, `references/*` | **English only** | These are the LLM's authoritative reading material. The LLM is bilingual, but the spec needs a single source of truth — translating both would create sync drift on every change. |
| `CLAUDE.md` | English only | Same reason; this is project-context for Claude Code. |
| `README.md` + `README.zh-CN.md` | **Full parity** | First impression on GitHub. Both must reflect the current state. |
| `CONTRIBUTING.md` + `CONTRIBUTING.zh-CN.md` | **Full parity** | A monolingual contributor must be able to onboard fully. |
| `assets/examples/<name>-en.md` and `<name>-zh.md` | **Both encouraged** | Worked examples are illustrative, not authoritative. Each language has its own. New examples ideally ship in both languages; one is acceptable if the contributor is monolingual (a maintainer will translate the other). |
| `evals/evals.json` | Mixed | Test set should cover both languages anyway. Each eval is in its target language. |

**Practical rule for monolingual contributors:** read the README in your language, read this CONTRIBUTING in your language, look at the worked example in your language. Then propose your change. If your change touches the spec (`SKILL.md` or `references/`), draft it in your language and the maintainer will land it in English.

## What kinds of contributions land smoothly

- **New worked examples** under `assets/examples/`. Pick a concept the existing examples don't cover (Raft, B+ tree, FlashAttention, type inference, …). Run the skill on it, save the output, polish for clarity. See "Adding a worked example" below.
- **Misclassified concepts** in [`references/concept-to-language.md`](references/concept-to-language.md). If you think a concept's recommended language or Mode (A vs B) is wrong, open an issue with a justification.
- **Missing enrichments** for concepts. If you can show a concept that should fire E3 (design rationale) or E8 (invariants) but isn't reflected in [`references/enrichments.md`](references/enrichments.md)'s calibration list, propose an addition.
- **Bilingual READMEs out of sync.** When one is updated, the other must follow. Drift here is a real bug.
- **CI / packaging improvements.** The two workflows live in `.github/workflows/`; the packaging script is `scripts/package-skill.sh`.

## What kinds of contributions need more discussion first

Open an issue before doing the work:

- **Adding or removing a layer in the spine** (L1–L6). The six-layer contract is core. We don't add L7 lightly; we don't remove a layer lightly.
- **Adding a ninth enrichment.** The current eight (E1–E8) were debated. New ones must demonstrate they fill a real gap that the existing eight can't cover.
- **Renaming the project, the skill, or the GitHub repo.** Lots of links to update.
- **Changing Mode A / Mode B semantics.** The runnable-vs-pseudocode binary with three flavors of Mode B is intentional.

## Project layout (where to look)

```
AgentTeacher/
├── SKILL.md                              ← the contract (English, canonical)
├── README.md / README.zh-CN.md           ← project intro (bilingual)
├── CONTRIBUTING.md / CONTRIBUTING.zh-CN.md ← this file (bilingual)
├── AGENTS.md                             ← maintainer playbook (English)
├── CLAUDE.md                             ← Claude Code project context (English)
├── LICENSE                               ← MIT
├── references/
│   ├── teaching-method.md                ← per-layer playbook with examples
│   ├── code-style-for-teaching.md        ← Mode A / Mode B / trace block rules
│   ├── concept-to-language.md            ← which language for which concept
│   └── enrichments.md                    ← E1–E8 playbook + decision rules
├── assets/examples/
│   ├── grpo-en.md / grpo-zh.md           ← bilingual worked examples
│   ├── moe-en.md  / moe-zh.md
│   └── *-pseudocode.py                   ← shared sidecar code (language-agnostic)
├── evals/
│   └── evals.json                        ← test prompts (mixed CN/EN)
├── scripts/
│   └── package-skill.sh                  ← builds dist/agent-teacher.zip
├── .github/workflows/
│   ├── check.yml                         ← lint + schema check on PR
│   └── release.yml                       ← auto-build + attach zip on tag
├── .claude-plugin/
│   └── marketplace.json                  ← Claude Code plugin marketplace metadata
└── dist/
    └── agent-teacher.zip                 ← tracked release artifact
```

## Adding a worked example

1. **Run the skill on the target concept.** If you've installed AgentTeacher locally (`ln -s ... ~/.claude/skills/agent-teacher`), open a fresh Claude Code session and ask, e.g., "explain Raft" or "讲一下 B+ 树".
2. **Copy the full output** into a new file: `assets/examples/<concept>-en.md` and/or `<concept>-zh.md`. Use existing examples (`grpo-en.md`, `moe-zh.md`) as templates.
3. **Add a header block** at the top of the example listing the Mode, language, fired enrichments, and (if Mode B pseudocode) a sidecar code file path.
4. **If Mode B**, save the L2 pseudocode block to `assets/examples/<concept>-pseudocode.py`. The sidecar is language-agnostic (code comments can be in either language) — one sidecar serves both `-en` and `-zh` versions.
5. **Verify**: run `bash scripts/package-skill.sh` and confirm the new file is included in `dist/agent-teacher.zip`. The package script reads from `git ls-files`, so `git add` your new files first.
6. **Open a PR.** If you only wrote one language version, mention this in the PR description — a maintainer or another contributor will translate the other side.

## Adding a new eval

1. Edit `evals/evals.json`. Each entry has `id`, `name`, `prompt`, `expected_output`, `files`.
2. The prompt should sound like something a real user would type (with backstory, casual tone where natural). Avoid sterile "explain X" prompts unless that's exactly what you're testing.
3. The `expected_output` should be specific enough to grade against — list the fired enrichments, the required shape annotations, the test-question difficulty ladder.
4. CI will validate the JSON schema on PR.

## Local testing

```bash
# 1. Install the skill locally
ln -s "$(pwd)" ~/.claude/skills/agent-teacher

# 2. Try the skill in a fresh Claude Code session on your concept
#    (open Claude Code, type your question)

# 3. Build the release zip to confirm everything packages
bash scripts/package-skill.sh

# 4. Run the same checks CI runs (validates evals.json, SKILL.md, refs, zip)
python3 -c "import json; d=json.load(open('evals/evals.json')); assert len(d['evals']) > 0"
bash scripts/package-skill.sh
zipinfo -1 dist/agent-teacher.zip | head
```

## Commit conventions

- One logical change per commit.
- First line under 70 characters, present tense, capitalized.
- Body explains *why*, not what. The diff explains the what.
- Bilingual changes (e.g. updating both READMEs) can go in one commit.

## Code of behavior

Be terse and direct, like the docs. No filler greetings, no apologies, no "great question!" Just say what you mean. The audience is engineers; treat them like one.

## License

By contributing, you agree your contribution is licensed under the MIT License (see [LICENSE](LICENSE)).
