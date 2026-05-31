% is it a binary tree?
binTree(nil).
binTree(node(_, L, R)) :-
	binTree(L),
	binTree(R).

% succeeds when Tree is a binary tree and Path is a list of values
% tracing a connected top-down path through it
treePath(node(V, node(LV, _, _), _), [V, LV]).
treePath(node(V, _, node(RV, _, _)), [V, RV]).
treePath(node(V, L, _), [V | Rest]) :-
	treePath(L, Rest).
treePath(node(V, _, R), [V | Rest]) :-
	treePath(R, Rest).
% V is not used in the following predicate, 
% so might as well not mention it to avoid warnings
treePath(node(_ , L, _), Rest) :-
	treePath(L, Rest).
% same as here
treePath(node(_ , _, R), Rest) :-
	treePath(R, Rest).

% is it a subtree?
% is true when Subtree is a subtree of Tree
% a subtree of a tree is either the tree itself, or a subtree of one of its children
subtree(T, T).
subtree(node(_, L, _), Sub) :- subtree(L, Sub).
subtree(node(_, _, R), Sub) :- subtree(R, Sub).

% treeSum(Tree, N) is true when the sum of the values
% of the nodes of Tree is equal to N
treeSum(nil, 0).
% treeSum of the whole tree is equal
% to the sum of the left subtree + the sum of the right subtree
treeSum(node(V, L, R), Sum) :-
	treeSum(L, SL),
	treeSum(R, SR),
	Sum is V + SL + SR.
% is true when the sum of the values of the nodes of the Subtree S
% of Tree is equal to N
subtreeSum(Tree, N, Subtree) :-
	% must be a subtree
	subtree(Tree, Subtree),
	% sum of values in subtree is N
	treeSum(Subtree, N).


