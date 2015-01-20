-module (http_server).

-export ([start/0, start/1, stop/0]).

-define (DEFAULT_PORT, 1987).
-define (DEFAULT_ACCPEPTOR_COUNT, 10).
-define (DEF_PORT, 1987).
-define (DEF_PORT, 1987).
-define (DEF_PORT, 1987).
-define (DEF_PORT, 1987).
-define (DEF_PORT, 1987).

% http://erlang.org/doc/apps/inets/http_server.html
% spawn_opt是啥？
% erlang:system_info(schedulers)是啥？
start() ->
    start(?DEFAULT_PORT).

start(Port) ->
    io:format("start_server: http://localhost:~p~n", [Port]),
    register(ws_server, spawn(fun() -> listen(Port, ?DEFAULT_ACCPEPT_COUNT) end)).

start(Port, AcceptorCount) ->
    io:format("start_server: http://localhost:~p~n", [Port]),
    register(ws_server, spawn(fun() -> listen(Port, AcceptorCount) end)).

listen(Port, AcceptorCount) ->
    Opts = [{active, false},
            binary,
            {backlog, 512},
            {packet, http_bin},
            {raw,6,9,<<1:32/native>>}, %defer accept
            {delay_send,true},
            %%{nodelay,true},
            {reuseaddr, true}],
    {ok, ListenSocket} = gen_tcp:listen(Port, Opts),
    Fun = fun(I) ->
                    register(list_to_atom("acceptor_" ++ integer_to_list(I)),
                             spawn_opt(?MODULE, accept, [S, I], [link, {scheduler, I}]))
            end,
    lists:foreach(Fun, lists:seq(1, AcceptorCount)).

accept(ListenSocket) ->
    io:format("accept pid:~p~n", [self()]),
    case gen_tcp:accept(ListenSocket) of
        {ok, Socket} ->
            spawn(fun() -> accept(ListenSocket) end),
            loop(Socket);
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