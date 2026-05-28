# Code style for teaching

Teaching code is not production code. Production code optimizes for *maintenance across a team over years*. Teaching code optimizes for *a stranger understanding the idea in two minutes*. The trade-offs are different, and habits from one mode actively hurt the other.

This file captures the rules. When in doubt, ask: "would this line help or distract a reader meeting this concept for the first time?"

---

## 1. Names say what they mean

Production code can use `u`, `f`, `x` because the file context tells you what they are. A teaching example has no surrounding context — the names *are* the context.

Bad:

```python
def f(n):
    a = 0
    for i in range(n):
        a += i
    return a
```

Good:

```python
def sum_through(n):
    total = 0
    for current in range(n):
        total += current
    return total
```

The good version teaches you the algorithm without needing a single comment.

---

## 2. Show the seam

When the concept *replaces* something, show what it replaces. The reader learns by diffing.

Teaching `reduce`:

Bad:

```python
from functools import reduce
total = reduce(lambda acc, x: acc + x, numbers, 0)
```

Good:

```python
# the loop you would have written:
total = 0
for x in numbers:
    total = total + x

# the same thing, written with reduce:
from functools import reduce
total = reduce(lambda acc, x: acc + x, numbers, 0)
```

Now `reduce` has *meaning* — it's the loop, compressed. The bad version asks you to learn `reduce` cold.

Teaching `async`/`await`: show the blocking version first, then the async version. Teaching list comprehensions: show the `for` loop first.

---

## 3. `print()` is a teaching tool

Production code with eight `print`s is a code smell. Teaching code with eight `print`s might be the whole point — the prints are *the demonstration*.

Bad (production habit creeping in):

```python
result = compute_something(data)
return result
```

Good (teaching `compute_something`):

```python
print("input:    ", data)
intermediate = data * 2
print("after x2: ", intermediate)
result = intermediate + 1
print("final:    ", result)
```

The reader runs it and *sees* the transformation. No mental simulation required.

Aligned labels (the spacing after `:`) make output scannable.

---

## 4. Comments: only the WHY, only the non-obvious

Bad (what-comments):

```python
count = 0  # initialize counter to zero
count += 1  # increment count
```

Bad (production-style block comments):

```python
# ============================================
# COUNTER MODULE
# This module implements a counter using a
# closure pattern with nonlocal state.
# ============================================
```

Good (one WHY comment on the only line that needs it):

```python
def make_counter():
    count = 0
    def increment():
        nonlocal count   # without this, count += 1 creates a new local
        count += 1
        return count
    return increment
```

The `nonlocal` line is the only non-obvious one. Comment it, leave everything else clean. The walkthrough (L3) carries the rest.

---

## 5. No defensive code unless defense is the concept

Production code does input validation, type checking, retries. Teaching code skips all of that — it gets in the way.

Bad:

```python
def divide(a, b):
    if not isinstance(a, (int, float)):
        raise TypeError("a must be numeric")
    if not isinstance(b, (int, float)):
        raise TypeError("b must be numeric")
    if b == 0:
        raise ZeroDivisionError("cannot divide by zero")
    return a / b
```

Good (if the concept is *division*):

```python
def divide(a, b):
    return a / b
```

Exception: if the concept *is* exception handling, validation, or type checking, then those become the focus and everything else strips down.

---

## 6. One concept per example

A teaching example is a microscope, not a tour. It demonstrates *exactly one thing*.

Bad (teaching closures, accidentally also teaching decorators, type hints, and dataclasses):

```python
from dataclasses import dataclass
from typing import Callable

@dataclass
class Counter:
    start: int = 0

    def make(self) -> Callable[[], int]:
        count = self.start
        def increment() -> int:
            nonlocal count
            count += 1
            return count
        return increment
```

Good (closures only):

```python
def make_counter():
    count = 0
    def increment():
        nonlocal count
        count += 1
        return count
    return increment
```

