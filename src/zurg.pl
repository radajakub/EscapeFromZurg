% escape_zurg(60,[[buzz,5],[woody,10],[rex,20],[hamm,25]], Sol).
escape_zurg(T, Toys, Sol) :- dfs(left, Toys, [], Sol, [], T).

% unwrap cost and name from a toy
cost([_, C], C).
toyname([N, _], N).

% get more expensive toy of the pair T1, T2
max_cost(T1, T2, C) :- cost(T1, C1), cost(T2, C2), max_member(C, [C1, C2]).

pair(T1, T2, List) :- member(T1, List), member(T2, List), T1 \= T2.

% 'side', 'Left', 'Right', 'Solution', 'Accumulator'
dfs(left, Left, Right, Sol, Acc, Capacity) :-
    pair(T1, T2, Left),
    toyname(T1, N1),
    toyname(T2, N2),
    subtract(Left, [T1,T2], NewLeft),
    max_cost(T1, T2, Cost),
    NewCapacity is Capacity - Cost,
    NewCapacity >= 0,
    dfs(right, NewLeft, [T1,T2|Right], Sol, [left_to_right(N1, N2)|Acc], NewCapacity).

dfs(right, [], _Right, Sol, Sol, _).
dfs(right, Left, Right, Sol, Acc, Capacity) :-
    member(T, Right),
    toyname(T, N),
    subtract(Right, [T], NewRight),
    cost(T, Cost),
    NewCapacity is Capacity - Cost,
    NewCapacity >= 0,
    dfs(left, [T|Left], NewRight, Sol, [right_to_left(N)|Acc], NewCapacity).

