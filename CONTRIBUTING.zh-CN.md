# 贡献 AgentTeacher

[English](CONTRIBUTING.md) · [中文](CONTRIBUTING.zh-CN.md)

感谢愿意参与。AgentTeacher 很小、规则也很明确，看一遍这份文档你就知道东西在哪、怎么贡献。

## 双语策略

项目同时支持中文和英文，但**不同层用不同语言**：

| 层 | 语言 | 原因 |
|---|---|---|
| `SKILL.md`、`AGENTS.md`、`references/*` | **只用英文** | 这些是 LLM 的权威读物。LLM 当然双语，但 spec 需要一个 single source of truth —— 两边都翻译会在每次改动时同步漂移 |
| `CLAUDE.md` | 只用英文 | 同理；这是 Claude Code 的项目上下文 |
| `README.md` + `README.zh-CN.md` | **完全对译** | GitHub 第一印象，两边都要反映当前状态 |
| `CONTRIBUTING.md` + `CONTRIBUTING.zh-CN.md` | **完全对译** | 单语贡献者必须能完整 onboarding |
| `assets/examples/<name>-en.md` 和 `<name>-zh.md` | **鼓励都有** | Worked examples 是示例性质，不是权威。每种语言一份。新例子最好两个语言都提供；如果贡献者只会一种语言，给一份也行（维护者会补另一份）|
| `evals/evals.json` | 混合 | 测试集本来就该覆盖两语。每条 eval 用它对应的目标语言 |

**单语贡献者的实操规则**：读你这边语言的 README、读你这边语言的 CONTRIBUTING、看你这边语言的 worked example，然后开 PR。如果你的改动碰到 spec（`SKILL.md` 或 `references/`），用你的语言起草说明，维护者会把它落地成英文版本。

## 什么样的贡献容易合入

- **新增 worked example**，放在 `assets/examples/` 下。挑现有例子没覆盖的概念（Raft、B+ 树、FlashAttention、类型推断…）。让 skill 跑一遍，保存输出，做点润色。参见下面的"新增 worked example"。
- **概念分类错误**，在 [`references/concept-to-language.md`](references/concept-to-language.md) 里。如果你觉得某个概念推荐的语言或 Mode（A vs B）选错了，开 issue 说明理由。
- **enrichment 触发判断**。如果你能找出一个概念应该触发 E3（design rationale）或 E8（invariants）但 [`references/enrichments.md`](references/enrichments.md) 的 calibration list 里没体现，提议新增。
- **双语 README 不同步**。改了一边必须同步另一边。这里的 drift 是真 bug。
- **CI / 打包改进**。两个 workflow 在 `.github/workflows/`；打包脚本是 `scripts/package-skill.sh`。

## 什么样的贡献需要先讨论

改之前先开 issue：

- **改动六层骨架的层数**（L1–L6）。六层契约是核心，不轻易加 L7，也不轻易删层。
- **新增第九个 enrichment**。当前 E1–E8 是讨论后定下来的，新加的必须证明它填的是现有 8 个都覆盖不了的空白。
- **重命名项目、skill 或 GitHub repo**。会涉及大量链接更新。
- **改 Mode A / Mode B 的语义**。runnable-vs-pseudocode 加上 Mode B 的三种 flavor 是刻意设计。

## 项目结构（去哪里找什么）

