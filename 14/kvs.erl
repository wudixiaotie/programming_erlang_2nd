-module (kvs).
-export ([start/0, store/2, lookup/1]).

-spec kvs:start() -> true.
start() -> register(kvs, spawn(fun() -> loop() end)).


-spec kvs:store(term(), term()) -> true.
store(Key, Value) -> rpc({store, Key, Value}).


-spec kvs:lookup(term()) -> {ok, term()} | undefined.
lookup(Key) -> rpc({lookup, Key}).


rpc(Q) ->
    kvs ! {self(), Q},
    receive
        {kvs, Reply} ->
            Reply
    after 5000 ->
        io:format("Server do not responding!~n")
    end.


loop() ->
    receive
        {From, {store, Key, Value}} ->
            put(Key, {ok, Value}),
            From ! {kvs, true},
            io:format("~p store~n", [From]),
            loop();
        {From, {lookup, Key}} ->
            From ! {kvs, get(Key)},
            io:format("~p lookup~n", [From]),
            loop();
        die ->
            io:format("kvs server is down!~n")
    end.