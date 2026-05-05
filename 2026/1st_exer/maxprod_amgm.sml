fun maxProduct (n : int) : IntInf.int =
let
  val one  : IntInf.int = 1
  val two  : IntInf.int = 2
  val three: IntInf.int = 3
  val four : IntInf.int = 4
in
  if n = 2 then one
  else if n = 3 then two
  else
    let val threes = n div 3 in
      case n mod 3 of
           0 => IntInf.pow (three, threes)
         | 1 => four * IntInf.pow (three, threes - 1)
         | _ => two  * IntInf.pow (three, threes)
    end
    end

fun maxprod filename =
let
  val ic = TextIO.openIn filename
  val ans =
    (case TextIO.inputLine ic of
         SOME line =>
           (case Int.fromString line of
                SOME n => maxProduct n
              | NONE   => raise Fail "could not parse integer")
       | NONE => raise Fail "empty input")
  val () = TextIO.closeIn ic
in
  TextIO.output (TextIO.stdOut, IntInf.toString ans);
  TextIO.output (TextIO.stdOut, "\n")
end

fun maxprodStdin () =
let
  val line =
    case TextIO.inputLine TextIO.stdIn of
         SOME s => s
       | NONE   => raise Fail "empty input"
  val n =
    case Int.fromString line of
         SOME k => k
       | NONE   => raise Fail "could not parse integer"
  val ans = maxProduct n
in
  TextIO.output (TextIO.stdOut, IntInf.toString ans);
  TextIO.output (TextIO.stdOut, "\n")
end

val () =
  case CommandLine.arguments () of
       [filename] => maxprod filename
     | _          => maxprodStdin ()
