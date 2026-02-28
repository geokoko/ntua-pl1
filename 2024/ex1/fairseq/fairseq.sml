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

        (* A function to read N integers from the open file. *)
	fun readInts 0 acc = rev acc (* Replace with 'rev acc' for proper order. *)
	  | readInts i acc = readInts (i - 1) (readInt inStream :: acc)
    in
   	(n, readInts n [])
    end

(* This uses arrays
fun solve (n, S: int list) =
    let
        val total_sum = List.foldl (op +) 0 S
        val arr = Array.fromList S

        fun calcMinDiff (total_sum, arr, n) =
            let
                fun slide (current_sum, j) =
                    let
                        val updated_sum = current_sum + (if j >= n-1 then 0 else 2*Array.sub(arr, j+1))
                        val new_diff = abs(updated_sum - total_sum)
                        val old_diff = abs(current_sum - total_sum)
                    in
                        if j < n andalso old_diff > new_diff then slide (updated_sum, j + 1)
                        else (current_sum, j)
                    end

                fun loop (best, sum, i, j) =
                    if i >= n then best
                    else (let
                            val (new_sum, new_j) = slide (sum, j)
                            
                         in
                            loop (Int.min(best, abs(new_sum - total_sum)), new_sum - 2*Array.sub(arr, i) , i + 1, new_j)  
                         end)
                    
            in
                loop (abs(total_sum - 2*Array.sub(arr, 0)), 2*Array.sub(arr, 0), 0, 0)
            end
    in
        calcMinDiff (total_sum, arr, n)
    end
*)
(* Using Lists *)
fun solve (n, S: int list) =
    let
        val total_sum = List.foldl (op +) 0 S

        fun calcMinDiff (total_sum, S, n) =
            let
                fun slide (current_sum, j) =
                    let
                        val updated_sum = current_sum + (if j = [] orelse List.tl j = [] then 0 else 2*(List.hd (List.tl j)))
                        val new_diff = abs(updated_sum - total_sum)
                        val old_diff = abs(current_sum - total_sum)
                    in
                        if j = [] orelse old_diff <= new_diff then (current_sum, j)
                        else slide (updated_sum, List.tl j)
                    end

                fun loop (best , _, [], _) =  best
                |   loop (best, sum, i::is, j) =
                        (let
                            val (new_sum, new_j) = slide (sum, j)      
                         in
                            loop (Int.min(best, abs(new_sum - total_sum)), new_sum - 2*i , is, new_j)  
                         end)
                    
            in
                loop (abs(total_sum - 2*(List.hd S)), 2*(List.hd S), S, S)
            end
    in
       print((Int.toString (calcMinDiff (total_sum, S, n))) ^ "\n")
    end

(* Parse and process the file, then solve the partition problem. *)
fun fairseq fileName = solve (parse fileName)
