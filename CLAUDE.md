# AgentTeacher

Concept-teaching skill: explains a technical concept through a fixed six-part structure — intuition → example (runnable or pseudocode) → walkthrough → trap → pointers → test questions.

## Before you start

- Personal / global agent rules belong outside this repo. This file records only AgentTeacher's Claude Code entry and maintenance rules.
- The full repository map, working rules, current risk areas, verification, and release flow live in `AGENTS.md`.
- The skill itself starts at `SKILL.md`. Teaching method: `references/teaching-method.md`. Code style for teaching: `references/code-style-for-teaching.md`. Concept→language mapping: `references/concept-to-language.md`. Enrichments (E1–E8): `references/enrichments.md`.
- For contributors (English / 中文 onboarding): see `CONTRIBUTING.md` / `CONTRIBUTING.zh-CN.md`.

## Common commands

```bash
bash scripts/package-skill.sh                  # build dist/agent-teacher.zip
```

The project has no build / render pipeline — output is markdown delivered in chat. There is no test runner; verification is done by running the skill on a real prompt and inspecting the lesson.

## Project-specific hard rules

- The six-layer spine L1–L6 (intuition → example → walkthrough → trap → pointers → test questions) is the contract. Don't add L7, don't drop layers. If a layer feels redundant for a specific concept, write a one-liner — don't skip.
- Mode A (runnable) vs Mode B (pseudocode) is binary. Mode B auto-writes a sidecar file at `/tmp/<slug>-pseudocode.<ext>`; Mode A writes a file only when the user asks.
- Pseudocode must be real Python / PyTorch syntax with state annotations on every line where state changes. Natural-language pseudocode (`FOR each token DO ...`) is forbidden — it throws away the precision code form gives.
- L6 is "test questions," not a comprehension check. Hints, no answers. Phrase each question concretely ("if all rewards in a group were identical, what happens to the gradient?" — not "do you understand?"). Don't frame as interview questions; don't use the word "interview" in skill output.
- Enrichments E1–E8 are concept-driven, not concept-default. Decision table is in `references/enrichments.md`. Hard cap 5 per lesson, hard floor 0 (plain six-layer lesson is the right answer for most concepts). The framework was tuned for DL/ML but E2/E3/E4/E5/E7/E8 also apply to data structures, distributed protocols, and complex algorithms. **Language features** (closures, generators, channels) never get enrichments.
- Mode B has three flavors: DL (tensor shape annotations), protocols (participant state + message arrows), algorithms / data structures (invariants + concrete trace). E2 (state tracking) means the right thing in each flavor — don't apply DL shape-annotation conventions to a protocol pseudocode block.
- When changing `SKILL.md`, sync the matching playbook in `references/teaching-method.md`. SKILL.md is the contract; references are the expanded playbook with examples. They must agree.
- Project canonical docs are English-only (`SKILL.md`, `AGENTS.md`, `CLAUDE.md`, `references/`). Bilingual surfaces are `README` and `CONTRIBUTING` (both in English and Chinese versions) and `assets/examples/` (each example exists as `-en.md` and `-zh.md`). See `CONTRIBUTING.md` for the full bilingual policy.
- Don't bundle `evals/` / `.claude-plugin/` / `dist/` into the release zip. The exclude list lives in `scripts/package-skill.sh`.
- After editing `scripts/package-skill.sh` or adding any file that should ship in the zip, refresh and inspect `dist/agent-teacher.zip`, confirming new files were `git add`-ed (the package script is based on `git ls-files`; untracked files vanish silently).
- Don't commit one-off review reports or diagnostic snapshots. Stable rules go into `AGENTS.md`, `CLAUDE.md`, `SKILL.md`, or `references/`; everything else is discarded.
