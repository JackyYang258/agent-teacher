# AgentTeacher Agent Guide

> Personal/global agent rules may live outside this repository. This file records AgentTeacher-specific repository maps, Working Rules, Current Risk Areas, Verification, and Release Flow.

## Project

AgentTeacher is a Claude Code skill that teaches concepts through a fixed six-part spine: intuition → example (runnable or pseudocode) → code walkthrough → trap → pointers → test questions. It is deliberately small — one `SKILL.md`, a handful of references, a handful of evals and worked examples, one packaging script. The whole project should fit in a few hundred lines of markdown plus shell.

The skill output is delivered in conversation, not as files. The only artifacts written to disk are (a) the Mode B pseudocode sidecar for editor viewing, and (b) the full-lesson file when the user explicitly asks to save.

## Repository Map

- `SKILL.md` — skill entrypoint: triggering, language choice, the six-layer spine, output rules, anti-patterns.
- `README.md` — user-facing project intro and install instructions.
- `CLAUDE.md` — Claude-specific entry pointing here, with the project-specific hard rules.
- `LICENSE` — MIT.
- `references/teaching-method.md` — per-layer playbook with good/bad examples. The craft of each layer lives here.
- `references/code-style-for-teaching.md` — rules for teaching code (both runnable and pseudocode); explains why teaching-code differs from production-code.
- `references/concept-to-language.md` — concept area → recommended code language; runnable vs pseudocode mapping.
- `evals/evals.json` — test prompts with expected-output descriptions (closure, CAP, GIL, monad, GRPO, MoE).
- `assets/examples/` — worked example outputs frozen from running the skill (regression baselines and live demos).
- `scripts/package-skill.sh` — builds the release archive.
- `.claude-plugin/marketplace.json` — Claude Code plugin marketplace metadata.
- `dist/agent-teacher.zip` — tracked release archive.

## Commands

```bash
bash scripts/package-skill.sh                # build dist/agent-teacher.zip
```

The project has no build/render pipeline — output is markdown delivered in chat. There is intentionally no test runner; verification is done by running the skill on an eval prompt and inspecting the lesson.

## Working Rules

- The six-layer spine (L1 intuition → L2 example → L3 walkthrough → L4 trap → L5 pointers → L6 test questions) is the contract. Do not add L7, do not remove a layer. If a layer feels redundant for a specific concept, make it one line — don't drop it.
- Mode A (runnable) vs Mode B (pseudocode) is binary. Don't introduce a third mode without strong evidence that a real concept fits neither.
- Pseudocode in Mode B must follow the four rules in `references/code-style-for-teaching.md` §10: mark as pseudocode, annotate every shape change, drop scaffolding, show the seam to a cousin concept. The biggest regression risk is sliding into natural-language pseudocode (`FOR each token DO ...`) — that throws away everything code form gives us.
- L6 test questions: 2–3, increasing difficulty (recall/contrast → read the code → design/trap), hints but no answers, framed as questions someone could pose. Do **not** label them "interview questions" or set an interview scenario in skill output — the phrasing of the questions itself carries the externally-shaped quality.
- SKILL.md states the contract; `references/teaching-method.md` is the playbook with examples. Changing one without the other is drift.
- File output policy: Mode B writes a pseudocode sidecar to `/tmp/<slug>-pseudocode.<ext>` automatically; Mode A writes a file only when the user asks ("save this" / "做成笔记").
- Keep `SKILL.md` under ~250 lines. Detailed playbooks go in `references/` and are loaded by reference on demand.
- New worked examples in `assets/examples/` should be frozen outputs from real skill runs, not hand-written specimens — the value is showing the skill's actual behavior.
- Use `OK:` / `ERROR:` in script output, never emoji.

## Refactor And Packaging Hard Stops

- `scripts/package-skill.sh` packages from `git ls-files`. Any new file (script, reference, worked example) must be `git add`-ed before it can land in `dist/agent-teacher.zip`.
- Any source change that ships through the package must refresh and inspect `dist/agent-teacher.zip` — staleness of the zip is a release-readiness bug, not a later cleanup.
- Do not bundle `evals/`, `.claude-plugin/`, `dist/`, or transient `/tmp/` paths into the release zip. The exclude list is in `scripts/package-skill.sh`.
- Do not commit one-off review reports or diagnostic snapshots. Distill stable rules into `AGENTS.md`, `CLAUDE.md`, `SKILL.md`, or the `references/` files and discard the rest.

## Current Risk Areas

- **L6 softness drift.** Test questions can erode into "did this make sense?" self-checks. That is the failure mode the design explicitly rejected. Each L6 question must be answerable independently, with a concrete answer the reader can check themselves against the lesson.
- **Mode A vs Mode B mis-selection.** Writing a "runnable" MoE forward becomes 60 lines of `nn.Module` scaffolding that buries the algorithm. The decision table in `SKILL.md` is canonical — Mode B is the right choice for architectures and training algorithms.
- **Pseudocode shape annotations are load-bearing.** A pseudocode block without `# [B, T, D]`-style annotations is broken even when the syntax is valid. Reviewing a new lesson means scanning whether shape transitions are visible.
- **Domain coverage.** Current `concept-to-language.md` maps roughly 30 concept areas. Newly common concepts (mechanistic interpretability primitives, diffusion training, RLHF variants beyond GRPO/DPO) may need an entry — but only add when a real lesson surfaces the gap, not preemptively.
- **Sidecar file path assumption.** `/tmp/<slug>-pseudocode.<ext>` works on macOS / Linux. Windows or sandboxed environments would need an override mechanism, which does not yet exist. Acceptable until a user reports it.

## Verification

- **SKILL.md or references changes:** run the skill manually on a representative concept ("explain GRPO" or "what is a closure") and check that L1–L6 all appear, the code form matches the concept (runnable vs pseudocode), shape annotations are present in Mode B, and L6 questions follow the recall → read → design difficulty ladder.
- **Adding an eval:** confirm the prompt sounds like something a real user would type (with backstory, casual tone where natural), and the `expected_output` describes the deliverable specifically enough to grade against.
- **Packaging changes:** run `bash scripts/package-skill.sh`. Inspect with `zipinfo -1 dist/agent-teacher.zip`. The zip should contain `SKILL.md`, `README.md`, `LICENSE`, `AGENTS.md`, `CLAUDE.md`, `references/*`, `assets/examples/*`, `scripts/package-skill.sh`. It should NOT contain `.git/`, `dist/`, `evals/`, `.claude-plugin/`, `__pycache__/`, or `.DS_Store`.
- **Adding a worked example:** run the skill on the prompt yourself, then save the full output (including sidecar code) under `assets/examples/<concept>.md`. The frozen output doubles as a regression reference.

## Release Flow

- The project is young. No version tags yet.
- When a first version is cut: tag `v0.1.0`, refresh `dist/agent-teacher.zip`, optionally publish to the Claude Code plugin marketplace by ensuring the GitHub repo is public and `.claude-plugin/marketplace.json` points to it.
- `dist/agent-teacher.zip` is a tracked artifact. Refresh it alongside any source change that ships through the package.
- README download links should target `https://github.com/<owner>/agent-teacher/releases/latest/download/agent-teacher.zip` once a release is published.
