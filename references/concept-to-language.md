# Concept → language mapping

Choose the language that makes the concept *cheapest to demonstrate*. The wrong language forces you to spend L2 explaining the language itself instead of the concept. The right language disappears.

User preference always wins. If the user says "show me in Rust," use Rust even if Python would be clearer — they're learning Rust through the lens of this concept, which is its own valid goal.

---

## Decision rules (in priority order)

1. **User specified a language** → use it.
2. **Concept is intrinsic to a language** ("Python's GIL," "Go channels," "JavaScript's event loop") → use that language.
3. **Concept requires features the candidate language lacks** (teaching pointers in Python is impossible; teaching higher-kinded types in Java is awful) → pick a language with the feature.
4. **Default**: Python, because it reads like pseudocode and most programmers can read it even if they don't write it.

---

## Mapping table

| Concept area | First choice | Second choice | Avoid | Why |
|---|---|---|---|---|
| Variables, scope, closures (general) | Python | JavaScript | C | Need first-class functions and dynamic scope semantics |
| Recursion, divide-and-conquer | Python | Haskell | Java | Minimal ceremony, easy to print intermediate state |
| Data structures (list, dict, tree, graph) | Python | TypeScript | C | Built-in literals make the code about the structure, not the boilerplate |
| Algorithms (sort, search, DP) | Python | Go | C++ | Read like pseudocode |
| OOP basics (class, inheritance, polymorphism) | Python | TypeScript | Java | Less syntactic noise than Java; still has classes |
| Threading & GIL | Python | — | — | The concept *is* CPython's |
| Async / coroutines / event loop | Python `asyncio` | JavaScript | — | Both are first-class; pick by user's environment |
| Channels, goroutines, select | Go | — | — | Built into the language |
| Actor model | Erlang or Elixir | — | Python | Actors are the language, not a library |
| Mutex, semaphore, condition variable | C (pthreads) | Python `threading` | JavaScript | C shows the OS primitives; Python is OK for "what is a mutex" |
| Lock-free, memory ordering, atomics | C++ or Rust | C | Python | You can't talk about acquire/release without it being in the language |
| Pointers, references, indirection | C | Rust | Python, JavaScript | The concept doesn't exist in GC'd languages |
| Memory layout, struct padding, alignment | C | Rust | — | Need direct memory access |
| Ownership, borrowing, lifetimes | Rust | — | — | Rust *is* the concept |
| Manual memory management | C | C++ | — | malloc/free is the lesson |
| Garbage collection (conceptual) | Python or JavaScript | — | C | Need a runtime that does it |
| Type systems (basic) | TypeScript | Python with type hints | — | TS has structural typing, gradual typing, narrowing |
| Generics, variance | TypeScript | Scala | Java | TS shows covariance/contravariance with less noise |
| ADTs, pattern matching | Rust | Haskell | Python | Sum types + exhaustive match |
| Monads, functors, applicatives | Haskell | Scala | Python | Need a type system that can *express* the pattern |
| Effects, dependency injection (typed) | Haskell | Scala | — | Effect systems live here |
| Frontend, DOM, events | JavaScript | TypeScript | — | Native habitat |
| HTTP, REST, requests | Python (`requests`) | Bash (`curl`) | — | Both clear; bash if showing protocol-level details |
| Sockets, protocol details | Python or Go | C | — | Python shows API; C shows what's actually happening |
| Linear algebra, vectors, matrices | Python (numpy) | — | — | Ecosystem; the notation is the lesson |
| Neural networks, backprop, optimizers | Python (PyTorch) | Python (numpy from scratch) | — | "From scratch" for L2 of "what is backprop"; PyTorch for "what is Adam" |
| **Model architectures** (Transformer block, MoE, attention variants, Mamba, RetNet) | **PyTorch pseudocode** | — | Runnable PyTorch | Use pseudocode mode (see SKILL.md). Shape annotations on every line are mandatory — the architecture *is* the shape transitions. |
| **Training algorithms** (PPO, GRPO, DPO, RLHF, GRPO-style RL) | **PyTorch pseudocode** | — | Runnable | Use pseudocode mode. Always show the seam with the predecessor algorithm (PPO for GRPO, supervised FT for DPO). The delta *is* the lesson. |
| **Efficient-attention / kernel concepts** (FlashAttention, Paged attention, KV cache) | **Pseudocode (Python or CUDA-flavored)** | — | Actual CUDA | Use pseudocode mode. Show the memory tiling and what's recomputed vs. cached — that's the concept, not the kernel optimization. |
| Statistics, sampling, probability | Python (numpy) | R | — | Either works; choose by audience |
| SQL, joins, indexes | SQL (sqlite in-memory) | — | — | The concept *is* SQL |
| Regex | Python | JavaScript | — | The flavor is similar enough |
| Parsing, ASTs | Python | TypeScript | — | Easy data structures, no ceremony |
| Compilers, IR, codegen | — | — | — | Too broad — break into sub-concepts first |
| Operating system primitives (process, signal, fd) | C | Python (`os` module) | — | C if showing the actual syscall; Python if showing the shape |
| Shell concepts (pipes, redirection, exit codes) | Bash | — | — | The concept *is* the shell |
| Cryptography (concept-level) | Python | — | C | Library-level is plenty; never roll your own |
| Distributed systems concepts (CAP, consensus, replication) | Pseudocode or Python | Go | — | Concept-level prose with pseudocode beats real distributed code |

