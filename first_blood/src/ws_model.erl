-module(ws).
-export([start/0]).
 
-define(PORT, 12345).
 
start() ->
    {ok, Listen} = gen_tcp:listen(?PORT, [binary, {packet, 0}, {reuseaddr, true}, {active, true}]),
    io:format("listen on ~p~n", [?PORT]),
    par_connect(Listen).
 
par_connect(Listen) ->
    {ok, Socket} = gen_tcp:accept(Listen),
    spawn(fun() -> par_connect(Listen) end),
    wait(Socket).
 
wait(Socket) ->
    receive
        {tcp, Socket, HeaderData} ->
            HeaderList = binary:split(HeaderData, <<"\r\n">>, [global]),
            HeaderList1 = [list_to_tuple(binary:split(Header, <<": ">>)) || Header >) /= nomatch],
            {_, SecWebSocketKey} = lists:keyfind(<<"Sec-WebSocket-Key">>, 1, HeaderList1),
            Sha1 = crypto:sha([SecWebSocketKey, <<"258EAFA5-E914-47DA-95CA-C5AB0DC85B11">>]),
            Base64 = base64:encode(Sha1),
            Handshake = [
                <<"HTTP/1.1 101 Switching Protocols\r\n">>,
                <<"Upgrade: websocket\r\n">>,
                <<"Connection: Upgrade\r\n">>,
                <<"Sec-WebSocket-Accept: ">>, Base64, <<"\r\n">>,
                <<"\r\n">>
            ],
            gen_tcp:send(Socket, Handshake),
            loop(Socket);
        Any ->
            io:format("Received: ~p~n", [Any]),
            wait(Socket)
    end.
 
loop(Socket) ->
    receive
        {tcp, Socket, Data} ->
            handle_data(Data, Socket);
        {tcp_closed, Socket} ->
            gen_tcp:close(Socket);
        Any ->
            io:format("Received:~p~n", [Any]),
            loop(Socket)
    end.
 
unmask(Payload, Masking) ->
    unmask(Payload, Masking, <<>>).
 
unmask(Payload, Masking = <<MA:8, MB:8, MC:8, MD:8>>, Acc) ->
    case size(Payload) of
        0 -> Acc;
        1 ->
            <> = Payload,
            <<Acc/binary, (MA bxor A)>>;
        2 ->
            <<A:8, B:8>> = Payload,
            <<Acc/binary, (MA bxor A), (MB bxor B)>>;
        3 ->
            <<A:8, B:8, C:8>> = Payload,
            <<Acc/binary, (MA bxor A), (MB bxor B), (MC bxor C)>>;
        _Other ->
            <<A:8, B:8, C:8, D:8, Rest/binary>> = Payload,
            Acc1 = <<Acc/binary, (MA bxor A), (MB bxor B), (MC bxor C), (MD bxor D)>>,
            unmask(Rest, Masking, Acc1)
    end.
 
handle_data(Data, Socket) ->
    <<_Fin:1, _Rsv:3, _Opcode:4, _Mask:1, Len:7, Rest/binary>> = Data,
    <<Masking:4/binary, Payload:Len/binary, Next/binary>> = Rest,
    Line = unmask(Payload, Masking),
    case unicode:characters_to_list(Line) of
        {incomplete, _, _} ->
            gen_tcp:close(Socket);
        Str ->
            Bin = unicode:characters_to_binary(Str),
            Frame = <<1:1, 0:3, 1:4, 0:1, (size(Bin)):7, Bin/binary>>,
            gen_tcp:send(Socket, Frame),
            case size(Next) of
                0 -> loop(Socket);
                _Other -> handle_data(Next, Socket)
            end
    end.