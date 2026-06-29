# 3rd exercise — resume notes

Four deliverables. The two "ξανά" (again) ones are ports of code already in this repo.

| File | Lang | Status |
|---|---|---|
| `studies.py` | Python | **in progress** — scaffolding done, `feasible()` is TODO(human) |
| `studies.pl` | Prolog | not started — clpfd twin of studies.py |
| `walks.pl`  | Prolog | not started — port of `../1st_exer/walks.cpp` |
| `lights.py` | Python | not started — port of `../2nd_exer/lights.ml` |

Constraint: Python = single file, no classes, stdlib only, CPython 3.13.5.
Prolog = single file, must run on GNU-Prolog 1.4.5 / SWI 9.2.9 / YAP 7.6.0 (only one needs to work).

---

## studies.py — Στρατηγική Σπουδών (in progress)

Minimize `S` = max semester used. Structure: optimization around a feasibility check.
- Cycle in prerequisites → `IMPOSSIBLE`.
- `S = N` always works when acyclic (each course its own semester in topo order),
  so search `S = lower_bound .. N`, return first feasible.
- lower_bound = `max(ceil(N/K), longest prerequisite chain)`.

Done: parsing, Kahn topo sort + cycle detection, longest_chain, bounds, search loop.

**NEXT (TODO(human) at studies.py:~75):** write the `feasible(s)` backtracking.
- assign courses in topological `order` (prereqs already placed when you reach a course)
- `lo = max(sem[a] for a in pre[c]) + 1`  ← STRICT prereq, the `+1` matters
- only reject a value used by an *assigned* conflicting course (`sem[d] != 0 and sem[d] == v`)
- keep `count[v] < k` for capacity; bump on place, decrement on backtrack

Test: `studies1.txt`→4, `studies2.txt`→3, `studies3.txt`→IMPOSSIBLE (files already here).

## studies.pl — Prolog twin (not started)

Almost free with SWI clpfd:
- `Sems ins 1..N`
- each prereq `a→b`: `A #< B`
- each conflict `x,y`: `X #\= Y`
- capacity: `global_cardinality(Sems, Pairs)` with each count var `#=< K`
- `Max #= max(Sems...)`, then `labeling([min(Max)], Sems)`
- cycle → constraints unsatisfiable → `labeling` fails → `studies/2` fails → prints `false` ✓

## walks.pl — Μετακινήσεις (not started)

Port of `../1st_exer/walks.cpp`. Count walks of length exactly T from (Γ,Σ) to (Γ',Σ')
on an N×M grid (N,M ≤ 100), 4-neighbor steps, avoiding obstacles. Cells may be revisited.
- Input file (see walks.cpp read_input): `N M T Γ Σ Γ' Σ'` on line 1 (1-indexed),
  then a line with obstacle count, then that many `row col` lines (1-indexed).
- DP: `f(0, start) = 1`; `f(t, cell) = Σ f(t-1, neighbor)`. Answer = `f(T, target)`.
- Prolog has native bigints, so no BigInt struct needed (unlike the C++).
- Predicate `walks("grid1.txt", W)` must give ONE solution. Use SWI tabling on f/3,
  OR iterative DP over the reachable-cell set (sparse, merge counts each step).
  Parity/distance pruning from walks.cpp is an optimization, not required for correctness.

## lights.py — Ηλεκτρολόγοι (not started)

Port of `../2nd_exer/lights.ml`. Lights Out on N×N grid (N ≤ 5). Pressing (i,j) toggles
itself + 4 orthogonal neighbors. Minimize presses to turn all off, else `IMPOSSIBLE`.
- Input: line 1 = `N`, then N lines of N integers (0/1).
- Algorithm (same as lights.ml): brute-force all 2^N first-row press patterns; each
  fixes the rest (press row i+1 wherever a light in row i is still on); check last row
  all-off; take the min press count over all patterns. `max_int` → IMPOSSIBLE.
