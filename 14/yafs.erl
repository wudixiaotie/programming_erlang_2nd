-module (yafs).

-export ([start/0]).

start() ->
    io:format("yafs server is up~n"),
    spawn(fun() -> loop() end).


loop() ->
    receive
        {From, pwd} ->
            From ! c:pwd(),
            loop()
    end.