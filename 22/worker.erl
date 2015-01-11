-module (worker).

-compile(export_all).

get_a_job_and_do() ->
    JobInfo = job_center:work_wanted(),
    spawn_link(fun() -> superviser(JobInfo) end).


superviser({JobNumber, JobTime, F}) ->
    {WorkerPid, _Ref} = spawn_monitor(fun() -> work(F) end),
    receive
        {'DOWN', _Ref, process, WorkerPid, normal} ->
            job_center:job_done(JobNumber),
            io:format("superviser: Work done!~n");
        {'DOWN', _Ref, process, WorkerPid, Why} ->
            job_center:job_failed(JobNumber),
            io:format("superviser: Work failed! Because: ~p~n", [Why])
    after (JobTime - 1) * 1000 ->
        WorkerPid ! harry_up,
        receive
            {done, WorkerPid} -> ok
        after 2000 ->
            exit(WorkerPid, youre_fired),
            io:format("superviser: Worker fired!~n")
        end
    end.


work(F) ->
    HandleWorkPid = self(),
    Fun = fun() ->
        io:format("handle_work: Start to do the work!~n"),
        F(),
        HandleWorkPid ! done
    end,
    spawn_link(Fun),
    handle_work().


handle_work() ->
    receive
        harry_up ->
            io:format("handle_work: Harry up, got it!~n"),
            handle_work();
        done ->
            io:format("handle_work: Work done!~n")
    after 1000 ->
        io:format("handle_work: I'm working!~n"),
        handle_work()
    end.

test_fun() ->
    receive
        aaa -> aaa
    after 5000 ->
        done
    end.

test() ->
    F = fun() -> worker:test_fun() end,
    worker:superviser({1, 10, F}).











