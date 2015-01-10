-module (exercises_chapter5).

-export ([count_characters/1, map_search_pred/2]).

count_characters(Str) ->
    count_characters(Str, #{}).

% count_characters([H|T], #{ H => N }=X) ->
%     count_characters(T, X#{ H := N+1 });
% count_characters([H|T], X) ->
%     count_characters(T, X#{ H => 1 });

count_characters([H|T], Map) when is_map(Map) ->
    N = maps:get(H, Map, 0),
    count_characters(T, maps:put(H, N + 1, Map));
count_characters([], Map) ->
    Map.


% exercise 1
% exercise 2
% Write a function map_search_pred(Map, Pred) that
% returns the first element {Key,Value} in the map for which Pred(Key, Value) is true.
map_search_pred(Map, Pred) ->
    map_search_pred(maps:keys(Map), Map, Pred).

map_search_pred([H|T], Map, Pred) ->
    Val = maps:get(H, Map),
    case Pred(H, Val) of
        true -> {H, Val};
        _ -> map_search_pred(T, Map, Pred)
    end;
map_search_pred([], _, _) -> 
    {}.