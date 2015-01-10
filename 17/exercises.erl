-module (exercises).

-export ([nano_get_url/0, start_nano_server/0, nano_client_eval/3,
          start_nano_udp_server/0, nano_udp_client_eval/3,
          start_nano_mail_server/0, nano_mail_client_eval/3]).

% exercise 01
nano_get_url() ->
    nano_get_url("www.baidu.com").

nano_get_url(Host) ->
    {ok, Socket} = gen_tcp:connect(Host, 80, [binary, {packet, 0}]),
    ok = gen_tcp:send(Socket, "GET / HTTP/1.0\r\n\r\n"),
    receive_data(Socket, []).

receive_data(Socket, SoFar) ->
    receive
        {tcp, Socket, Bin} ->
            receive_data(Socket, [Bin|SoFar]);
        {tcp_closed, Socket} ->
            list_to_binary(lists:reverse(SoFar))
    end.


% exercise 02
start_nano_server() ->
    {ok, Listen} = gen_tcp:listen(1987, [binary, {packet, 4},
                                         {reuseaddr, true},
                                         {active, true}]),
    {ok, Socket} = gen_tcp:accept(Listen),
    gen_tcp:close(Listen),
    loop(Socket).

loop(Socket) ->
    receive
        {tcp, Socket, Bin} ->
            io:format("Server received binary = ~p~n", [Bin]),
            {Mod, Func, Args} = binary_to_term(Bin),
            io:format("Server (unpacked) ~p~n", [{Mod, Func, Args}]),
            Reply = apply(Mod, Func, Args),
            io:format("Server replying = ~p~n",[Reply]),
            gen_tcp:send(Socket, term_to_binary(Reply)),
            loop(Socket);
        {tcp_closed, Socket} ->
            io:format("Server socket closed.~n")
    end.

nano_client_eval(Mod, Func, Args) ->
    {ok, Socket} = gen_tcp:connect("localhost", 1987, [binary, {packet, 4}]),
    ok = gen_tcp:send(Socket, term_to_binary({Mod, Func, Args})),
    receive
        {tcp, Socket, Bin} ->
            io:format("Client received binary = ~p~n", [Bin]),
            Val = binary_to_term(Bin),
            io:format("Client result = ~p~n", [Val]),
            gen_tcp:close(Socket)
    end.


% exercise 03 & 04
start_nano_udp_server() ->
    {ok, Socket} = gen_udp:open(1987, [binary]),
    loop_udp(Socket).

loop_udp(Socket) ->
    receive
        {udp, Socket, Host, Port, Bin} ->
            io:format("Server received binary = ~p~n", [Bin]),
            {Mod, Func, Args} = binary_to_term(Bin),
            io:format("Server (unpacked) ~p~n", [{Mod, Func, Args}]),
            Reply = apply(Mod, Func, Args),
            io:format("Server replying = ~p~n",[Reply]),
            gen_udp:send(Socket, Host, Port, term_to_binary(Reply)),
            loop_udp(Socket)
    end.

nano_udp_client_eval(Mod, Func, Args) ->
    {ok, Socket} = gen_udp:open(0, [binary]),
    Bin = term_to_binary({Mod, Func, Args}),
    ok = gen_udp:send(Socket, "localhost", 1987, Bin),
    receive
        {udp, Socket, _Host, _Port, BinReply} ->
            io:format("Client received binary = ~p~n", [BinReply]),
            Reply = binary_to_term(BinReply),
            io:format("Client result = ~p~n", [Reply])
    after 2000 ->
        error
    end,
    gen_udp:close(Socket).


% exercise 05
start_nano_mail_server() ->
    {ok, Listen} = gen_tcp:listen(1987, [binary, {packet, 4},
                                         {reuseaddr, true},
                                         {active, true}]),
    {ok, Socket} = gen_tcp:accept(Listen),
    gen_tcp:close(Listen),
    loop_mail(Socket).

loop_mail(Socket) ->
    receive
        {tcp, Socket, Bin} ->
            io:format("Server received binary = ~p~n", [Bin]),
            {Mod, Func, Args} = binary_to_term(Bin),
            io:format("Server (unpacked) ~p~n", [{Mod, Func, Args}]),
            Reply = apply(Mod, Func, Args),
            {{Year, Month, Day}, {Hour, Minute, Second}} = erlang:localtime(),
            FileName = string:join(io_lib:format("~p~p~p~p~p~p", [Year, Month, Day, Hour, Minute, Second]), "_") ++ ".msg",
            {ok, IoDevice} = file:open(FileName, write),
            io:format(IoDevice, "~p~n", [Reply]),
            io:format("Server save replying at ~p~n",[FileName]),
            gen_tcp:send(Socket, term_to_binary(FileName)),
            loop_mail(Socket);
        {tcp_closed, Socket} ->
            io:format("Server socket closed.~n")
    end.

nano_mail_client_eval(Mod, Func, Args) ->
    {ok, Socket} = gen_tcp:connect("localhost", 1987, [binary, {packet, 4}]),
    ok = gen_tcp:send(Socket, term_to_binary({Mod, Func, Args})),
    receive
        {tcp, Socket, Bin} ->
            Val = binary_to_term(Bin),
            io:format("Server save replying at ~p~n", [Val]),
            gen_tcp:close(Socket)
    end.

