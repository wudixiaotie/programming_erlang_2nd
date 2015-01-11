-module (worker).

-compile(export_all).

% get_a_job_and_do() ->
%     JobInfo = ?MODULE:work_wanted(),
%     spawn_link(fun() -> worker_superviser(JobInfo) end),
%     worker_superviser()

superviser({JobNumber, JobTime, F}) ->
    {WorkerPid, _Ref} = spawn_monitor(fun() -> work(JobNumber, F) end),
    receive
        {done, WorkerPid} ->
            ok;
        {'DOWN', _Ref, process, WorkerPid, _Why} ->
            % job_center:job_failed(JobNumber)
            io:format("==========工作失败~n")
    after (JobTime - 1) * 1000 ->
        WorkerPid ! hurry_up,
        receive
            {done, WorkerPid} -> ok
        after 2000 ->
            exit(WorkerPid, youre_fired)
        end
    end.


work(JobNumber, F) ->
    HandlerPid = spawn_link(fun() -> handle_work() end),
    Fun = fun() ->
        F(),
        HandlerPid ! {done, JobNumber}
    end,
    spawn_link(Fun).
handle_work() ->
    receive
        harry_up ->
            io:format("Harry up, got it!~n");
        {done, JobNumber} ->
            io:format("Work done!~n"),
            % job_center:job_done(JobNumber),
            io:format("==========工作完成~n")
    after 1000 ->
        io:format("I'm working!~n"),
        handle_work()
    end.

test() ->
    receive
        aaa -> aaa
    end.