```
AgentTeacher/
├── SKILL.md                              ← 契约（英文，权威）
├── README.md / README.zh-CN.md           ← 项目介绍（双语）
├── CONTRIBUTING.md / CONTRIBUTING.zh-CN.md ← 本文件（双语）
├── AGENTS.md                             ← 维护者手册（英文）
├── CLAUDE.md                             ← Claude Code 项目上下文（英文）
├── LICENSE                               ← MIT
├── references/
│   ├── teaching-method.md                ← 每层 playbook 配例子
│   ├── code-style-for-teaching.md        ← Mode A / Mode B / trace block 规则
│   ├── concept-to-language.md            ← 哪个概念用哪个语言
│   └── enrichments.md                    ← E1–E8 playbook + 决策规则
├── assets/examples/
│   ├── grpo-en.md / grpo-zh.md           ← 双语 worked examples
│   ├── moe-en.md  / moe-zh.md
│   └── *-pseudocode.py                   ← 共享 sidecar 代码（语言无关）
├── evals/
│   └── evals.json                        ← 测试 prompt（混合中英）
├── scripts/
│   └── package-skill.sh                  ← 打包 dist/agent-teacher.zip
├── .github/workflows/
│   ├── check.yml                         ← PR 时 lint + schema 检查
│   └── release.yml                       ← tag 触发自动打包 + 上传 zip
├── .claude-plugin/
│   └── marketplace.json                  ← Claude Code 插件市场元数据
└── dist/
    └── agent-teacher.zip                 ← tracked 发布制品
```

## 新增 worked example

1. **让 skill 跑一遍目标概念**。如果你本地装了 AgentTeacher（`ln -s ... ~/.claude/skills/agent-teacher`），开新的 Claude Code session 问，比如 "explain Raft" 或 "讲一下 B+ 树"。
2. **复制完整输出**到新文件：`assets/examples/<concept>-en.md` 或 `<concept>-zh.md`。参考现有例子（`grpo-en.md`、`moe-zh.md`）的格式。
3. **顶部加 header block**，列出 Mode、语言、触发的 enrichments，以及（如果是 Mode B 伪代码）sidecar 代码文件路径。
4. **如果是 Mode B**，把 L2 伪代码块保存到 `assets/examples/<concept>-pseudocode.py`。sidecar 是语言无关的（代码注释可以是任一语言）—— 一份 sidecar 同时服务 `-en` 和 `-zh` 两个版本。
5. **验证**：跑 `bash scripts/package-skill.sh`，确认新文件进了 `dist/agent-teacher.zip`。打包脚本基于 `git ls-files`，所以记得先 `git add`。
6. **开 PR**。如果你只写了一种语言，PR 描述里说明，维护者或其他贡献者会补另一边。

## 新增 eval

1. 改 `evals/evals.json`。每条 entry 有 `id`、`name`、`prompt`、`expected_output`、`files`。
2. Prompt 要像真实用户会说的话（带背景、自然口语）。不要写苍白的 "explain X"，除非那就是你想测的。
3. `expected_output` 要具体到能拿来打分 —— 列出触发的 enrichments、要求的 shape 注释、测试题难度梯度。
4. CI 会在 PR 时校验 JSON schema。

## 本地测试

```bash
# 1. 本地装 skill
ln -s "$(pwd)" ~/.claude/skills/agent-teacher

# 2. 开新的 Claude Code session，用你的概念试 skill
#    （打开 Claude Code，问你的问题）

# 3. 打包 release zip 确认能正常打包
bash scripts/package-skill.sh

# 4. 跑 CI 同样的检查（校验 evals.json、SKILL.md、references、zip）
python3 -c "import json; d=json.load(open('evals/evals.json')); assert len(d['evals']) > 0"
bash scripts/package-skill.sh
zipinfo -1 dist/agent-teacher.zip | head
```

## Commit 规范

- 一个 commit 一个逻辑变更。
- 第一行不超过 70 字符，现在时态，首字母大写。
- Body 解释**为什么**，不解释做了什么 —— 做了什么 diff 已经说明了。
- 双语同步改动（比如同时改两个 README）可以放在同一个 commit。

## 风格约定

文档风格本身就是简洁、直接，贡献也按这个调子来。不要"很棒的问题！"开场白、不要抱歉式表达、不要冗长铺垫。直接说意思。受众是工程师，按工程师的方式沟通。

## License

提交贡献即代表你同意你的贡献在 MIT 协议下发布（见 [LICENSE](LICENSE)）。
