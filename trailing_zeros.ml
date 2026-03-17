let rec pow base exp =
    if exp = 0 then 1
    else base * pow base (exp - 1)

(* Harder version - numeric system base passed as parameter *)
let rec prime_factors (num: int) (factor: int) (acc: int list) : int list =
    if num = 1 then acc
    else if num % factor = 0 then prime_factors (num / factor) (factor) (acc @ [factor])
    else prime_factors (num) (factor + 1) (acc);;

let rec zeroes (num: int) (div: int) : int =
    if num = 0 then 0
    else (num / div) + zeroes (num / div);;

let rec trailing_zeroes (num: int) (base: int) : int =
    if num = 0 then 0
    else
        let rec count_and_process factors prev_prime count cur_zeros min_zeros =
            match factors with
            | [] -> min min_zeros (cur_zeros / count)
            | x :: rest when x = prev_prime ->
                count_and_process rest prev_prime (count + 1) cur_zeros min_zeros
            | x :: rest ->
                let cur_ans = zeroes num x in
                count_and_process rest x 1 cur_ans (min min_zeros (cur_zeros / count))
        in count_and_process (prime_factors base 2 []) 1 1 0 max_int

