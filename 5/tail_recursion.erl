-module (tail_recursion).
-export ([normal/1, tail/1]).

normal(N) when N > 0 -> N + normal(N - 1);
normal(0) -> 0.

tail(N) -> tail(N, 0).

tail(N, Result) when N > 0 -> tail(N - 1, N + Result);
tail(0, Result) -> Result.