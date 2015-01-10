-module (exercises).

-export ([check_recompiling/1, small_file_md5_checksum/1,
          large_file_md5_checksum/1, file_md5_checksum/1]).

-import(lib_find, [files/3]).

-include_lib("kernel/include/file.hrl").


%% exercise 01
check_recompiling(FileName) ->
    case get_file_mtime(FileName, ".erl") of
        {error, ErrorMsg} ->
            {error, ErrorMsg};
        {ok, TimeStamp} ->
            FileNameWithoutExtension = string:substr(FileName, 1, string:len(FileName) - 4),
            FileName_beam = FileNameWithoutExtension ++ ".beam",
            case get_file_mtime(FileName_beam, ".beam") of
                {error, ErrorMsg} ->
                    {error, ErrorMsg};
                {ok, TimeStamp_beam} ->
                    case TimeStamp > TimeStamp_beam of
                        true -> FileName ++ " needs recompiling.";
                        false -> FileName ++ " dose not need recompiling."
                    end
            end
    end.

get_file_mtime(FileName, Extension) ->
    case filename:extension(FileName) of
        Extension ->
            case file:read_file_info(FileName) of
                {error, enoent} ->
                    {error, FileName ++ " does not exist."};
                {error, eacces} -> 
                    {error, "Missing search permission for one of the parent directories of the file."};
                {error, Reason} -> 
                    {error, Reason};
                {ok, FileInfo} ->
                    {ok, FileInfo#file_info.mtime}
            end;
        _ -> {error, FileName ++ " does not an erlang file."}
    end.



%% exercise 02
small_file_md5_checksum(File) ->
    statistics(wall_clock),
    case file:read_file(File) of
        {error, Why} ->
            {error, Why};
        {ok, Bin} ->
            MD5 = erlang:md5(Bin),
            {_, Time} = statistics(wall_clock),
            io:format("~p~n", [Time]),
            MD5
    end.


%% exercise 03
large_file_md5_checksum(File) ->
    statistics(wall_clock),
    case file:open(File, [read, binary, raw]) of
        {error, Reason} ->
            {error, Reason};
        {ok, IoDevice} ->
            MD5 = compute_chunk(IoDevice),
            {_, Time} = statistics(wall_clock),
            io:format("~p~n", [Time]),
            MD5
    end.

compute_chunk(IoDevice) ->
    Context = erlang:md5_init(),
    compute_chunk(Context, IoDevice, 0).

compute_chunk(Context, IoDevice, Index) ->
    case file:pread(IoDevice, Index, 5242880) of
        eof ->
            file:close(IoDevice),
            erlang:md5_final(Context);
        {ok, Data} ->
            NewContext = erlang:md5_update(Context, Data),
            compute_chunk(NewContext, IoDevice, Index + 5242880)
    end.


%% exercise 04
% "/Users/xiaotie/Movies/seen/The.Flash.2014.Season1.EP09_S-Files.mp4"
file_md5_checksum(File) ->
    FileSize = filelib:file_size(File),
    case FileSize > (1024 * 1024 * 100) of
        true ->
            large_file_md5_checksum(File);
        false ->
            small_file_md5_checksum(File)
    end.





