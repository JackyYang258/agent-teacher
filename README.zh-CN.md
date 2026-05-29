<div align="center">
  <h1>AgentTeacher</h1>
  <p><b>好概念，配好代码。</b></p>
  <p><a href="README.md">English</a> · <a href="README.zh-CN.md"><b>中文</b></a></p>
  <a href="https://github.com/JackyYang258/AgentTeacher/stargazers"><img src="https://img.shields.io/github/stars/JackyYang258/AgentTeacher?style=flat-square" alt="Stars"></a>
  <a href="https://github.com/JackyYang258/AgentTeacher/releases"><img src="https://img.shields.io/github/v/tag/JackyYang258/AgentTeacher?label=version&style=flat-square" alt="Version"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square" alt="License"></a>
</div>

## 为什么

我每天读 AI paper，"扫过一遍"和"真懂了"之间差距最大的就是那些 dense concept —— GRPO 里的 group-relative advantage、MoE 的 expert routing、FlashAttention 的 attention tiling。默认的 LLM 解释会撞上两种失败模式：要么是没有代码锚定的散文，要么是被 60 行 model + dataloader 设置淹没的算法。

AgentTeacher 给它一个框架：每个概念都走相同的六层骨架 —— 直觉、例子、拆解、陷阱、延伸、测试题 —— 例子要么是 10 行能跑的 REPL 片段，要么是带 shape 注释的 PyTorch 伪代码。结构锁定后，解释的质量从模型不再临场发挥的那一刻起就上一个台阶。

主要针对 **AI/ML 概念**：训练算法（GRPO、PPO、DPO、RLHF）、架构（MoE、FlashAttention、Mamba、attention 变体）。对通用编程概念也一样适用 —— 闭包、generator、channel、ownership。

## 看效果

两个 AI/ML 概念上跑 skill 的真实冻结输出：

<table>
<tr>
  <td align="center" width="50%">
    <a href="assets/examples/grpo-zh.md"><b>GRPO</b></a>
    <br><sub>组相对策略优化</sub>
    <br><sub>"没有 critic 的 PPO" —— group-relative advantage、shape-traced 训练步、k3 KL 估计</sub>
    <br><sub><a href="assets/examples/grpo-en.md">English</a> · <a href="assets/examples/grpo-zh.md"><b>中文</b></a></sub>
  </td>
  <td align="center" width="50%">
    <a href="assets/examples/moe-zh.md"><b>Mixture of Experts</b></a>
    <br><sub>稀疏架构</sub>
    <br><sub>Gate → top-K → dispatch → combine，每一次 shape 转换 <code>[B,T,D] → [B,T,E] → [N,D]</code> 都标出来</sub>
    <br><sub><a href="assets/examples/moe-en.md">English</a> · <a href="assets/examples/moe-zh.md"><b>中文</b></a></sub>
  </td>
</tr>
</table>

每个回答都配了轻量级的伪代码文件（[`grpo-pseudocode.py`](assets/examples/grpo-pseudocode.py)、[`moe-pseudocode.py`](assets/examples/moe-pseudocode.py)），可以在编辑器里看高亮，一边读解释一边对照代码。

## 使用方式

**Claude Code**

```bash
npx skills add JackyYang258/AgentTeacher -a claude-code -g -y
```

**Claude Code 插件市场**（需要 Claude Code v2.1.142+）

```bash
/plugin marketplace add JackyYang258/AgentTeacher
/plugin install agent-teacher@agent-teacher
```

**通用 agent**（Codex、OpenCode、Pi 等读取 `~/.agents/` 的工具）

```bash
npx skills add JackyYang258/AgentTeacher -a '*' -g -y
```

**Claude Desktop**

