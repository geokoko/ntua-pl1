val directions = [(1, 0, "S"), (~1, 0, "N"), (0, 1, "E"), (0, ~1, "W"), (1, 1, "SE"), (1, ~1, "SW"), (~1, 1, "NE"), (~1, ~1, "NW")]

fun is_valid_move N grid visited (row, col) cur_weight =
    row >= 0 andalso row < N andalso col >= 0 andalso col < N andalso (not (Array.sub(visited, row * N + col))) andalso 
    (Array.sub(grid, row * N + col) < cur_weight) (* constraints for making a move valid *)

fun bfs N grid = 
    let
        val visited = Array.array(N * N, false)
        val queue = Queue.mkQueue()
        val _ = Queue.enqueue(queue, (0, 0, []))
        val _ = Array.update(visited, 0, true)

        fun bfs_help N grid visited queue =
            if Queue.isEmpty(queue) then ["IMPOSSIBLE"]
            else
                let
                    val (row, col, path) = Queue.dequeue(queue)
                    val _ = Array.update(visited, row * N + col, true)
                    val current_weight = Array.sub(grid, row * N + col)
                    val neighbors = List.filter (fn (dx, dy, dir) => is_valid_move N grid visited (row + dx, col + dy) current_weight) directions
                    
                    val _ = List.app (fn (dx, dy, dir) => 
                                let
                                    val new_row = row + dx
                                    val new_col = col + dy
                                    val new_path = path @ [dir]
                                    val _ = Queue.enqueue(queue, (new_row, new_col, new_path))
                                in
                                    ()
                                end) neighbors
                    val goal = (N-1, N-1)
                in
                    if (row, col) = goal then path
                    else bfs_help N grid visited queue
                end
    in
        bfs_help N grid visited queue
    end

(* Function to read grid from a file *)
fun read_grid filename = 
    let
        val ins = TextIO.openIn filename
        val size = 
            case TextIO.inputLine ins of
                SOME line => (case Int.fromString line of
                                 SOME n => n
                               | NONE => raise Fail "Invalid grid size")
              | NONE => raise Fail "Failed to read grid size"
        val grid = Array.array(size * size, 0)
        fun read_row idx =
            if idx < size then
                let
                    val line = TextIO.inputLine ins
                    val _ = case line of
                              SOME l => let
                                          val nums = String.tokens (fn c => c = #" ") l
                                          val _ = List.appi (fn (i, n) => 
                                              case Int.fromString n of
                                                  SOME num => Array.update(grid, idx * size + i, num)
                                                | NONE => raise Fail "Invalid grid weight") nums
                                        in () end
                            | NONE => raise Fail "Failed to read grid row"
                in
                    read_row (idx + 1)
                end
            else
                ()
    in
        read_row 0;
        TextIO.closeIn ins;
        (size, grid)
    end

(* Function to convert a list to a string *)
fun list_to_string lst =
    let
        fun aux [] = ""
          | aux [x] = x
          | aux (x::xs) = x ^ "," ^ aux xs
    in
        "[" ^ aux lst ^ "]"
    end

(* Main function *)
fun moves filename =
    let
        val (N, grid) = read_grid filename
        val result = bfs N grid
    in
        if result = ["IMPOSSIBLE"] then
            print "IMPOSSIBLE\n"
        else
            print (list_to_string result ^ "\n")
    end