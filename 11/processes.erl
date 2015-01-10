-module (processes).

-export ([max/1, fuck/0]).

%% max(N)

%%   Create N processes then destroy them
%%   See how much time this takes

max(N) ->
    Max = erlang:system_info(process_limit),
    io:format("Maximum allowed processes:~p~n",[Max]),
    statistics(runtime),
    statistics(wall_clock),
    L = for(1, N, fun() -> spawn(fun() -> wait() end) end),
    {_, Time1} = statistics(runtime),
    {_, Time2} = statistics(wall_clock),
    lists:foreach(fun(Pid) -> Pid ! die end, L),
    U1 = Time1 * 1000 / N,
    U2 = Time2 * 1000 / N,
    io:format("Process spwan time=~p (~p) microseconds~n", [U1, U2]).

wait() ->
    receive
        die -> void
    end.

for(N, N, F) -> [F()];
for(I, N, F) -> [F()|for(I+1, N, F)].



fuck() ->
    {_, Time1} = statistics(wall_clock),
    io:format("wall_clock=~p ~n", [Time1]),
    receive
        aa -> void
    after 1000 ->
        {_, Time2} = statistics(wall_clock),
        Time2
    end.
    