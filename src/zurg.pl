% Program that solves the Escape from Zurg problem
% program is run by main predicate escape_zurg(T, Toys, Sol). with following arguments:
% T - battery life span in time units
% Toys - list of toys to move from left to right in the form [[toy1, time1], [toy2, time2], ...]
% Sol - list of actions to perform in order to move all toys from left to right
% Example query to run in SWI-Prolog:
%   escape_zurg(60, [[buzz,5],[woody,10],[rex,20],[hamm,25]], Sol).

%% helper predicates for toys

% toy_name(Toy, Name) -> unwrap name of a toy 
% toy_name([buzz, 5], Name). -> Name = buzz
toy_name([N, _], N).
% toy_names(Toys, Names) -> collect names of a list of toys
% toy_names([[buzz, 5], [woody, 10]], Names). -> Names = [buzz, woody]
toy_names([], []).
toy_names([T|Ts], [N|Ns]) :- toy_name(T, N), toy_names(Ts, Ns).

% cost(Toy, Cost) -> unwrap cost of a toy
% cost([buzz, 5], Cost). -> Cost = 5
cost([_, C], C).
% costs(Toys, Costs) -> collect costs of a list of toys
% costs([[buzz, 5], [woody, 10]], Costs). -> Costs = [5, 10]
costs([], []).
costs([T|Ts], [C|Cs]) :- cost(T, C), costs(Ts, Cs).
% max_cost(Toys, MaxCost) -> obtain cost of the most costly toy in a list
% max_cost([[buzz,5],[woody,10],[rex,20],[hamm,25]], MaxCost). -> MaxCost = 25
max_cost(Toys, MaxCost) :- costs(Toys, Costs), max_member(MaxCost, Costs).

%% helper predicates for creating actions and switching sides

% next_side(Side, NextSide) -> switch side from left to right and vice versa
next_side(left, right).
next_side(right, left).

% action(Side, Toys, Action) -> create action predicate Action based on Side and names of Toys
% action(left, [[buzz, 5], [woody, 10]], Action). -> Action = left_to_right([buzz, woody])
% action(right, [[buzz, 5]], Action). -> Action = right_to_left([buzz])
action(left, Ts, left_to_right(Ns)) :- toy_names(Ts, Ns).
action(right, Ts, right_to_left(Ns)) :- toy_names(Ts, Ns).

%% predicates to choose toys to move from one side to the other

% is_before(T1, T2, List) -> test if T1 is before T2 in a List of toys
% is_before([buzz,5], [woody,10], [[buzz,5],[woody,10],[rex,20],[hamm,25]]). -> true.
% is_before([woody,10], [buzz,5], [[buzz,5],[woody,10],[rex,20],[hamm,25]]). -> false.
is_before(T1, T2, [T1|Rest]) :- member(T2, Rest).
is_before(T1, T2, [_|Rest]) :- is_before(T1, T2, Rest).

% select toys to move from one side or another, choose one toy or two toys
% select one toy T from list of toys List
next_toys([T], List) :- member(T, List).
% select two toys T1 and T2 from list of toys List, prevent duplicities (e.g. [buzz, woody] and [woody, buzz])
next_toys([T1, T2], List) :- member(T1, List), member(T2, List), is_before(T1, T2, List).

%% predicates for the search

% create next state from current state together with action and its cost
% state representation: s(Side, ActiveToys, InactiveToys) where
% - Side is current position of the lamp (left or right)
% - ActiveToys is a list of toys on the same side as the lamp
% - InactiveToys is a list of toys on the other side than the lamp
next_state(s(Side, Active, Inactive), s(NextSide, NextActive, NextInactive), Action, Cost) :-
    next_side(Side, NextSide),
    next_toys(Ts, Active),
    action(Side, Ts, Action),
    max_cost(Ts, Cost),
    subtract(Active, Ts, NextInactive),
    append(Inactive, Ts, NextActive).

% search the problem with dfs
% base case -> current state State is the same as Goal state and the Solution predicate is empty
dfs(Goal, Goal, _, []).
% recursive case -> expand dfs search in state State with current remaining battery Capacity
% prepend currently selected Action to solution Sol
% after generating new state and action, verify that there is enough capacity left and stop the search if not
dfs(State, Goal, Capacity, [Action|Sol]) :-
    next_state(State, NextState, Action, Cost),
    NextCapacity is Capacity - Cost,
    NextCapacity >= 0,
    dfs(NextState, Goal, NextCapacity, Sol).

% main predicate solving the problem which wraps the dfs search
% dfs - start: state s(left, Toys, []) where all Toys are on the left side
%     - goal: state s(right, _, [])  where the left side is empty
%     - capacity of the battery T
%     - solution Sol
% Example:
%  escape_zurg(60, [[buzz,5],[woody,10],[rex,20],[hamm,25]], Sol).
escape_zurg(T, Toys, Sol) :- dfs(s(left, Toys, []), s(right, _, []), T, Sol).



