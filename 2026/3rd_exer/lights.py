import sys


def main():
    src = open(sys.argv[1]) if len(sys.argv) > 1 else sys.stdin
    toks = iter(src.read().split())
    nxt = lambda: int(next(toks))

    n = nxt()
    start = [0] * n                       # each row packed into a bitmask
    for i in range(n):
        for j in range(n):
            if nxt() == 1:
                start[i] |= 1 << j

    def press(a, i, j):
        a[i] ^= 1 << j
        if j > 0:
            a[i] ^= 1 << (j - 1)
        if j + 1 < n: 
            a[i] ^= 1 << (j + 1)
        if i > 0:
            a[i - 1] ^= 1 << j
        if i + 1 < n:
            a[i + 1] ^= 1 << j

    best = None
    for first in range(1 << n):     # every subset of row-0 presses
        a = start[:]
        cnt = 0
        for j in range(n):
            if first & (1 << j):
                press(a, 0, j)
                cnt += 1

        for i in range(1, n):   
            # each row forced by the one above
            above = a[i - 1]
            for j in range(n):
                if above & (1 << j):
                    press(a, i, j)
                    cnt += 1

        if a[n - 1] == 0 and (best is None or cnt < best):
            best = cnt

    # Output the result
    print("IMPOSSIBLE" if best is None else best)


main()
