let mingle lists =
    let rec aux current next acc =
        match current with
        | [] -> (
            match next with
            | [] -> List.rev acc
            | _ -> aux (List.rev next) [] acc)
        | [] :: rest -> aux rest next acc
        | [ x ] :: rest -> aux rest next (x :: acc)
        | (x :: xs) :: rest -> aux rest (xs :: next) (x :: acc)
    in
    aux lists [] []
