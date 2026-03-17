let rec pow (base: Z.t) (exp: Z.t) : Z.t =
    if Z.equal exp Z.zero then Z.one
    else Z.mul base (pow base (Z.sub exp Z.one))

(* Adding some optimizations here :
   1. Look for prime factors of n up to sqrt n (classic)
   2. @ appends to the end of the list by copying the whole list O(n). Use : (prepend in O(1)). Produces a reversed list (factors in descending order) but it doesnt affect correctness.
*)
let rec prime_factors (num: Z.t) (factor: Z.t) (acc: Z.t list) : Z.t list =
    if Z.equal num Z.one then acc
    else if Z.gt (Z.mul factor factor) num then num :: acc
    else if Z.equal (Z.rem num factor) Z.zero then
        prime_factors (Z.div num factor) factor (factor :: acc)
    else prime_factors num (Z.add factor Z.one) acc

let rec zeroes (num: Z.t) (div: Z.t) : Z.t =
    if Z.equal num Z.zero then Z.zero
    else Z.add (Z.div num div) (zeroes (Z.div num div) div)

let trailing_zeroes (num: Z.t) (base: Z.t) : Z.t =
    if Z.equal num Z.zero then Z.zero
    else
        let rec count_and_process factors prev_prime count cur_zeros min_zeros =
            match factors with
            | [] -> Z.min min_zeros (Z.div cur_zeros count)
            | x :: rest when Z.equal x prev_prime ->
                count_and_process rest prev_prime (Z.add count Z.one) cur_zeros min_zeros
            | x :: rest ->
                let cur_ans = zeroes num x in
                count_and_process rest x Z.one cur_ans (Z.min min_zeros (Z.div cur_zeros count))
        in
        let factors = prime_factors base (Z.of_int 2) [] in
        match factors with
        | [] -> Z.zero  (* base = 1 edge case *)
        | first :: rest ->
            let first_zeros = zeroes num first in
            count_and_process rest first Z.one first_zeros first_zeros
