fun readAllInput () =
  case CommandLine.arguments () of
       [filename] =>
       let
         val input = TextIO.openIn filename
         val text = TextIO.inputAll input
         val () = TextIO.closeIn input
       in
         text
       end
     | _ => TextIO.inputAll TextIO.stdIn

fun parseInts text =
let
  fun parse token =
    case IntInf.fromString token of
         SOME value => value
       | NONE => raise Fail "could not parse integer"
in
  List.map parse (String.tokens Char.isSpace text)
end

fun asInt value = IntInf.toInt value

fun cellId cols row col = row * cols + col

fun markObstacles _ _ 0 rest = rest
  | markObstacles cols blocked count (row :: col :: rest) =
    let
      val cell = cellId cols (asInt row - 1) (asInt col - 1)
      val () = Array.update (blocked, cell, true)
    in
      markObstacles cols blocked (count - 1) rest
    end
  | markObstacles _ _ _ _ = raise Fail "bad obstacle list"

fun buildNodes rows cols blocked =
let
  val total = rows * cols
  val cellToNode = Array.array (total, ~1)

  fun loop cell count cells =
    if cell = total then
      (cellToNode, Array.fromList (List.rev cells))
    else if Array.sub (blocked, cell) then
      loop (cell + 1) count cells
    else
      let
        val () = Array.update (cellToNode, cell, count)
      in
        loop (cell + 1) (count + 1) (cell :: cells)
      end
in
  loop 0 0 []
end

fun buildNeighbors rows cols cellToNode nodeToCell =
let
  val directions = [(~1, 0), (1, 0), (0, ~1), (0, 1)]

  fun inside row col =
    row >= 0 andalso row < rows andalso col >= 0 andalso col < cols

  fun neighborsOf node =
  let
    val cell = Array.sub (nodeToCell, node)
    val row = cell div cols
    val col = cell mod cols

    fun add ((dr, dc), acc) =
    let
      val nr = row + dr
      val nc = col + dc
    in
      if inside nr nc then
        let
          val nextNode = Array.sub (cellToNode, cellId cols nr nc)
        in
          if nextNode = ~1 then acc else nextNode :: acc
        end
      else
        acc
    end
  in
    Array.fromList (List.foldl add [] directions)
  end
in
  Array.tabulate (Array.length nodeToCell, neighborsOf)
end

fun bfsDistances source neighbors =
let
  val nodes = Array.length neighbors
  val dist = Array.array (nodes, ~1)
  val queue = Array.array (nodes, 0)
  val head = ref 0
  val tail = ref 0

  fun push node =
    (Array.update (queue, !tail, node); tail := !tail + 1)

  val () = Array.update (dist, source, 0)
  val () = push source

  fun visit from node =
    if Array.sub (dist, node) = ~1 then
      (Array.update (dist, node, Array.sub (dist, from) + 1); push node)
    else
      ()

  fun loop () =
    if !head = !tail then
      dist
    else
      let
        val node = Array.sub (queue, !head)
        val () = head := !head + 1
        val nextNodes = Array.sub (neighbors, node)

        fun visitAll i =
          if i = Array.length nextNodes then
            ()
          else
            (visit node (Array.sub (nextNodes, i)); visitAll (i + 1))
      in
        visitAll 0;
        loop ()
      end
in
  loop ()
end

fun countWalks start target steps neighbors distToTarget =
let
  val nodes = Array.length neighbors
  val zero : IntInf.int = 0
  val current = Array.array (nodes, zero)
  val next = Array.array (nodes, zero)
  val active = Array.array (nodes, 0)
  val nextActive = Array.array (nodes, 0)
  val activeCount = ref 1

  val () = Array.update (current, start, 1)
  val () = Array.update (active, 0, start)

  fun writeNext ways node nextCount =
    if Array.sub (next, node) = zero then
      (Array.update (nextActive, !nextCount, node);
       nextCount := !nextCount + 1;
       Array.update (next, node, ways))
    else
      Array.update (next, node, Array.sub (next, node) + ways)

  fun processNeighbors ways nextNodes remainingAfterMove nextCount i =
    if i = Array.length nextNodes then
      ()
    else
      let
        val node = Array.sub (nextNodes, i)
        val targetDist = Array.sub (distToTarget, node)
      in
        if targetDist >= 0 andalso targetDist <= remainingAfterMove andalso
           (remainingAfterMove - targetDist) mod 2 = 0 then
          writeNext ways node nextCount
        else
          ();
        processNeighbors ways nextNodes remainingAfterMove nextCount (i + 1)
      end

  fun processActive remainingAfterMove nextCount i =
    if i = !activeCount then
      ()
    else
      let
        val node = Array.sub (active, i)
        val ways = Array.sub (current, node)
        val nextNodes = Array.sub (neighbors, node)
      in
        processNeighbors ways nextNodes remainingAfterMove nextCount 0;
        processActive remainingAfterMove nextCount (i + 1)
      end

  fun clearCurrent i =
    if i = !activeCount then
      ()
    else
      let
        val node = Array.sub (active, i)
      in
        Array.update (current, node, zero);
        clearCurrent (i + 1)
      end

  fun moveNext nextCount i =
    if i = !nextCount then
      ()
    else
      let
        val node = Array.sub (nextActive, i)
        val value = Array.sub (next, node)
      in
        Array.update (current, node, value);
        Array.update (next, node, zero);
        Array.update (active, i, node);
        moveNext nextCount (i + 1)
      end

  fun loop step =
    if step = steps orelse !activeCount = 0 then
      ()
    else
      let
        val remainingAfterMove = steps - step - 1
        val nextCount = ref 0
      in
        processActive remainingAfterMove nextCount 0;
        clearCurrent 0;
        moveNext nextCount 0;
        activeCount := !nextCount;
        loop (step + 1)
      end
in
  loop 0;
  Array.sub (current, target)
end

fun solve ints =
  case ints of
       rows0 :: cols0 :: steps0 :: sr0 :: sc0 :: tr0 :: tc0 :: obstacleCount0 :: rest =>
       let
         val rows = asInt rows0
         val cols = asInt cols0
         val steps = asInt steps0
         val obstacleCount = asInt obstacleCount0
         val total = rows * cols
         val blocked = Array.array (total, false)
         val _ = markObstacles cols blocked obstacleCount rest
         val startRow = asInt sr0 - 1
         val startCol = asInt sc0 - 1
         val targetRow = asInt tr0 - 1
         val targetCol = asInt tc0 - 1
         val startCell = cellId cols startRow startCol
         val targetCell = cellId cols targetRow targetCol
       in
         if Array.sub (blocked, startCell) orelse Array.sub (blocked, targetCell) then
           0
         else
           let
             val (cellToNode, nodeToCell) = buildNodes rows cols blocked
             val neighbors = buildNeighbors rows cols cellToNode nodeToCell
             val start = Array.sub (cellToNode, startCell)
             val target = Array.sub (cellToNode, targetCell)
             val distToTarget = bfsDistances target neighbors
             val dist = Array.sub (distToTarget, start)
           in
             if dist < 0 orelse dist > steps orelse (steps - dist) mod 2 <> 0 then
               0
             else
               countWalks start target steps neighbors distToTarget
           end
       end
     | _ => raise Fail "bad input"

val () =
let
  val answer = solve (parseInts (readAllInput ()))
in
  TextIO.output (TextIO.stdOut, IntInf.toString answer);
  TextIO.output (TextIO.stdOut, "\n")
end
