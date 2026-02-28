% define the directions
direction(n, -1, 0).
direction(s, 1, 0).
direction(w, 0, -1).
direction(e, 0, 1).
direction(nw, -1, -1).
direction(ne, -1, 1).
direction(sw, 1, -1).
direction(se, 1, 1).

% check if a cell is within the grid bounds
valid_cell(X, Y, N) :-
    X >= 0, X < N, Y >= 0, Y < N.

% get the weight of a cell in the grid
weight(Grid, X, Y, Weight) :-
    nth0(X, Grid, Row),
    nth0(Y, Row, Weight).

% BFS algorithm to find the shortest path
bfs(Grid, N, Path) :-
    bfs([[0, 0, []]], Grid, N, [], Path),!.

bfs([[X, Y, Path] | _], _, N, _, Path) :-
    X =:= N-1, Y =:= N-1,!.

bfs([[X, Y, Path] | Queue], Grid, N, Visited, ResultPath) :-
    findall([NX, NY, [Dir | Path]],
            (direction(Dir, DX, DY),
             NX is X + DX,
             NY is Y + DY,
             valid_cell(NX, NY, N),
             weight(Grid, X, Y, W1),
             weight(Grid, NX, NY, W2),
             W2 < W1,
             \+ memberchk([NX, NY], Visited)),
            Neighbors),
    append(Queue, Neighbors, NewQueue),
    append(Visited, [[X, Y]], NewVisited),
    bfs(NewQueue, Grid, N, NewVisited, ResultPath).

find_shortest_path(Grid, Directions) :-
    length(Grid, N),
    (   bfs(Grid, N, ReversedPath)
    ->  reverse(ReversedPath, Directions)
    ;   Directions = 'IMPOSSIBLE'
    ).

read_grid(File, Grid) :-
    open(File, read, Stream),
    read_line_to_codes(Stream, Line1),
    atom_codes(Line1Atom, Line1),
    atom_number(Line1Atom, N),
    read_lines(Stream, N, Grid),
    close(Stream).

read_lines(_, 0, []):- !.
read_lines(Stream, N, [Row | Rows]) :-
    N > 0,
    read_line_to_codes(Stream, Line),
    atom_codes(LineAtom, Line),
    atomic_list_concat(Atoms, ' ', LineAtom),
    maplist(atom_number, Atoms, Row),
    N1 is N - 1,
    read_lines(Stream, N1, Rows).

moves(File, Directions) :-
    read_grid(File, Grid),
    find_shortest_path(Grid, Directions).
