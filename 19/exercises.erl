-module (exercises).

-export ([func2mod/0]).

func2mod() ->
    {ok, LibDirList} = file:list_dir(code:lib_dir()),
    AllModuleNameList = get_all_module_names(LibDirList),
    ModuleList = [ ModuleName || { ModuleName, _ } <- code:all_loaded() ],
    io:format("AllModuleNameList: ~p~n", [AllModuleNameList]),
    io:format("ModuleList: ~p~n", [ModuleList]),
    ets_store(ModuleList).

get_all_module_names(LibDirList) -> get_all_module_names(LibDirList, []).
get_all_module_names([H|T], Result) ->
    get_all_module_names(T, [get_module_name(H)|Result]);
get_all_module_names([], Result) -> Result.


get_module_name(LibDirName) -> get_module_name(LibDirName, []).
get_module_name([H|T], Result) ->
    case H =/= $- of
        true -> get_module_name(T, [H|Result]);
        false -> lists:reverse(Result)
    end;
get_module_name([], Result) -> lists:reverse(Result).


ets_store(AllModuleNameList) ->
    TableId = ets:new(func2mod, [bag]),
    ets_store_loop_module(AllModuleNameList, TableId),
    ets:tab2file(TableId, "func2mod.tab"),
    ets:delete(TableId).


ets_store_loop_module([H|T], TableId) ->
    case is_atom(H) of
        true -> ModuleName = H;
        false -> ModuleName = list_to_atom(H)
    end,
    try apply(ModuleName, module_info, []) of
        [{_, FuncNameList}, _, _, _] ->
            ets_store_loop_func(FuncNameList, term_to_binary(ModuleName), TableId)
    catch
        _ -> error
    after
        ets_store_loop_module(T, TableId)
    end;
ets_store_loop_module([], _) -> ok.


ets_store_loop_func([H|T], ModuleName, TableId) ->
    true = ets:insert(TableId, {term_to_binary(H), ModuleName}),
    ets_store_loop_func(T, ModuleName, TableId);
ets_store_loop_func([], _, _) -> ok.