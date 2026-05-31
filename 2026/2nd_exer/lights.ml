let ic =
    if Array.length Sys.argv > 1 then open_in Sys.argv.(1) else stdin

let buffer = Bytes.create (1 lsl 16)
let len = ref 0
let pos = ref 0

let refill () =
    len := input ic buffer 0 (Bytes.length buffer);
    pos := 0

let read () =
    if !pos = !len then refill ();
    if !len = 0 then -1
    else
        let c = Char.code (Bytes.get buffer !pos) in
        incr pos;
        c

let next_int () =
    let c = ref (read ()) in
    while !c >= 0 && !c <= Char.code ' ' do
        c := read ()
    done;
    let value = ref 0 in
    while !c > Char.code ' ' do
        value := (10 * !value) + (!c - Char.code '0');
        c := read ()
    done;
    !value

let press a n i j =
    let bit = 1 lsl j in
    a.(i) <- a.(i) lxor bit;
    if j > 0 then a.(i) <- a.(i) lxor (1 lsl (j - 1));
    if j + 1 < n then a.(i) <- a.(i) lxor (1 lsl (j + 1));
    if i > 0 then a.(i - 1) <- a.(i - 1) lxor bit;
    if i + 1 < n then a.(i + 1) <- a.(i + 1) lxor bit

let () =
    let n = next_int () in
    let start = Array.make n 0 in

    for i = 0 to n - 1 do
        for j = 0 to n - 1 do
            if next_int () = 1 then start.(i) <- start.(i) lor (1 lsl j)
        done
    done;

    let best = ref max_int in

    (* try every possible first row *)
    for first = 0 to (1 lsl n) - 1 do
        let a = Array.copy start in
        let cnt = ref 0 in

        for j = 0 to n - 1 do
            if first land (1 lsl j) <> 0 then (
                press a n 0 j;
                incr cnt
            )
        done;

        for i = 1 to n - 1 do
            let above = a.(i - 1) in
            for j = 0 to n - 1 do
                if above land (1 lsl j) <> 0 then (
                    press a n i j;
                    incr cnt
                )
            done
        done;

        if a.(n - 1) = 0 && !cnt < !best then best := !cnt
    done;

    if !best = max_int then
        print_endline "IMPOSSIBLE"
    else
        Printf.printf "%d\n" !best
