
read_ints(Stream, Ints) :-
    read_string(Stream, _, Str),
    split_string(Str, " \t\n\r", " \t\n\r", Parts),
    exclude(==(""), Parts, Toks),
    numbers(Toks, Ints).

numbers([], []).
numbers([T | Ts], [N | Ns]) :- number_string(N, T), numbers(Ts, Ns).

% take NObs "row col" pairs off the token list
obstacles(0, _, []) :- !.
obstacles(K, [R, C | T], [R-C | Os]) :- K > 0, K1 is K - 1, obstacles(K1, T, Os).

% ---- solver ----
walks_solve([N, M, T, R0, C0, R1, C1, NObs | Rest], Ways) :-
    V is N * M,
    obstacles(NObs, Rest, Obs),
    empty_assoc(Empty),
    blocked_cells(Obs, M, Empty, Blocked),
    Start is (R0 - 1) * M + (C0 - 1),
    Target is (R1 - 1) * M + (C1 - 1),
    (   \+ get_assoc(Start, Blocked, _),
        \+ get_assoc(Target, Blocked, _),
        bfs(N, M, Blocked, Target, Dist),
        get_assoc(Start, Dist, D0),
        D0 =< T, (T - D0) mod 2 =:= 0           % reachable in T steps, right parity
    ->  neighbour_table(0, V, N, M, Blocked, NbrList),  Nbrs =.. [a | NbrList],
        dist_table(0, V, Dist, DistList),              Dists =.. [a | DistList],
        start_layer(0, V, Start, InitList),            Cur =.. [a | InitList],
        run(T, V, Nbrs, Dists, Cur, Final),
        TP is Target + 1,
        arg(TP, Final, Ways)
    ;   Ways = 0
    ).

blocked_cells([], _, B, B).
blocked_cells([R-C | Os], M, B0, B) :-
    Id is (R - 1) * M + (C - 1),
    put_assoc(Id, B0, t, B1),
    blocked_cells(Os, M, B1, B).

% ---- precompute three arity-V tables (indexed by position = cellid+1) ----
neighbour_table(V, V, _, _, _, []) :- !.
neighbour_table(I, V, N, M, Blocked, [Ps | T]) :-
    neighbours(N, M, Blocked, I, Ns),          % 0-based neighbour ids
    shift(Ns, Ps),                             % -> 1-based positions for arg/3
    I1 is I + 1,
    neighbour_table(I1, V, N, M, Blocked, T).

shift([], []).
shift([X | Xs], [Y | Ys]) :- Y is X + 1, shift(Xs, Ys).

dist_table(V, V, _, []) :- !.
dist_table(I, V, Dist, [D | T]) :-
    ( get_assoc(I, Dist, D0) -> D = D0 ; D = -1 ),
    I1 is I + 1,
    dist_table(I1, V, Dist, T).

start_layer(V, V, _, []) :- !.
start_layer(I, V, Start, [X | T]) :-
    ( I =:= Start -> X = 1 ; X = 0 ),
    I1 is I + 1,
    start_layer(I1, V, Start, T).

% ---- one DP step: Next[p] = sum of Cur over live neighbours, else 0 ----
run(0, _, _, _, Cur, Cur) :- !.
run(T, V, Nbrs, Dists, Cur, Final) :-
    T > 0,
    Rem is T - 1,
    step(1, V, Rem, Nbrs, Dists, Cur, Sums),
    Next =.. [a | Sums],
    run(Rem, V, Nbrs, Dists, Next, Final).

step(P, V, _, _, _, _, []) :- P > V, !.
step(P, V, Rem, Nbrs, Dists, Cur, [S | Ss]) :-
    arg(P, Dists, D),
    (   D >= 0, D =< Rem, (Rem - D) mod 2 =:= 0
    ->  arg(P, Nbrs, NbPs), sum_cells(NbPs, Cur, 0, S)
    ;   S = 0                                  % prune: can't finish in time/parity
    ),
    P1 is P + 1,
    step(P1, V, Rem, Nbrs, Dists, Cur, Ss).

sum_cells([], _, A, A).
sum_cells([P | Ps], Cur, A, S) :- arg(P, Cur, X), A1 is A + X, sum_cells(Ps, Cur, A1, S).

% ---- BFS distance from the target to every free cell (unit edges, level by level) ----
bfs(N, M, Blocked, Target, Dist) :-
    empty_assoc(D0),
    put_assoc(Target, D0, 0, D1),
    bfs_levels([Target], 1, N, M, Blocked, D1, Dist).

bfs_levels([], _, _, _, _, D, D) :- !.
bfs_levels(Frontier, Lvl, N, M, Blocked, D0, D) :-
    grow_level(Frontier, Lvl, N, M, Blocked, D0, D1, Next),
    Lvl1 is Lvl + 1,
    bfs_levels(Next, Lvl1, N, M, Blocked, D1, D).

grow_level([], _, _, _, _, D, D, []).
grow_level([C | Cs], Lvl, N, M, Blocked, D0, D, Next) :-
    neighbours(N, M, Blocked, C, Ns),
    add_unseen(Ns, Lvl, D0, D1, Here),
    grow_level(Cs, Lvl, N, M, Blocked, D1, D, Rest),
    append(Here, Rest, Next).

add_unseen([], _, D, D, []).
add_unseen([X | Xs], Lvl, D0, D, New) :-
    ( get_assoc(X, D0, _)
    ->  add_unseen(Xs, Lvl, D0, D, New)
    ;   put_assoc(X, D0, Lvl, D1),
        New = [X | More],
        add_unseen(Xs, Lvl, D1, D, More)
    ).

% free 4-neighbours of cell Id (as 0-based ids)
neighbours(N, M, Blocked, Id, Ns) :-
    R is Id // M, C is Id mod M,
    findall(NId,
        ( member(DR-DC, [(-1)-0, 1-0, 0-(-1), 0-1]),
          R2 is R + DR, R2 >= 0, R2 < N,
          C2 is C + DC, C2 >= 0, C2 < M,
          NId is R2 * M + C2,
          \+ get_assoc(NId, Blocked, _)
        ),
        Ns).

% ---- entry points ----
walks(File, Ways) :-
    setup_call_cleanup(open(File, read, S), read_ints(S, Ints), close(S)),
    walks_solve(Ints, Ways).

main :-
    read_ints(user_input, Ints),
    walks_solve(Ints, Ways),
    format("~w~n", [Ways]).
