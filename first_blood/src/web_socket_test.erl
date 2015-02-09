-module (web_socket_test).
-compile(export_all).
% var list_ws = [];
% for(var i = 0; i < 100; i++) {
%   list_ws[i] = new WebSocket("ws://localhost:1987");
% }

% websocket_server:start().
% c("../test/web_socket_test.erl").
% SocketList = web_socket_test:loop(300).

connect() ->
    case gen_tcp:connect("localhost", 1987, [binary,{packet,raw},{active,true},{reuseaddr,true}]) of
        {ok, Socket} ->
            HandshakeHeader = [
                <<"GET / HTTP/1.1\r\n">>,
                <<"Host: localhost:1987\r\n">>,
                <<"Upgrade: websocket\r\n">>,
                <<"Connection: Upgrade\r\n">>,
                <<"Sec-WebSocket-Key: 2o79ukx+U8rH0Whmp4r2aw==\r\n">>,
                <<"Sec-WebSocket-Version: 13\r\n">>,
                <<"\r\n">>
            ],
            gen_tcp:send(Socket, HandshakeHeader),
            Socket;
        Any ->
            Any
end.

loop(Max) ->
    websocket_client(Max, 1, []).

websocket_client(Max, CurrentIndex, SocketList) ->
    io:format("~p~n", [CurrentIndex]),
    case Max =:= CurrentIndex of
        true ->
            SocketList;
        false ->
            Socket = connect(),
            NewSocketList = [Socket|SocketList],
            websocket_client(Max, CurrentIndex + 1, NewSocketList)
    end.