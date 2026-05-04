let rec itermap f lst =
    match lst with
    | [] -> []
    | x :: rest -> x :: itermap f (List.map f rest);;

let f x = x + 1;;

let print_int_list lst =
    print_string "[";
    List.iter (fun x -> print_int x; print_string "; ") lst;
    print_string "]\n";;

let () =
    print_int_list (itermap f [0; 0; 0; 0]);
    print_int_list (itermap f [10; 10; 10; 10]);
    print_int_list (itermap f []);
    print_int_list (itermap f [42]);
    print_int_list (itermap f [0; 0]);
