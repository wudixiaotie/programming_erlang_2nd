-module (a).
-export ([f1/0, f2/0, f3/0, f4/1, f5/1, f6/1]).

% Incorrect Use of a BIF Return Value
f1() ->
    X = erlang:time(),
    seconds(X).
seconds({_Year, _Month, _Day, Hour, Min, Sec}) ->
    (Hour * 60 + Min)*60 + Sec.


% Incorrect Arguments to a BIF
f2() ->
    tuple_size(list_to_tuple({a,b,c})).


% Incorrect Program Logic
f3() -> factorial(-5).

% factorial(N) when N =<0 -> 1;
factorial(0) -> 1;
factorial(N) -> N*factorial(N-1).


f4({H,M,S}) ->
    (H+M*60)*60+S.
f5({H,M,S}) when is_integer(H) -> (H+M*60)*60+S.
f6({H,M,S}) when is_float(H) ->
    print(H,M,S),
    (H+M*60)*60+S.
print(H,M,S) ->
    Str = integer_to_list(H) ++ ":" ++ integer_to_list(M) ++ ":" ++
          integer_to_list(S),
    io:format("~s", [Str]).