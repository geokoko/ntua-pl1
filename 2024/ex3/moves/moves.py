import sys
from collections import deque

class Cell:
    def __init__ (self, x, y, cost, parent):
        self.x = x
        self.y = y
        self.cost = cost
        self.parent = parent

def out_of_bounds(x, y, n):
        return x < 0 or y < 0 or x >= n or y >= n
    
def is_allowed(source, target):
        return source.cost > target.cost
    
def shortest_path (grid, n):
    dRow = [-1, 1, 0, 0, -1, -1, 1, 1]
    dCol = [0, 0, -1, 1, -1, 1, -1, 1]
    directions = ["N", "S", "W", "E", "NW", "NE", "SW", "SE"]

    frontier = deque()
    visited = [[False for _ in range(n)] for _ in range(n)]
    end_cell = None

    frontier.append(Cell(0, 0, grid[0][0], None))

    while frontier:
          current = frontier.popleft()
          if current.x == n-1 and current.y == n-1:
                end_cell = current
                break
          visited[current.x][current.y] = True

          # explore neighbors
          for i in range(8):
                new_row = current.x + dRow[i]
                new_col = current.y + dCol[i]

                if not out_of_bounds(new_row, new_col, n) and not visited[new_row][new_col]:
                      if is_allowed(current, Cell(new_row, new_col, grid[new_row][new_col], None)):
                        frontier.append(Cell(new_row, new_col, grid[new_row][new_col], current))
                        visited[new_row][new_col] = True

    if end_cell:
          print_path(end_cell, directions, dRow, dCol)
    else:
          print("IMPOSSIBLE")

def print_path (end_cell, directions, dRow, dCol):
    path = []
    directions_list = []
    cur = end_cell

    while cur:
        path.append(cur)
        cur = cur.parent

    for i in range(len(path) - 1, 0, -1):
        from_cell = path[i]
        to_cell = path[i - 1]
        dx = to_cell.x - from_cell.x
        dy = to_cell.y - from_cell.y
        for j in range(8):
            if dRow[j] == dx and dCol[j] == dy:
                directions_list.append(directions[j])
                break

    print("[", end="")
    for index, direction in enumerate(directions_list):
        if index == len(directions_list) - 1:
            print(direction, end="")
        else:
            print(f"{direction},", end="")
    print("]")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python moves.py <input_file>")
        sys.exit(1)

    file_name = sys.argv[1]

    try:
        with open(file_name, 'r') as f:
            n = int(f.readline().strip())
            grid = []
            for _ in range(n):
                line = f.readline().strip().split()
                grid.append([int(x) for x in line])

        shortest_path(grid, n)
    except IOError as e:
        print(f"Error reading input file: {e}")
    except ValueError as e:
        print(f"Invalid number format in input file: {e}")
                      