let rec maxSumSublist lst =
    let rec helper lst acc maxSum =
        match lst with
        | [] -> max acc maxSum
        | x :: xs ->
            if acc + x > 0 then 
                helper xs (acc + x) maxSum
            else
                helper xs 0 (max acc maxSum)
    in
    helper lst 0 0

let lst = [1; -2; -3; -5; -1; -2; -1; -3; -4; -1];;
let result = maxSumSublist lst;;
Printf.printf "The maximum sum of a contiguous sublist is: %d\n" result;;

let lst2 = [-1; -2; -3; -4; -5];;
let result2 = maxSumSublist lst2;;
Printf.printf "The maximum sum of a contiguous sublist is: %d\n" result2;;

let lst3 = [1; 2; 3; 4; 5];;
let result3 = maxSumSublist lst3;;
Printf.printf "The maximum sum of a contiguous sublist is: %d\n" result3;;

let lst4 = [1; -2; 3; 4; -5; 6];;
let result4 = maxSumSublist lst4;;
Printf.printf "The maximum sum of a contiguous sublist is: %d\n" result4;;
