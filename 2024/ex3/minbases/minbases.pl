convert(_, 0, P, P).
convert(N, X, P, Result) :-
    X > 0,
    Digit is X mod N,
    NX is X div N,
    convert(N, NX, [Digit|P], Result).

is_equal([]).
is_equal([_]).
is_equal([X, X | XS]) :- is_equal([X | XS]).

check_base(X, N, N) :- 
    N =:= X + 1.
check_base(X, N, Result) :-
    N =\= X + 1,
    convert(N, X, [], Digits),
    is_equal(Digits),
    Result is N.
check_base(X, N, Result) :-
    N =\= X + 1,
    convert(N, X, [], Digits),
    \+ is_equal(Digits),
    NN is N + 1,
    check_base(X, NN, Result).

minbases([], []).
minbases([X | XS], [R | RS]) :-
    check_base(X, 2, R),
    minbases(XS, RS).

