(* Exercise 1 (Telecom Cables) — maximum-product partition of n.
   AM-GM: split into mostly 3s.
   Hand-rolled big integers (base 10000, little-endian limbs in an int array).
   Squaring: schoolbook for small, two-modulus NTT + CRT otherwise.
   No external packages — OCaml stdlib only.
   Build:  ocamlopt -O3 maxprod_amgm.ml -o maxprod
   Run:    ./maxprod input.txt *)

let base = 10000
let base_digits = 4
let schoolbook_limit = 64
let mod1 = 998244353
let mod2 = 1004535809
let prim_root = 3

let mod_pow b e m =
  let r = ref 1 in
  let b = ref (((b mod m) + m) mod m) in
  let e = ref e in
  while !e > 0 do
    if !e land 1 = 1 then r := !r * !b mod m;
    b := !b * !b mod m;
    e := !e lsr 1
  done;
  !r

(* In-place NTT modulo m. Length of [a] must be a power of two. *)
let ntt a invert m =
  let n = Array.length a in
  let j = ref 0 in
  for i = 1 to n - 1 do
    let bit = ref (n lsr 1) in
    while !j land !bit <> 0 do
      j := !j lxor !bit;
      bit := !bit lsr 1
    done;
    j := !j lxor !bit;
    if i < !j then begin
      let t = a.(i) in
      a.(i) <- a.(!j);
      a.(!j) <- t
    end
  done;
  let len = ref 2 in
  while !len <= n do
    let wlen0 = mod_pow prim_root ((m - 1) / !len) m in
    let wlen = if invert then mod_pow wlen0 (m - 2) m else wlen0 in
    let i = ref 0 in
    while !i < n do
      let w = ref 1 in
      let half = !len lsr 1 in
      let base_i = !i in
      for k = 0 to half - 1 do
        let u = a.(base_i + k) in
        let v = !w * a.(base_i + k + half) mod m in
        let x = u + v in
        let x = if x >= m then x - m else x in
        let y = u - v in
        let y = if y < 0 then y + m else y in
        a.(base_i + k) <- x;
        a.(base_i + k + half) <- y;
        w := !w * wlen mod m
      done;
      i := !i + !len
    done;
    len := !len lsl 1
  done;
  if invert then begin
    let inv_n = mod_pow n (m - 2) m in
    for i = 0 to n - 1 do
      a.(i) <- a.(i) * inv_n mod m
    done
  end

type bigint = {
  mutable digits : int array;
  mutable len : int;
}

let make_bigint v =
  if v = 0 then { digits = [| 0 |]; len = 1 }
  else begin
    let buf = ref (Array.make 4 0) in
    let i = ref 0 in
    let v = ref v in
    while !v > 0 do
      if !i >= Array.length !buf then begin
        let nb = Array.make (Array.length !buf * 2) 0 in
        Array.blit !buf 0 nb 0 (Array.length !buf);
        buf := nb
      end;
      (!buf).(!i) <- !v mod base;
      v := !v / base;
      incr i
    done;
    { digits = !buf; len = !i }
  end

let trim x =
  while x.len > 1 && x.digits.(x.len - 1) = 0 do
    x.len <- x.len - 1
  done

let ensure_capacity x cap =
  if Array.length x.digits < cap then begin
    let new_cap = max cap (Array.length x.digits * 2) in
    let nb = Array.make new_cap 0 in
    Array.blit x.digits 0 nb 0 x.len;
    x.digits <- nb
  end

let multiply_small x mult =
  let carry = ref 0 in
  for i = 0 to x.len - 1 do
    let cur = x.digits.(i) * mult + !carry in
    x.digits.(i) <- cur mod base;
    carry := cur / base
  done;
  while !carry > 0 do
    ensure_capacity x (x.len + 1);
    x.digits.(x.len) <- !carry mod base;
    x.len <- x.len + 1;
    carry := !carry / base
  done;
  trim x

let assign_with_carry x raw =
  let raw_len = Array.length raw in
  ensure_capacity x raw_len;
  let carry = ref 0 in
  for i = 0 to raw_len - 1 do
    let cur = raw.(i) + !carry in
    x.digits.(i) <- cur mod base;
    carry := cur / base
  done;
  x.len <- raw_len;
  while !carry > 0 do
    ensure_capacity x (x.len + 1);
    x.digits.(x.len) <- !carry mod base;
    x.len <- x.len + 1;
    carry := !carry / base
  done;
  trim x

let schoolbook_square x =
  let n = x.len in
  let raw = Array.make (2 * n - 1) 0 in
  let d = x.digits in
  for i = 0 to n - 1 do
    raw.(2 * i) <- raw.(2 * i) + d.(i) * d.(i);
    let di = d.(i) in
    for j = i + 1 to n - 1 do
      raw.(i + j) <- raw.(i + j) + 2 * di * d.(j)
    done
  done;
  assign_with_carry x raw

let ntt_square x =
  let needed = 2 * x.len - 1 in
  let nsz = ref 1 in
  while !nsz < needed do nsz := !nsz lsl 1 done;
  let nsz = !nsz in

  let r1 = Array.make nsz 0 in
  Array.blit x.digits 0 r1 0 x.len;
  ntt r1 false mod1;
  for i = 0 to nsz - 1 do r1.(i) <- r1.(i) * r1.(i) mod mod1 done;
  ntt r1 true mod1;

  let r2 = Array.make nsz 0 in
  Array.blit x.digits 0 r2 0 x.len;
  ntt r2 false mod2;
  for i = 0 to nsz - 1 do r2.(i) <- r2.(i) * r2.(i) mod mod2 done;
  ntt r2 true mod2;

  let inv_m1_m2 = mod_pow mod1 (mod2 - 2) mod2 in
  let raw = Array.make needed 0 in
  for i = 0 to needed - 1 do
    let diff = r2.(i) - r1.(i) in
    let diff = if diff < 0 then diff + mod2 else diff in
    let factor = diff * inv_m1_m2 mod mod2 in
    raw.(i) <- r1.(i) + mod1 * factor
  done;
  assign_with_carry x raw

let square x =
  if x.len <= schoolbook_limit then schoolbook_square x
  else ntt_square x

let rec pow3 e =
  if e = 0 then make_bigint 1
  else begin
    let r = pow3 (e / 2) in
    square r;
    if e land 1 = 1 then multiply_small r 3;
    r
  end

let bigint_to_string x =
  let buf = Buffer.create (x.len * base_digits) in
  Buffer.add_string buf (string_of_int x.digits.(x.len - 1));
  for i = x.len - 2 downto 0 do
    let s = string_of_int x.digits.(i) in
    for _ = 1 to base_digits - String.length s do
      Buffer.add_char buf '0'
    done;
    Buffer.add_string buf s
  done;
  Buffer.contents buf

let max_product n =
  if n = 2 then make_bigint 1
  else if n = 3 then make_bigint 2
  else
    let threes, mult = match n mod 3 with
      | 0 -> n / 3, 1
      | 1 -> n / 3 - 1, 4
      | _ -> n / 3, 2
    in
    let r = pow3 threes in
    if mult <> 1 then multiply_small r mult;
    r

let read_n path =
  let ic = open_in path in
  let line = input_line ic in
  close_in ic;
  int_of_string (String.trim line)

let () =
  let n =
    if Array.length Sys.argv > 1 then read_n Sys.argv.(1)
    else int_of_string (String.trim (input_line stdin))
  in
  print_endline (bigint_to_string (max_product n))
