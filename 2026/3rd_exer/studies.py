# Στρατηγική Σπουδών — minimum number of semesters.
#
# Input file:
#   N M K
#   M lines: "a b"  (course a is a prerequisite of b, so sem[a] < sem[b])
#   C
#   C lines: "x y"  (x and y cannot share a semester)
#
# Output: minimum max-semester used, or IMPOSSIBLE if prerequisites are cyclic.

import sys


def read_input(path):
    with open(path) as f:
        toks = iter(f.read().split())
    nxt = lambda: int(next(toks))

    n, m, k = nxt(), nxt(), nxt()
    pre = [[] for _ in range(n + 1)]    # pre[b] = courses that must come before b
    succ = [[] for _ in range(n + 1)]   # succ[a] = courses a unlocks (for topo sort)
    indeg = [0] * (n + 1)
    for _ in range(m):
        a, b = nxt(), nxt()
        pre[b].append(a)
        succ[a].append(b)
        indeg[b] += 1

    conflict = [set() for _ in range(n + 1)]
    for _ in range(nxt()):
        x, y = nxt(), nxt()
        conflict[x].add(y)
        conflict[y].add(x)

    return n, k, pre, succ, indeg, conflict


def topo_order(n, succ, indeg):
    """Kahn's algorithm. Returns a topological order, or None if there's a cycle."""
    deg = indeg[:]
    stack = [v for v in range(1, n + 1) if deg[v] == 0]
    order = []
    while stack:
        u = stack.pop()
        order.append(u)
        for w in succ[u]:
            deg[w] -= 1
            if deg[w] == 0:
                stack.append(w)
    return order if len(order) == n else None


def longest_chain(n, pre, order):
    """Length (in courses) of the longest prerequisite chain."""
    chain = [0] * (n + 1)
    for v in order:                       # prereqs are processed before v
        chain[v] = 1 + max((chain[a] for a in pre[v]), default=0)
    return max(chain[1:], default=0)


def feasible(s, n, k, order, pre, conflict):
    """
    Can every course be assigned a semester in 1..s such that:
      - sem[a] < sem[b]   for every prerequisite a -> b   (strict),
      - sem[x] != sem[y]  for every conflict pair,
      - at most k courses share any one semester?
    Return True/False.

    Strategy hint: assign courses in `order` (topological), so a course's
    prerequisites already have semesters when you reach it. For each course,
    its semester must be at least max(sem of its prereqs) + 1. Try each legal
    value, track how many courses sit in each semester (the capacity limit),
    reject a value already used by an *assigned* conflicting course, recurse,
    and undo (backtrack) on failure.
    """
    sem = [0] * (n + 1)        # sem[c] = assigned semester, 0 = unassigned
    count = [0] * (s + 1)      # count[v] = courses currently placed in semester v

    # TODO(human): write the backtracking recursion that fills `sem`.
    # Suggested shape:
    #   def assign(i):                      # i = index into `order`
    #       if i == len(order): return True
    #       c = order[i]
    #       lo = max((sem[a] for a in pre[c]), default=0) + 1
    #       for v in range(lo, s + 1):
    #           ... check capacity and conflicts, place c, recurse, undo ...
    #       return False
    #   return assign(0)
    raise NotImplementedError("feasible() — your turn")


def solve(path):
    n, k, pre, succ, indeg, conflict = read_input(path)
    order = topo_order(n, succ, indeg)
    if order is None:
        return "IMPOSSIBLE"

    lo = max(-(-n // k), longest_chain(n, pre, order))   # ceil(n/k) vs longest chain
    for s in range(lo, n + 1):
        if feasible(s, n, k, order, pre, conflict):
            return str(s)
    return str(n)   # S = n is always feasible when acyclic


if __name__ == "__main__":
    sys.setrecursionlimit(10000)
    print(solve(sys.argv[1]))
