% this predicate must behave like a function
% returns the running sum of a list of numbers
% e.g. running sum of [1, 2, 3] is [1, 3, 6]

running_sum([], []).
running_sum(List, Sums) :- 
	running_sum(List, 0, Sums).

running_sum([], _, []).
running_sum([X | XS], Acc, [Y | YS]) :-
	Y is Acc + X,
	running_sum(XS, Y, YS).
