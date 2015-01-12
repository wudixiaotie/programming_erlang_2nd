-module (motor_controller).
-export ([add_event_handler/0]).
-compile(export_all).

add_event_handler() ->
    event_handler:add_handler(errors, fun controller/1).

controller(too_hot) ->
    io:format("Turn off the motor!~n");
controller(X) ->
    io:format("~w ignore event: ~p~n", [?MODULE, X]).


test() ->
    case whereis(errors) of
        undefined ->
            void;
        Pid ->
           exit(Pid, kill)
    end,
    event_handler:make(errors),
    add_event_handler(),
    event_handler:event(errors, cool),
    event_handler:event(errors, hot),
    event_handler:event(errors, too_hot).
