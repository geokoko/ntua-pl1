import sys

def fairseq(array):
    total = sum(array)
    best = float('inf')
    i = 0
    j = 0
    s = 0
    while j < len(array) and i < len(array):
        s += array[j]
        j += 1
        curr_diff = abs(total - 2 * s)

        if curr_diff < best:
            best = curr_diff
        
        while i < j and (2 * s - total) >= 0:
            s -= array[i]
            i += 1
            curr_diff = abs(total - 2 * s)
            if curr_diff < best:
                best = curr_diff

        if best == 0:
            break

    return best

with open(sys.argv[1], 'r') as f:
    N = int(f.readline().strip())
    S = list(map(int, f.readline().strip().split()))
    f.close()

print(fairseq(S))