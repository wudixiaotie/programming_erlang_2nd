-module (mod_statistic).
-export ([statistic/0]).

statistic() ->
    ModuleList = [ ModuleName || { ModuleName, _ } <- code:all_loaded() ],
    FunctionCountMap = function_count_map(ModuleList).
    % FunctionMostCommon = function_most_common(AllFunctionList),
    % FunctionUnique = function_unique(AllFunctionList),
    % ModuleExportMost = module_export_most(ModuleList),
    % {
    %     module_exports_the_most_functions: ModuleExportMost
    % }.

function_count_map(ModuleList) ->
    AllFunctionList = module_function_list(ModuleList, []),
    function_count_map(AllFunctionList, #{}).

% 获取所有函数的列表
module_function_list([], Result) -> Result;
module_function_list([ H | T ], Result) ->
    [ { _, CurrentFunList }, _, _, _ ] = H:module_info(),
    module_function_list(T, lists:append(CurrentFunList, Result)).

% 根据所有函数的列表，统计各个函数的出现次数
function_count_map([ H | T ], #{ H := Count } = Result) ->
    module_function_list(T, Result#{ H := Count + 1 });
function_count_map([ H | T ], Result) ->
    module_function_list(T, Result#{ H := 1 });
function_count_map([], Result) -> Result.


module_export_most([ H | T ]) ->
    [ { _, CurrentFunList }, _, _, _ ] = H:module_info(),
    module_export_most(T, { H, length(CurrentFunList) }).

module_export_most([], Result) -> Result;
module_export_most([ H | T ], Result) ->
    [ { _, CurrentFunList }, _, _, _ ] = H:module_info(),
    { _, MaxLength } = Result,
    CurrentLength = length(CurrentFunList),
    case MaxLength < CurrentLength of
        true -> module_export_most(T, { H, CurrentLength });
        false -> module_export_most(T, Result)
    end.


function_most_common([ H | T ]) -> function_most_common(T, []).

% function_most_common([ H | T ], Result) ->

    
% function_unique()