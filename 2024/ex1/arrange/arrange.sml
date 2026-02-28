datatype tree = Nil | Node of int * tree * tree

(* Input parse code by Stavros Aronis, modified by Nick Korasidis. *)
fun parse file =
    let
	(* A function to read an integer from specified input. *)
        fun readInt input = 
	    Option.valOf (TextIO.scanStream (Int.scan StringCvt.DEC) input)

	(* Open input file. *)
    	val inStream = TextIO.openIn file

        (* Read an integer (number of countries) and consume newline. *)
	val n = readInt inStream
	val _ = TextIO.inputLine inStream

	fun mkTree () =
    let
        val num = readInt inStream
    in
        if num = 0 then
            Nil
        else
            let
                val left = mkTree ()
                val right = mkTree ()
            in
                Node (num, left, right)
            end
    end
    in
   	(n, mkTree ())
    end

fun Arrange tree N =
    case tree of
        Nil => (N + 1, Nil)
      | Node (v, left, right) =>
        let
            val (l , Left) = Arrange left N
            val (r, Right) = Arrange right N
        in
            if (l > r andalso l <= N andalso r <= N) then (Int.min(r, v) , Node (v, Right, Left))
            else (if (l = (N+1) orelse r = (N+1)) then (
                if ((l <> (N+1) andalso v < l) orelse (r <> (N+1) andalso v > r)) then (Int.min(r, Int.min(l,v)), Node (v, Right, Left))
                else (Int.min(r, Int.min(l,v)), Node (v, Left, Right))
                )
                else (Int.min(r, Int.min(l,v)), Node (v, Left, Right))
            )
        end

fun printTree tree isFirst =
    case tree of
        Nil => ()
      | Node (v, left, right) =>
        (printTree left isFirst;
         if not (!isFirst) then
             print " "
         else
             isFirst := false;
         print (Int.toString v);
         printTree right isFirst)

fun solve (n, tree) =
    let
        val (_, tree') = Arrange tree n
        val isFirst = ref true
    in
        printTree tree' isFirst;
        print "\n"
    end

(* Parse and process the file, then solve the partition problem. *)
fun arrange fileName = solve (parse fileName)