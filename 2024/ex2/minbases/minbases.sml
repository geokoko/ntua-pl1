fun convert n x p =
    if x = 0 then p
    else convert n (x div n) ((x mod n) :: p);

fun is_equal [] = true
    | is_equal [x] = true
    | is_equal (x::y::xs) = (x = y) andalso is_equal (y::xs);

fun check_base n x = 
    if n = x + 1 then x + 1
    else if is_equal (convert n x []) then n
    else check_base (n + 1) x;

fun minbases l = List.map (check_base 2) l;