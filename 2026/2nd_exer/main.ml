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

let daily_choice day mountain sea =
    if mountain < sea then (1, mountain)
    else if mountain > sea then (-1, sea)
    else if day mod 2 = 1 then (1, mountain)
    else (-1, sea)

let () =
    let n = next_int () in
    let offset = n in
    let size = (2 * n) + 1 in

    let seen = Array.make size 0L in
    let first_pos = Array.make size (-1) in
    let first_cost = Array.make size 0L in

    let balance = ref 0 in
    let sum_cost = ref 0L in
    let total = ref 0L in
    let best_len = ref 0 in
    let best_cost = ref Int64.max_int in

    (* same balance twice => valid interval between them *)
    seen.(offset) <- 1L;
    first_pos.(offset) <- 0;

    for day = 1 to n do
        let mountain = next_int () in
        let sea = next_int () in
        let value, price = daily_choice day mountain sea in

        balance := !balance + value;
        sum_cost := Int64.add !sum_cost (Int64.of_int price);

        let id = !balance + offset in
        total := Int64.add !total seen.(id);

        if first_pos.(id) = -1 then (
            first_pos.(id) <- day;
            first_cost.(id) <- !sum_cost
        ) else (
            let len = day - first_pos.(id) in
            let cost = Int64.sub !sum_cost first_cost.(id) in

            if len > !best_len then (
                best_len := len;
                best_cost := cost
            ) else if len = !best_len && len > 0 && cost < !best_cost then
                best_cost := cost
        );

        seen.(id) <- Int64.succ seen.(id)
    done;

    if !total = 0L then
        print_endline "0 0 0"
    else
        Printf.printf "%Ld %d %Ld\n" !total !best_len !best_cost
