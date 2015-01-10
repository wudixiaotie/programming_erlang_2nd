-module (lib_misc).
-export ([quick/1, pythag/1, perm/1, even/1, odd/1, split/1, filter/2,
    my_tuple_to_list/1]).

quick([]) -> [];
quick([Pivot|T]) ->
    quick([X || X <- T, X < Pivot])
    ++ [Pivot] ++
    quick([X || X <- T, X >= Pivot]).

pythag(N) ->
    [ {A,B,C} ||
        A <- lists:seq(1,N),
        B <- lists:seq(1,N),
        C <- lists:seq(1,N),
        A+B+C =< N,
        A*A+B*B == C*C
    ].

perm([]) -> [[]];
perm(L) -> [ [H|T] || H <- L, T <- perm(L -- [H]) ].

% practise 2
my_tuple_to_list(T) -> my_tuple_to_list(T, [], 1, tuple_size(T)).

my_tuple_to_list(T, Result, Position, Size) when Position =< Size ->
    my_tuple_to_list(T, [ element(Position, T) | Result ], Position + 1, Size);
my_tuple_to_list(_, Result, Position, Size) when Position > Size ->
    lists:reverse(Result).

% practise 5
even(L) -> even(L, []).
even([H|T], Result) ->
    case H rem 2 =:= 1 of
        true -> even(T, Result);
        false -> even(T, [H|Result])
    end;
even([], Result) -> lists:reverse(Result).

odd(L) -> odd(L, []).
odd([H|T], Result) ->
    case H rem 2 =:= 1 of
        true -> odd(T, [H|Result]);
        false -> odd(T, Result)
    end;
odd([], Result) -> lists:reverse(Result).

% practise 6
filter(F, L) -> filter(F, L, []).

filter(F, [H|T], Result) ->
    case F(H) of
        true -> filter(F, T, [H|Result]);
        false -> filter(F, T, Result)
    end;
filter(_, [], Result) -> lists:reverse(Result).

% practise 7
split(L) -> split(L, [], []).
% split(L) ->
%     {
%         filter(fun(X) -> X rem 2 == 1 end, L),
%         filter(fun(X) -> X rem 2 == 0 end, L)
%     }.

split([H|T], Odds, Evens) ->
    case (H rem 2) of
        1 -> split(T, [H|Odds], Evens);
        0 -> split(T, Odds, [H|Evens])
    end;
split([], Odds, Evens) ->
    {lists:reverse(Odds), lists:reverse(Evens)}.