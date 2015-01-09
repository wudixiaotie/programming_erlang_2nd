-module (job_center).

-export ([init/1, handle_call/3, handle_cast/2,
          handle_info/2, terminate/2, code_change/3,
          start/0, add_job/1, work_wanted/0,
          job_done/1, stop/0]).

-compile(export_all).

-behaviour (gen_server).

-include ("job_center.hrl").

% gen_server callbacks
init([]) ->
    JobQueue = #job_queue{},
    {ok, JobQueue}.

handle_call({in, F}, _From, #job_queue{
                                waitting = Waitting,
                                job_number = JobNumber
                            } = JobQueue) ->

    NewWaitting = queue:in({JobNumber, F}, Waitting),
    NewJobNumber = JobNumber + 1,
    NewJobQueue = JobQueue#job_queue{
        waitting = NewWaitting,
        job_number = NewJobNumber
    },
    {reply, JobNumber, NewJobQueue};

handle_call({out}, _From, #job_queue{
                            waitting = Waitting,
                            processing = Processing
                          } = JobQueue) ->

    case queue:out(Waitting) of
        {empty, _NewWaitting} ->
            {reply, no, JobQueue};
        {{value, {JobNumber, F} = JobItem}, NewWaitting} ->
            NewProcessing = dict:store(JobNumber, F, Processing),
            NewJobQueue = JobQueue#job_queue{
                waitting = NewWaitting,
                processing = NewProcessing
            },
            {reply, JobItem, NewJobQueue}
    end;

handle_call({done, JobNumber}, _From, #job_queue{
                            processing = Processing,
                            done = Done
                          } = JobQueue) ->

    case dict:find(JobNumber, Processing) of
        error ->
            {reply, error, JobQueue};
        {ok, F} ->
            NewProcessing = dict:erase(JobNumber, Processing),
            NewDone = [F|Done],
            NewJobQueue = JobQueue#job_queue{
                processing = NewProcessing,
                done = NewDone
            },
            {reply, ok, NewJobQueue}
    end;

handle_call(stop, _From, JobQueue) ->
    {stop, normal, stopped, JobQueue}.

handle_cast(_Msg, State) -> {noreply, State}.
handle_info(_info, State) -> {noreply, State}.
terminate(_Reason, _Status) -> ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.

% server function
start() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop() -> gen_server:call(?MODULE, stop).

add_job(F) -> gen_server:call(?MODULE, {in, F}).
work_wanted() -> gen_server:call(?MODULE, {out}).
job_done(JobNumber) -> gen_server:call(?MODULE, {done, JobNumber}).

