-module (myfile).
-export ([read/1]).

read(File) ->
    case file:read_file(File) of
        { ok, Bin } -> { ok, Bin };
        { error, Why } -> throw(Why)
    end.