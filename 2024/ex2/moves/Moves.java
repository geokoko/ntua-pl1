import java.util.*;
import java.io.*;

class Cell implements Comparable<Cell> {
    int x, y, cost;
    Cell parent;

    Cell(int x, int y, int cost, Cell parent) {
        this.x = x;
        this.y = y;
        this.cost = cost;
        this.parent = parent;
    }

    @Override
    public int compareTo(Cell o) {
        return this.cost - o.cost;
    }
}

public class Moves {
    private static final int[] dRow = { -1, 1, 0, 0, -1, -1, 1, 1 };
    private static final int[] dCol = { 0, 0, -1, 1, -1, 1, -1, 1 };
    private static final String[] directions = { "N", "S", "W", "E", "NW", "NE", "SW", "SE" };

    public static boolean out_of_bounds(int x, int y, int n) {
        if (x < 0 || x >= n || y < 0 || y >= n) {
            return true;
        }
        return false;
    }

    public static boolean isAllowed(Cell source, Cell target) {
        if (source.cost > target.cost) {
            return true;
        }
        return false;
    }

    public static void shortest_path(int[][] grid, int n) {
        Queue<Cell> frontier = new LinkedList<>(); // search frontier
        boolean[][] visited = new boolean[n][n]; // closed set
        Cell endCell = null;

        frontier.add(new Cell(0, 0, grid[0][0], null));

        while (!frontier.isEmpty()) {
            Cell current = frontier.poll();
            if (current.x == n - 1 && current.y == n - 1) {
                endCell = current;
                break;
            }
            visited[current.x][current.y] = true;

            for (int i = 0; i < 8; i++) {
                int newRow = current.x + dRow[i];
                int newCol = current.y + dCol[i];

                if (!out_of_bounds(newRow, newCol, n) && !visited[newRow][newCol]) {
                    if (grid[newRow][newCol] < current.cost) /* if we are allowed to travel to this node */ {
                        frontier.add(new Cell(newRow, newCol, grid[newRow][newCol], current)); // add to search frontier
                        visited[newRow][newCol] = true; // mark as visited
                    }
                }
            }
        }

        if (endCell != null) {
            printPath(endCell);
        }

        else {
            System.out.println("IMPOSSIBLE");
        }

    }

    public static void printPath(Cell endCell) {
        List<Cell> path = new ArrayList<>();
        List<String> directionsList = new ArrayList<>();
        Cell cur = endCell;

        while (cur != null) {
            path.add(cur);
            cur = cur.parent;
        } // save the path by backtracking from end to start

        for (int i = path.size() - 1; i > 0; --i) {
            Cell from = path.get(i);
            Cell to = path.get(i - 1);
            int dx = to.x - from.x;
            int dy = to.y - from.y;
            for (int j = 0; j < 8; ++j) {
                if (dRow[j] == dx && dCol[j] == dy) {
                    directionsList.add(Moves.directions[j]);
                    break;
                }
            }
        }

        System.out.print("[");
        int index = 0;

        for (String str : directionsList) {
            if (index == directionsList.size() - 1)
                System.out.print(str);
            else
                System.out.print(str + ", ");
            
            index++;
        }

        System.out.print("]");

        System.out.println();
    }

    public static void main(String[] args) {
        if (args.length != 1) {
            System.out.println("Usage: java Moves <input_file>");
            return;
        }

        String fileName = args[0];
        try {
            BufferedReader reader = new BufferedReader(new FileReader(fileName));
            String line = reader.readLine();

            int n = Integer.parseInt(line.trim());
            int[][] grid = new int[n][n];

            for (int i = 0; i < n; i++) {
                line = reader.readLine();
                String[] parts = line.split("\\s+");
                for (int j = 0; j < parts.length; j++) {
                    grid[i][j] = Integer.parseInt(parts[j]);
                }
            }

            reader.close();

            shortest_path(grid, n);
        } catch (IOException e) {
            System.err.println("Error reading input file: " + e.getMessage());
        } catch (NumberFormatException e) {
            System.err.println("Invalid number format in input file: " + e.getMessage());
        }
    }

}
