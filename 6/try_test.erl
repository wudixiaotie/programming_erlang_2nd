-module (try_test).
-export ([demo1/0, demo2/0]).

generate_exception(1) -> a;
generate_exception(2) -> throw(a);
generate_exception(3) -> exit(a);
generate_exception(4) -> {'EXIT', a};
generate_exception(5) -> error(a).

demo1() -> [catcher(I) || I <- [1,2,3,4,5]].

catcher(N) ->
    try generate_exception(N) of
        Val -> ["OK", {N, normal, Val}]
    catch
        throw:X -> ["ERROR", {N, caught, thrown, X}];
        exit:X -> ["ERROR", {N, caught, exited, X}];
        error:X -> ["ERROR", {N, caught, error, X}]
    end.

demo2() ->
    [{I, (catch generate_exception(I))} || I <- [1,2,3,4,5]].