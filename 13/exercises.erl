-module (exercises).

-export ([simple/0, my_spawn/3, my_spawn1/3, my_spawn/4, still_running/0, no5/0,
          stop_no5/0, no6/0, stop_no6/0]).

simple() ->
    receive
        stop -> void
    after 3000 ->
        exit("fuck")
    end.

on_exit(Pid, Fun) ->
    spawn(fun() ->
                Ref = monitor(process, Pid),
                receive
                    {'DOWN', Ref, process, Pid, Why} ->
                        Fun(Why)
                end
            end).

% exercises 01
my_spawn(Mod, Func, Args) ->
    statistics(wall_clock),
    {Pid, Ref} = spawn_monitor(Mod, Func, Args),
    receive
        {'DOWN', Ref, process, Pid, Why} ->
            {_, Time} = statistics(wall_clock),
            io:format("~p:~p(~p) live for about:~p s, and died because: ~p~n",
                      [Mod, Func, Args, Time / 1000, Why])
    end.


% exercises 02
my_spawn1(Mod, Func, Args) ->
    statistics(wall_clock),
    Fun = 
        fun(Why) ->
            {_, Time} = statistics(wall_clock),
            io:format("~p:~p(~p) live for about:~p s, and died because: ~p~n",
                      [Mod, Func, Args, Time / 1000, Why])
        end,
    Pid = spawn(Mod, Func, Args),
    on_exit(Pid, Fun).


% exercises 03
my_spawn(Mod, Func, Args, Time) ->
    statistics(wall_clock),
    {Pid, Ref} = spawn_monitor(Mod, Func, Args),
    receive
        {'DOWN', Ref, process, Pid, Why} ->
            {_, TimeLive} = statistics(wall_clock),
            io:format("~p:~p(~p) live for about:~p s, and died because: ~p~n",
                      [Mod, Func, Args, TimeLive / 1000, Why])
    after Time ->
        exit(Pid, kill),
        io:format("after ~p s, I killed ~p:~p(~p)~n",
                      [Time / 1000, Mod, Func, Args])
    end.

% exercises 04 exit(whereis(loop_running), kill).
still_running() ->
    start_running(),
    Pid = spawn(fun() -> monitor_running()  end),
    register(monitor_running, Pid).


start_running() ->
    Pid = spawn(fun() -> loop() end),
    register(loop_running, Pid).

loop() ->
    receive
        die -> void
    after 5000 ->
        io:format("I'm still running！~n"),
        loop()
    end.

monitor_running() ->
    io:format("start monitor the process! ~n"),
    Ref = monitor(process, loop_running),
    receive
        {'DOWN', Ref, process, _Pid, _Why} ->
            io:format("loop running died! restart! ~n"),
            start_running()
    end.


% exercises 05
no5() ->
    Pid = spawn(fun() -> monitor5() end),
    register(monitor5, Pid).

stop_no5() ->
    exit(whereis(monitor5), kill),
    exit(whereis(worker1), kill),
    exit(whereis(worker2), kill),
    exit(whereis(worker3), kill).

monitor5() ->
    {Pid1, Ref1} = spawn_monitor(fun() -> loop(1) end),
    register(worker1, Pid1),
    {Pid2, Ref2} = spawn_monitor(fun() -> loop(2) end),
    register(worker2, Pid2),
    {Pid3, Ref3} = spawn_monitor(fun() -> loop(3) end),
    register(worker3, Pid3),
    receive
        {'DOWN', Ref1, process, Pid1, _Why} ->
            io:format("worker1 died! restart! ~n"),
            {Pid, _Ref} = spawn_monitor(fun() -> loop(1) end),
            register(worker1, Pid);
        {'DOWN', Ref2, process, Pid2, _Why} ->
            io:format("worker2 died! restart! ~n"),
            {Pid, _Ref} = spawn_monitor(fun() -> loop(2) end),
            register(worker2, Pid);
        {'DOWN', Ref3, process, Pid3, _Why} ->
            io:format("worker3 died! restart! ~n"),
            {Pid, _Ref} = spawn_monitor(fun() -> loop(3) end),
            register(worker3, Pid)
    end.

loop(Number) ->
    receive
        die -> void
    after 5000 ->
        io:format("Worker No.~p still running！~n", [Number]),
        loop(Number)
    end.


% exercises 06
% no6() ->
worker() ->