下载 [agent-teacher.zip](https://github.com/JackyYang258/AgentTeacher/releases/latest/download/agent-teacher.zip)，打开 Customize > Skills > "+" > Create skill，直接上传 ZIP（不需要解压）。ZIP 大约 50KB。

**本地开发**

```bash
ln -s /path/to/AgentTeacher ~/.claude/skills/agent-teacher
```

Skill 会根据自然语言请求自动触发，不需要 slash command。例如：

- 中文：`讲一下 GRPO` / `MoE 怎么路由 token` / `教我 FlashAttention 的 tiling 思路` / `Python 的 GIL 到底是什么`
- 英文：`explain GRPO` / `what is mixture of experts` / `teach me FlashAttention with code` / `how does PPO clipping actually work`

## 骨架

骨架分为六层，每一层都有自己的职责。

| 部分 | 职责 | 长度 |
|---|---|---|
| 直觉 | 把概念在解决的问题用 1-2 句话框出来 | 1-2 句 |
| 例子 | 能跑的代码（5-20 行）**或**架构/训练算法的结构化伪代码 | 一段代码 |
| 拆解 | 把例子按"用途单元"分段讲，不要逐行复述 | 2-4 段 |
| 陷阱 | 这个概念是为了避免哪个 bug，或者新手会本能地理解错成什么 | 一段代码 + 一行点评 |
| 延伸 | 2-3 个相邻概念。**不要展开** | 3 行 |
| 测试题 | 2-3 道难度递增的题（recall/对比 → 读代码 → 设计/陷阱）。**给 hint，不给答案** | 3 题 |

**两种例子模式：**

- **Mode A — runnable.** 语言特性、小算法、API。5-20 行 REPL snippet，把中间状态打印出来，不带外部依赖。
- **Mode B — 结构化伪代码.** 架构（Transformer、MoE、Mamba）、训练算法（GRPO、PPO、DPO）、kernel 概念（FlashAttention、paged attention）。真 PyTorch 语法，砍掉脚手架，**每个 shape 转换都要标注**，跟相近概念的差异要写出来。文件会自动写到 `/tmp/<concept>-pseudocode.py` 方便在编辑器里看。

完整每层 playbook：[references/teaching-method.md](references/teaching-method.md)。代码风格规则：[references/code-style-for-teaching.md](references/code-style-for-teaching.md)。概念 → 语言映射：[references/concept-to-language.md](references/concept-to-language.md)。

## 设计

不是教程生成器，而是**技术解释的约束系统**。文档读起来应该像被精心组织过的 lesson，不是临场堆砌的内容倾倒。

| 元素 | 规则 |
|---|---|
| 形 | 六部分，无例外。"陷阱"是大多数 lesson 跳过的部分；"测试题"是大多数 lesson 完全省略的部分 |
| 代码 | 用有意义的名字（`gate_logits`、`expert_outputs`），不要 `g`、`e` 这种缩写 |
| Shape | 每个形状转换都标注：`[B, T, D] → [B, T, E] → [B, T, K] → [N, D]`。Mode B 里这条是硬规则，不商量 |
| 伪代码 | 真 Python/PyTorch 语法，砍掉脚手架。**禁止**自然语言伪代码 `FOR each token DO ...` —— 那等于扔掉了代码这种形式给你的精度 |
| 注释 | 一个 `# WHY` 注释胜过十个 `# WHAT`。其余靠拆解承担 |
| 长度 | 150-400 字散文 + 代码块 + 2-3 道测试题。一个屏幕能读完 |
| 测试题 | 给 hint 不给答案；用问题本身的具体性传达"外部考察"语气（"如果 reward 全相等会发生什么"而不是"你理解了吗"） |

代码语言按概念选：DL 架构/训练算法用 PyTorch 伪代码；通用 CS / 算法用 Python；channel / goroutine 用 Go；ownership / borrowing 用 Rust；指针 / 内存用 C；DOM / 事件循环用 JavaScript；类型系统 / monad 用 TypeScript 或 Haskell。完整映射在 [references/concept-to-language.md](references/concept-to-language.md)。

**八个可选 enrichment.** 当概念性质允许时，骨架最多可选挂 5 个增强：math tier（标准公式或 Big-O 递推）、state tracking（DL 是 tensor shape；协议是参与方状态；算法是数据 trace）、design rationale（"为什么除以 √d 而不是 √2d"、"为什么指数退避"）、cousin matrix（BN vs LN、GRPO vs PPO、TCP vs UDP）、prerequisite + variants 依赖图、misconception 列表、visualization（heatmap、状态机、时序图），以及 invariant（heap 性质、Raft safety properties、BST 不变量）。每个 enrichment **只有当概念性质触发它时才开启**。框架以 DL/ML 为主调，但多个模块也适用于数据结构、分布式协议、复杂算法。完整决策规则和 per-module playbook（DL 和非 DL 例子都有）在 [references/enrichments.md](references/enrichments.md)。

## 贡献

欢迎贡献。贡献流程和双语策略在 [CONTRIBUTING.zh-CN.md](CONTRIBUTING.zh-CN.md)（[English](CONTRIBUTING.md)）。

- 觉得 AgentTeacher 帮到你了，给个 star 或者分享给朋友。
- 看到 concept 处理得不到位？开个 issue 或 PR。

## License

MIT 协议。`assets/examples/` 下的 worked examples 是示例性质，可以自由使用或修改。
