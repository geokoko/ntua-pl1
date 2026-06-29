import heapq
import sys


def read_input(path):

    src = open(path) if path else sys.stdin
    toks = iter(src.read().split())
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


def topo_order(n, succ, indeg, cdeg):
    """Kahn's algorithm, but among the courses that are currently free to place
    pick the most conflict-constrained one first (MRV-style), so isolated/low-
    conflict courses are deferred to the end. Returns a topological order, or
    None if there's a cycle."""
    deg = indeg[:]
    heap = [(-cdeg[v], v) for v in range(1, n + 1) if deg[v] == 0]
    heapq.heapify(heap)
    order = []
    while heap:
        u = heapq.heappop(heap)[1]
        order.append(u)
        for w in succ[u]:
            deg[w] -= 1
            if deg[w] == 0:
                heapq.heappush(heap, (-cdeg[w], w))
    return order if len(order) == n else None


def longest_chain(n, pre, order):
    """Length (in courses) of the longest prerequisite chain."""
    chain = [0] * (n + 1)
    for v in order:                       # prereqs are processed before v
        chain[v] = 1 + max((chain[a] for a in pre[v]), default=0)
    return max(chain[1:], default=0)


def bits(mask):
    """Yield the set bit positions of mask (vertex ids)."""
    while mask:
        low = mask & -mask
        yield low.bit_length() - 1
        mask ^= low


def max_clique(n, conflict):
    """Largest set of pairwise-conflicting courses — a lower bound on semesters
    (a clique of size w forces w distinct semesters). Bron-Kerbosch with pivot;
    n <= 20 so this is microseconds."""
    adj = [0] * (n + 1)
    for c in range(1, n + 1):
        for d in conflict[c]:
            adj[c] |= 1 << d
    best = 0

    def expand(size, cand):
        nonlocal best
        if cand == 0:
            best = max(best, size)
            return
        if size + cand.bit_count() <= best:                 # can't beat best
            return
        pivot = max(bits(cand), key=lambda u: (cand & adj[u]).bit_count())
        for v in list(bits(cand & ~adj[pivot])):            # only non-neighbours of pivot
            expand(size + 1, cand & adj[v])
            cand &= ~(1 << v)

    expand(0, (1 << (n + 1)) - 2)                            # candidate = vertices 1..n
    return best


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
    reject a value already used by an *assigned* conflicting course, backtrack
    on failure
    """
    sem = [0] * (n + 1)        # sem[c] = assigned semester, 0 = unassigned
    count = [0] * (s + 1)      # count[v] = courses currently placed in semester v

    def assign(i):
        if i == n:
            return True
        c = order[i]
        lo = max((sem[a] for a in pre[c]), default=0) + 1   # strict prereq => +1
        for v in range(lo, s + 1):
            if count[v] == k:                               # semester full
                continue
            if any(sem[d] == v for d in conflict[c]):        # clashes an assigned course
                continue
            sem[c] = v
            count[v] += 1
            if assign(i + 1):
                return True
            sem[c] = 0                                       # undo (backtrack)
            count[v] -= 1
        return False

    return assign(0)


def solve(path):
    n, k, pre, succ, indeg, conflict = read_input(path)
    if any(c in conflict[c] for c in range(1, n + 1)):   # a course conflicts with itself
        return "IMPOSSIBLE"
    cdeg = [len(conflict[c]) for c in range(n + 1)]      # conflict degree per course
    order = topo_order(n, succ, indeg, cdeg)
    if order is None:
        return "IMPOSSIBLE"

    # lower bound: capacity floor, longest prereq chain, largest conflict clique
    lo = max(-(-n // k), longest_chain(n, pre, order), max_clique(n, conflict))
    for s in range(lo, n + 1):
        if feasible(s, n, k, order, pre, conflict):
            return str(s)
    return str(n)   # S = n is always feasible when acyclic


if __name__ == "__main__":
    sys.setrecursionlimit(10000)
    print(solve(sys.argv[1] if len(sys.argv) > 1 else None))
