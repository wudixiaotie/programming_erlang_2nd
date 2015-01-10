-module (name_server).

% -export ([init/0, ]).

-define (SERVER, ?MODULE).

-compile(export_all).

start() ->
    server1:start(?SERVER, ?MODULE).

find(Name) -> server1:rpc(?SERVER, {find, Name}).
add(Name, Place) -> server1:rpc(?SERVER, {add, Name, Place}).

init() -> dict:new().
handle({add, Name, Place}, Dict) -> {ok, dict:store(Name, Place, Dict)};
handle({find, Name}, Dict) -> {ok, dict:find(Name, Dict), Dict}.

