let rec gcd a b = if b = 0 then a else gcd b (a mod b)

let rec an (n: int): int list =
    let rec aux n = if n = 1 then 7 else aux (n-1) + gcd n (aux (n-1)) in 
    match n with
    | 1 -> [7] 
    | _ -> an (n-1) @ [aux n];; (* :: requires the right side to be a list. Using @ -> concatenate with a single element list *)

let rec gn (n: int): int list = 
    let rec aux n = if n = 1 then 7 else aux (n-1) + gcd n (aux (n-1)) in  
    match n with
    | 1 -> [1]
    | _ -> gn (n-1) @ [aux n];;

let count_ones(n: int): int = 
    let rec count_ones_aux lst =
        match lst with
        | [] -> 0
        | x::xs -> if x = 1 then 1 + count_ones_aux xs else count_ones_aux xs
    in count_ones_aux gn n;;



let max_pn(n: int): int = 0
    (* your code *);;

let an_over_average (n: int): int = 0
        (* your code *);;
