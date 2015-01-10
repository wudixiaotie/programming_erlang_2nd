-module (area_server_final).   
-export ([start/0, area/2, loop/0]).

start() -> spawn(xt_server_1, loop, []).


loop() ->
    receive
        { From, { rectangle, Width, Ht } } ->
            From !{ self(), Width * Ht };
        { From, { square, Side } } ->
            From !{ self(), Side * Side};
        { From, { circle, R } } ->
            From !{ self(), 3.1415926 * R * R };
        { From, Other } ->
            From !{ self(), { error, Other } }
    end,
    loop().


area(Server, What) ->
    rpc(Server, What).


rpc(Pid, Request) ->
    Pid ! { self(), Request },
    receive
        { Pid, Response } -> Response
    end.