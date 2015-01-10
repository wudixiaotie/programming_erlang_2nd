-module (exercise9_4).
-export ([show_point_add/2]).
-import (exercise9_1, [point_add/2]).

-spec show_point_add(exercise9_1:point(), exercise9_1:point()) ->
    exercise9_1:point().

show_point_add(A, B) ->
    exercise9_1:point_add(A, B).