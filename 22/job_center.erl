-module (job_center).

-export ([init/1, handle_call/3, handle_cast/2,
          handle_info/2, terminate/2, code_change/3,
          start_link/0, add_job/1, work_wanted/0,
          job_done/1, stop/0]).

-compile(export_all).

-behaviour (gen_server).

-include ("job_center.hrl").

% gen_server callbacks
init([]) ->
    JobCenter = #job_center{
                    waitting_queue = queue:new(),
                    processing_queue = queue:new(),
                    done_list = [],
                    job_number = 0
                },
    {ok, JobCenter}.

handle_call({in, F}, _From, #job_center{
                                waitting_queue = WaittingQueue,
                                job_number = JobNumber
                            } = JobCenter) ->

    NewWaittingQueue = queue:in({JobNumber, F}, WaittingQueue),
    NewJobNumber = JobNumber + 1,
    NewJobCenter = JobCenter#job_center{
        waitting_queue = NewWaittingQueue,
        job_number = NewJobNumber
    },
    {reply, JobNumber, NewJobCenter};

handle_call({out}, _From, #job_center{
                            waitting_queue = WaittingQueue,
                            processing_queue = ProcessingQueue
                          } = JobCenter) ->

    case queue:out(WaittingQueue) of
        {empty, NewWaittingQueue} ->
            {reply, no, JobCenter};
        {{value, JobItem}, NewWaittingQueue} ->
            NewProcessingQueue = queue:in(JobItem, ProcessingQueue),
            NewJobCenter = JobCenter#job_center{
                waitting_queue = NewWaittingQueue,
                processing_queue = NewProcessingQueue
            },
            {reply, JobItem, NewJobCenter}
    end;

handle_cast(_Msg, State) -> {noreply, State}.
handle_info(_info, State) -> {noreply, State}.
terminate(_Reason, _Status) -> ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.

% server function
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop() -> gen_server:call(?MODULE, stop).

add_job(F) -> gen_server:call(?MODULE, {in, F}).
work_wanted() -> gen_server:call(?MODULE, {out}).
job_done(JobNumber) -> gen_server:call(?MODULE, {done, JobNumber}).

