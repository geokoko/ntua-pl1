open Printf

let sumEven list =
    let (_, res) = List.fold_left (fun (i, res) x -> 
        if i mod 2 = 0 then (i+1, res+x) else (i+1, res)) (0, 0) list 
    in res;;

let rec sum_aux (lst: int list) (acc: int list) =
    match acc with
    | [] -> lst
    | y::ys -> 
        (match lst with
        | [] -> acc
        | x::xs -> (x + y)::sum_aux xs ys);;

let elemSum (init: int list list) =
    List.fold_left (fun acc x -> sum_aux x acc) [] init;;

(* Same length lists - basic case *)
List.iter (fun x -> print_int x; print_string " ") (elemSum [[1;2;3]; [4;5;6]; [7;8;9]]);;
print_newline ();;
(* Expected: 12 15 18 *)

(* Empty outer list *)
List.iter (fun x -> print_int x; print_string " ") (elemSum []);;
print_newline ();;
(* Expected: (empty) *)

(* Single inner list *)
List.iter (fun x -> print_int x; print_string " ") (elemSum [[1;2;3]]);;
print_newline ();;
(* Expected: 1 2 3 *)

(* Different length lists *)
List.iter (fun x -> print_int x; print_string " ") (elemSum [[1;2;3;4]; [10;20]]);;
print_newline ();;
(* Expected: 11 22 3 4 *)

(* One empty inner list *)
List.iter (fun x -> print_int x; print_string " ") (elemSum [[1;2;3]; []; [4;5;6]]);;
print_newline ();;
(* Expected: 5 7 9 *)

List.iter (fun x -> print_int x; print_string " ") (elemSum [[1;2;42;11]; [101;102]; [17]; []; [51;52;53;54;55]]);;
print_newline ();;
(* Expected: 170 156 95 65 55 *)