Strip everything that isn't the concept. Type hints, dataclasses, decorators, `__main__` guards — all noise unless they *are* the lesson.

---

## 7. Show output inline

A reader of a lesson is probably not going to run the code right now. Put the output in a comment so they can see what would happen.

```python
counter = make_counter()
print(counter())   # 1
print(counter())   # 2
print(counter())   # 3
```

The `# 1`, `# 2`, `# 3` are not redundant — they're the *result*. The reader's eye runs the program.

This applies to anything with deterministic output. For random output, write `# e.g. 0.4382`.

---

## 8. Idiomatic but not clever

Use the idiom of the language — but don't show off. The goal is "this is how you'd actually write it," not "look at the trick I know."

Teaching iteration in Python:

OK: `for x in xs:` — idiomatic.
Not great: `list(map(some_func, xs))` — unless you're teaching `map`.
Definitely not: `[*(some_func(x) for x in xs)]` — clever, not clear.

Teaching a value swap:

OK: `a, b = b, a` — Python's idiom.
Not OK: `a, b = b, a` *with* a comment "// XOR swap would be faster" — distracting.

---

## 9. The first line of code should resolve a question raised by L1

L1 promises "a closure remembers variables from where it was born." The first non-trivial line of L2 should let the reader point at it and say *"oh, that's where it remembers."*

If L1 says "futexes let userspace handle the fast path of locking" and L2 starts with `int fd = open(...)`, the reader's question is unanswered for ten lines. Restructure: open with the line where the fast path happens.

---

## 10. Pseudocode for architectures and training algorithms

This section is the rule book for when the concept is a *system* (Mixture of Experts, FlashAttention, the Transformer block) or a *training algorithm* (GRPO, PPO, DPO, RLHF). Runnable code is the wrong tool here — you'd write 60 lines of `nn.Module` scaffolding and the algorithm would be 8 of them. Structured pseudocode reverses that ratio.

### What pseudocode means here

It does **not** mean prose-in-uppercase ("FOR each token IF gate score > threshold..."). That style throws away the precision that makes code worth reading. It means **real Python/PyTorch syntax**, with the parts that aren't the concept stripped out and the parts that *are* the concept annotated heavily.

### The four rules

#### Rule 1 — Mark the block

Top of the code block, one comment line:

```python
# pseudocode — illustrative, not runnable
```

The reader needs to know not to copy-paste it into a notebook expecting it to work. This one line prevents 90% of the "I tried to run your example and got an error" follow-ups.

#### Rule 2 — Annotate every shape that changes

This is the single most important rule. For architecture and training-algorithm concepts, **shape transitions are the load-bearing part of the lesson**. Skip them and the code reads as noise.

Conventions:

- Stable axis letters: `B` batch, `T` tokens, `D` model dim, `H` heads, `E` experts, `K` top-k, `V` vocab. Use these consistently across the lesson.
- Annotate inline, right of the assignment, aligned where possible:

```python
gate_logits = gate(x)                        # [B, T, E]
top_w, top_i = gate_logits.topk(k, dim=-1)   # [B, T, K], [B, T, K]
```

- Annotate transitions explicitly when the shape changes in a non-obvious way:

```python
tokens = x[mask]   # [B, T, D] → [N, D]   (N = number of routed tokens)
```

The `[B, T, D] → [N, D]` is doing the same work as a paragraph of prose. It tells the reader *what the operation accomplishes structurally*.

#### Rule 3 — Drop the scaffolding, keep the algorithm

Strip these aggressively:

- `import torch, torch.nn as nn` — assumed.
- `class Foo(nn.Module): def __init__(self, ...): super().__init__(); ...` — assumed. Write the forward logic as a standalone function.
- Dataloader / batching / distributed init — the lesson is not about how data arrives.
- Optimizer step boilerplate (`optimizer.zero_grad(); loss.backward(); optimizer.step()`) unless the concept *is* the optimization step.

