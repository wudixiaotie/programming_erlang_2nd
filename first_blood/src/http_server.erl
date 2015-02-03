-module (http_server).

-export ([start/0, start/1, stop/0]).
-compile(export_all).

-define (DEFAULT_PORT, 1987).
% -define (DEF_PORT, 1987).
% -define (DEF_PORT, 1987).
% -define (DEF_PORT, 1987).
% -define (DEF_PORT, 1987).
% -define (DEF_PORT, 1987).

% http://erlang.org/doc/apps/inets/http_server.html
% spawn_opt是啥？
% erlang:system_info(schedulers)是啥？
% CPU调度器，用来调度多核cpu的使用。
start() ->
    start(?DEFAULT_PORT).

start(Port) ->
    io:format("start_server: http://localhost:~p~n", [Port]),
    listen(Port),
    register(http_server, self()),
    receive
        _ -> stop
    end.

listen(Port) ->
    Opts = [{active, false},
            binary,
            {backlog, 512},
            {packet, http_bin},
            {raw,6,9,<<1:32/native>>}, %defer accept
            {delay_send,true},
            %%{nodelay,true},
            {reuseaddr, true}],
    {ok, ListenSocket} = gen_tcp:listen(Port, Opts),
    Fun = fun(SchedulerIndex) ->
        io:format("SchedulerIndex:~p~n", [SchedulerIndex]),
        register(list_to_atom("acceptor_" ++ integer_to_list(SchedulerIndex)),
                 spawn_opt(fun() -> accept(ListenSocket, SchedulerIndex) end,
                           [link, {scheduler, SchedulerIndex}]))
    end,
    lists:foreach(Fun, lists:seq(1, erlang:system_info(schedulers))).

accept(ListenSocket, SchedulerIndex) ->
    io:format("accept pid:~p, scheduler index:~p~n", [self(), SchedulerIndex]),
    case gen_tcp:accept(ListenSocket) of
        {ok, Socket} ->
            spawn_opt(fun() -> loop(Socket) end, [link, {scheduler, SchedulerIndex}]);
        Error ->
            erlang:error(Error)
    end,
    accept(ListenSocket, SchedulerIndex).

loop(Socket) ->
    case gen_tcp:recv(Socket, 0) of
        {ok, http_eoh} ->
            Response = <<"HTTP/1.1 200 OK\r\nContent-Length: 12\r\n\r\nhello world!">>,
            gen_tcp:send(Socket, Response),
            gen_tcp:close(Socket),
            ok;
        {ok, _Data} ->
            loop(Socket);
        Error ->
            Error
    end.
    % receive
    %     {tcp, Socket, Bin} ->
    %         io:format("Server received binary = ~p~n", [Bin]),
    %         case erlang:decode_packet(http, Bin, [{packet_size, 0}]) of
    %             {ok, HttpRequest, _Rest} ->
    %                 io:format("Server received HttpRequest = ~p~n", [HttpRequest]),
    %                 gen_tcp:send(Socket, "fuck"),
    %                 gen_tcp:close(Socket),
    %                 ok;
    %             {error, Why} ->
    %                 {error, Why} 
    %         end;
    %     {tcp_closed, Socket} ->
    %         io:format("Server socket closed.~n")
    % end.


stop() ->
    http_server ! stop,
    io:format("start_server: http://localhost:").