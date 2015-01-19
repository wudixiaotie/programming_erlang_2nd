-module (ws_server).

-export ([start/0, start/1, stop/0]).

start() ->
    start(1987).

start(Port) ->
    register(ws_server, spawn(fun() -> start_ws_server(Port) end)).

start_ws_server(Port) ->
    {ok, ListenSocket} = gen_tcp:listen(Port, [binary, {packet, 0},
                                         {reuseaddr, true},
                                         {active, true}]),
    io:format("start_server: http://localhost:~p~n", [Port]),
    wait_for_connect(ListenSocket).

wait_for_connect(ListenSocket) ->
    case gen_tcp:accept(ListenSocket) of
        {ok, Socket} ->
            spawn(fun() -> wait_for_connect(ListenSocket) end),
            loop(Socket);
        {error, Why} ->
            % spawn(fun() -> wait_for_connect(ListenSocket) end),
            io:format("ListenSocket stoped:~p~n", [Why])
    end.

loop(Socket) ->
    receive
        {tcp, Socket, Bin} ->
            io:format("Server received binary = ~p~n", [Bin]),
            gen_tcp:send(Socket, "fuck"),
            loop(Socket);
        {tcp_closed, Socket} ->
            io:format("Server socket closed.~n")
    end.


stop() ->
    io:format("start_server: http://localhost:").