Keep these unconditionally:

- Every operation that's part of the algorithm: `softmax`, `topk`, `gather`, `mask_fill`, `cumsum`, `where`.
- Every `for` / `if` / `while` in the algorithm's control flow.
- Shape annotations on every line where the shape moves.
- The seam — what this replaces or what this differs from (see Rule 4).

#### Rule 4 — Show the seam to the cousin concept

Most algorithms and architectures are interesting *relative to a predecessor*. GRPO is interesting because of what it removes from PPO (the critic network). MoE is interesting because of what it adds to a dense FFN (routing + sparsity). FlashAttention is interesting because of what it changes about standard attention (tiling for memory).

Show the cousin in two or three lines, side by side or with a "compare with" comment:

```python
# pseudocode — illustrative, not runnable
# PPO advantage (needs a learned value function V):
#   advantages = rewards + gamma * V(s_next) - V(s)
#
# GRPO advantage (no value function — uses the group's own mean):
def grpo_advantages(rewards):
    # rewards: [B, G]  (G samples per prompt)
    mean = rewards.mean(dim=-1, keepdim=True)
    std  = rewards.std(dim=-1, keepdim=True)
    return (rewards - mean) / (std + 1e-8)        # [B, G]
```

The PPO line in the comment is doing a quarter of the lesson. Don't drop it.

### What stays the same from production-code-don'ts

Even in pseudocode:

- Names still say what they mean: `gate_logits` not `g`, `expert_outputs` not `e`.
- Comment only the WHY: `# group-relative — no critic needed` next to the normalization line is gold; `# subtract the mean` next to `- mean` is noise.
- One concept per block. If you're tempted to also show the KL penalty, the clipping ratio, *and* the entropy bonus in the same GRPO block, you have three lessons fighting for the floor. Pick one.

### A common failure to watch for

When writing pseudocode for an architecture, the temptation is to compress it into one beautiful nested expression:

```python
# bad pseudocode — too compressed to teach from
out = sum(w * e(x[m]) for w, e, m in zip(top_w, experts, masks))
```

This is wrong for teaching even if it's a faithful one-liner. The lesson is in the *steps*: gate → top-k → softmax → mask → dispatch → combine. Compressing them into a comprehension hides the steps. Write the explicit `for` loop.

The inverse is also wrong:

```python
# bad pseudocode — over-expanded
for b in range(B):
    for t in range(T):
        for e in range(E):
            if e in top_indices[b, t]:
                ...
```

Three nested loops in a vectorized architecture are a *mental model bug*: MoE is vectorized routing, not per-token iteration. The pseudocode reinforces the wrong mental model. Use the tensor-level loop (one `for` over experts, vectorized over tokens) — that matches how it actually runs.

---

## 11. Working through a worked example

The full template, applied to teaching the concept of **memoization** in Python.

```python
# without memoization — recomputes fib(30) a quarter-billion times
def fib(n):
    if n < 2:
        return n
    return fib(n - 1) + fib(n - 2)

# with memoization — remember each result the first time we compute it
cache = {}
def fib_memo(n):
    if n in cache:
        return cache[n]
    if n < 2:
        return n
    result = fib_memo(n - 1) + fib_memo(n - 2)
    cache[n] = result   # the line memoization is named after
    return result

import time
for func in (fib, fib_memo):
    start = time.time()
    print(func.__name__, func(30), f"{time.time() - start:.3f}s")
# fib       832040 0.302s
# fib_memo  832040 0.000s
```

Notice what's there and what isn't:

- Naming says the intent (`fib_memo`, `cache`, `result`).
- The seam is shown — `fib` and `fib_memo` side by side.
- One `# WHY` comment on the only non-obvious line (`cache[n] = result`).
- No type hints, no `@functools.cache` (that's L5 territory).
- The timing block at the bottom *proves* the lesson.
- Output is inlined.

If your draft code has this shape, you've nailed L2.