---

## Special cases

### When the concept *is* the language

"Explain Python's GIL" — Python. "Explain Go's channel semantics" — Go. "Explain Rust's borrow checker" — Rust. No alternative; the language and the concept are the same lesson.

### When pseudocode beats real code

Some concepts are about *what the system does*, not about how a specific language expresses it. Forcing them into runnable code drags in 50 lines of setup and buries the lesson. Use structured pseudocode (see [code-style-for-teaching.md](code-style-for-teaching.md) §10 for the full rule book) when:

- **Distributed protocols** (Paxos, Raft, two-phase commit, CAP scenarios). Real implementations need network setup that dwarfs the algorithm. Use named participants (`leader`, `follower`) and message arrows.
- **Model architectures** (Transformer block, MoE, attention variants, Mamba). The concept *is* the wiring and the shape transitions, not a function you call. Use PyTorch-flavored pseudocode with inline shape annotations on every line.
- **Training algorithms** (PPO, GRPO, DPO, RLHF). Real implementations need a model + optimizer + reward + dataloader. Strip all of that; show the algorithm. Always include a 2–3 line comparison with the predecessor algorithm (the seam).
- **Memory/kernel-level concepts** (FlashAttention, KV cache, paged attention). The lesson is about *what is cached, recomputed, or tiled* — not the actual CUDA. Use Python-flavored pseudocode with memory-access comments.

Across all four cases: keep it as **real syntax with selective elision** (drop scaffolding, keep every operation that matters). Never regress to natural-language pseudocode (`FOR each token DO …`) — that throws away the precision that made code worth using.

### When the user's stack is known

If the conversation history shows the user is working in a specific stack (e.g., they just had you debug a Django app), prefer that stack for the lesson when possible. They'll find it easier to map to what they already know.

But don't bend the rules: if they're a Django developer asking about pointer arithmetic, the lesson is in C. Acknowledging the language switch in one sentence is fine ("pointers don't exist in Python, so we'll use C — the ideas transfer back to thinking about object references in Python").

### When two languages tie

Pick the one with **smaller setup**. A lesson in Python with `import sys` is cheaper than the same lesson in Rust requiring `cargo new`. Cheaper setup = reader more likely to actually run it.

---

## What this file is *not*

This file does not say "use language X for concept Y because X is better." It says: "use X because X makes the concept easier to *show*." The "better" judgment is task-specific; the "easier to show" judgment is what matters for a lesson.

If you find a concept that doesn't fit cleanly into this table, default to Python and note in L1 if the concept loses something in translation. The reader is better served by a clear lesson in the wrong language than a perfect lesson they can't read.
