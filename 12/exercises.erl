-module (exercises).

-export ([start/2, max/1, ring/2, destroy_ring/0]).

%% exercise 1
start(AnAtom, Fun) ->
    case whereis(AnAtom) of
        undefined ->
            register(AnAtom, spawn(Fun));
        _ ->
            io:format("~p has already been registed! Please use another name.~n", [AnAtom])
    end.


%% exercise 2
%% max(N)
%% Create N processes then destroy them
%% See how much time this takes
max(N) ->
    Max = erlang:system_info(process_limit),
    io:format("Maximum allowed processes:~p~n",[Max]),
    statistics(runtime),
    statistics(wall_clock),
    L = for(1, N, fun() -> spawn(fun() -> wait() end) end),
    {_, Time1} = statistics(runtime),
    {_, Time2} = statistics(wall_clock),
    lists:foreach(fun(Pid) -> Pid ! die end, L),
    U1 = Time1 * 1000 / N,
    U2 = Time2 * 1000 / N,
    io:format("Process spawn time=~p (~p) microseconds~n",
    [U1, U2]).


wait() ->
    receive
        die -> void
    end.


for(N, N, F) -> [F()];
for(I, N, F) -> [F()|for(I+1, N, F)].


%% exercise 3
ring_node(NextNode) ->
    receive
        {message, Message} ->
            send_message(NextNode, Message),
            ring_node(NextNode);
        die ->
            io:format("~p died ~n", [self()]),
            case NextNode =:= end_node of
                true -> io:format("Finish destroy the ring, all nodes destroyed!~n");
                false -> NextNode ! die
            end
    end.

ring_end_node(NextNode) ->
    receive
        {start_sending_message, Message} ->
            send_message(NextNode, Message),
            ring_end_node(NextNode);
        die ->
            io:format("end_node died ~n"),
            NextNode ! die
    end.

send_message(NextNode, Message) ->
    NextNode ! {message, Message},
    io:format("I send '~p' to ~p~n", [NextNode, Message]).

build_ring(N, N, NextNode) ->
    Pid = spawn(fun() -> ring_end_node(NextNode) end),
    io:format("Create node ~p ~p!~nFinish build the ring, all nodes are created!~n", [N, Pid]),
    register(end_node, Pid);

build_ring(I, N, NextNode) ->
    Pid = spawn(fun() -> ring_node(NextNode) end),
    io:format("Create node ~p ~p!~n", [I, Pid]),
    build_ring(I + 1, N, Pid).

ring(N, M) ->
    statistics(wall_clock),
    io:format("Start to build the ring!~n"),
    build_ring(1, N, end_node),
    end_node ! {start_sending_message, "fuck me harder!"},
    {_, Time} = statistics(wall_clock),
    io:format("It take ~p s to finish the ring(~p, ~p) job.~n", [Time/1000, N, M]).

destroy_ring() ->
    io:format("Destroy all node in the ring!~n"),
    end_node ! die.