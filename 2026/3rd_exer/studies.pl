:- use_module(library(clpfd)).


read_ints(Stream, Ints) :-
    read_string(Stream, _, Str),
    split_string(Str, " \t\n\r", " \t\n\r", Parts),
    exclude(==(""), Parts, Toks),
    numbers(Toks, Ints).

numbers([], []).
numbers([T | Ts], [N | Ns]) :- number_string(N, T), numbers(Ts, Ns).


take_pairs(0, Rest, [], Rest) :- !.
take_pairs(N, [A, B | T], [A-B | Ps], Rest) :-
    N > 0, N1 is N - 1, take_pairs(N1, T, Ps, Rest).

% ---- the constraint model ----
solve([N, M, K | R0], Max) :-
    take_pairs(M, R0, Prereqs, R1),
    R1 = [C | R2],
    take_pairs(C, R2, Conflicts, _),
    length(Sems, N),
    Sems ins 1..N,
    prereqs(Prereqs, Sems),                 % sem[a] #< sem[b]
    conflicts(Conflicts, Sems),             % sem[x] #\= sem[y]
    capacity(Sems, N, K),                   % at most K per semester
    clique_distinct(Conflicts, N, Sems),    % strengthen dense-conflict cases
    Cap is (N + K - 1) // K,                % capacity lower bound
    max_of(Sems, Max),
    Max #>= Cap,
    once(labeling([min(Max)], Sems)).

prereqs([], _).
prereqs([A-B | Ps], Sems) :-
    nth1(A, Sems, SA), nth1(B, Sems, SB),
    SA #< SB,
    prereqs(Ps, Sems).

conflicts([], _).
conflicts([X-Y | Cs], Sems) :-
    nth1(X, Sems, SX), nth1(Y, Sems, SY),
    SX #\= SY,
    conflicts(Cs, Sems).

capacity(Sems, N, K) :-
    numlist(1, N, Vals),
    counts(Vals, K, Pairs),
    global_cardinality(Sems, Pairs).
counts([], _, []).
counts([V | Vs], K, [V-Cnt | Ps]) :- Cnt in 0..K, counts(Vs, K, Ps).

max_of([X], X).
max_of([X, Y | Xs], Max) :- max_of([Y | Xs], M), Max #= max(X, M).

% all_distinct on conflict cliques 
% Pairwise #\= can't see that w mutually-conflicting courses need w semesters;
% all_distinct on a clique can (Hall propagation), which avoids a search blow-up
% on dense conflict graphs.
clique_distinct(Conflicts, N, Sems) :-
    numlist(1, N, Vs),
    cover(Vs, Conflicts, Sems).

cover([], _, _).
cover([V | Vs], Conf, Sems) :-
    grow_clique(Vs, Conf, [V], Clique),
    post_clique(Clique, Sems),
    subtract([V | Vs], Clique, Rest),
    cover(Rest, Conf, Sems).

grow_clique([], _, C, C).
grow_clique([U | Us], Conf, C, Out) :-
    ( adjacent_to_all(U, C, Conf)
    ->  grow_clique(Us, Conf, [U | C], Out)
    ;   grow_clique(Us, Conf, C, Out)
    ).

adjacent_to_all(_, [], _).
adjacent_to_all(U, [W | Ws], Conf) :-
    ( member(U-W, Conf) ; member(W-U, Conf) ),
    !,
    adjacent_to_all(U, Ws, Conf).

post_clique([_], _) :- !.                    % a single vertex needs no constraint
post_clique(Clique, Sems) :-
    clique_vars(Clique, Sems, Vars),
    all_distinct(Vars).
clique_vars([], _, []).
clique_vars([I | Is], Sems, [S | Ss]) :- nth1(I, Sems, S), clique_vars(Is, Sems, Ss).


studies(File, Sem) :-
    setup_call_cleanup(open(File, read, S), read_ints(S, Ints), close(S)),
    solve(Ints, Sem).

main :-
    read_ints(user_input, Ints),
    ( solve(Ints, Sem) -> format("~w~n", [Sem]) ; writeln('IMPOSSIBLE') ).
