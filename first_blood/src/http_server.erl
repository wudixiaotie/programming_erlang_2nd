-module (http_server).

-export ([start/0, start/1, stop/0]).
% http://erlang.org/doc/apps/inets/http_server.html
start() ->
    start(1987).

start(Port) ->
    io:format("start_server: http://localhost:~p~n", [Port]),
    % register(ws_server, spawn(fun() -> start_ws_server(Port) end)).
    start_ws_server(Port).

start_ws_server(Port) ->
    {ok, ListenSocket} = gen_tcp:listen(Port, [binary, {packet, 0},
                                         {reuseaddr, true},
                                         {active, true}]),
    case gen_tcp:accept(ListenSocket) of
        {ok, Socket} ->
            spawn(fun() -> loop(Socket) end);
        {error, Why} ->
            io:format("ListenSocket stoped:~p~n", [Why])
    end.

loop(Socket) ->
    receive
        {tcp, Socket, Bin} ->
            io:format("Server received binary = ~p~n", [Bin]),
            case erlang:decode_packet(http, Bin, [{packet_size, 0}]) of
                {ok, HttpRequest, _Rest} ->
                    io:format("Server received HttpRequest = ~p~n", [HttpRequest]),
                    gen_tcp:send(Socket, "fuck"),
                    gen_tcp:close(Socket),
                    ok;
                {error, Why} ->
                    {error, Why} 
            end;
        {tcp_closed, Socket} ->
            io:format("Server socket closed.~n")
    end.


stop() ->
    io:format("start_server: http://localhost:").