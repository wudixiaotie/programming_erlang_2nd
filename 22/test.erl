-module (test).
-compile(export_all).


a() ->
    PidB = spawn_link(fun() -> b() end),
    PidC = spawn_link(fun() -> c() end),
    {PidB, PidC}.
b() ->
    receive
    after 2000 ->
        io:format("I'm b!~n"),
        b()
    end.
c() ->
    receive
    after 2000 ->
        io:format("I'm c!~n"),
        c()
    end.


% {PidB, PidC} = test:a().