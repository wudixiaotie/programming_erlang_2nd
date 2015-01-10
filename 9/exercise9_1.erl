-module (exercise9_1).
-export ([point_add/2]).

-spec point_add(point(), point()) -> point().
-opaque point() :: {integer(), integer()}.
-export_type ([point/0]).


point_add({A1, A2}, {B1, B2}) ->
    {(A1+B1), (A2+B2)}.

% Provide detailed type specifications for all the arguments to the exported 
% functions in the module. Try to tightly constrain the arguments to exported 
% functions as much as possible. For example, at first sight you might reason 
% that an argument to a function is an integer, but after a little more thought, 
% you might decide that the argument is a positive integer or even a bounded 
% integer. The more precise you can be about your types, the better results 
% you will get with the dialyzer. Also, add precise guard tests to your code 
% if possible. This will help with the program analysis and will often help 
% the compiler generate better-quality code. sling