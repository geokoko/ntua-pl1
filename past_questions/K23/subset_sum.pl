% subset sum prolog
% subset_sum (Set, Sum, Subset) Set and Subset are number lists and Sum is int.

subset([], []).
subset([X | XS], [X | YS]) :-
    subset(XS, YS).
subset([_ | XS], YS) :-
    subset(XS, YS).

sum([], 0).
sum([Y | YS], Sum) :-
	sum(YS, Rest),
	Sum is X + Rest.

subset_sum(Set, Sum, Subset) :-
	subset(Set, Subset),
	sum(Subset, Sum).
