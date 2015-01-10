-module (twit_store).

-export ([init/1, store/2, fetch/1]).

-define (data_store_file_name, "twit_store.dat").
-define (data_head_size, 10).

init(K) ->
    {ok, IoDevice} = file:open(?data_store_file_name, [write, binary, raw]),
    file:pwrite(IoDevice, 0, integer_to_list(K)),
    file:close(IoDevice).

store(N, Buf) ->
    valid(N),
    case is_binary(Buf) of
        true ->
            Bin = Buf;
        false ->
            Bin = list_to_binary(Buf)
    end,
    case byte_size(Bin) > 140 of
        true ->
            exit("Buff is bigger than 140 bytes.");
        false ->
            ok
    end,
    {ok, IoDevice} = file:open(?data_store_file_name, [read, write, binary, raw]),
    file:pwrite(IoDevice, (N - 1) * 140 + ?data_head_size, Bin),
    file:close(IoDevice),
    ok.

fetch(N) ->
    valid(N),
    {ok, IoDevice} = file:open(?data_store_file_name, [read, binary, raw]),
    {ok, Bin} = file:pread(IoDevice, (N - 1) * 140 + ?data_head_size, 140),
    file:close(IoDevice),
    content_of_binary(Bin).

valid(N) ->
    K = data_store_file_length(),
    case K >= N of
        true ->
            ok;
        false ->
            ErrorMsg = lists:flatten(io_lib:format("Out of range! ~p is bigger than ~p.", [N, K])),
            error(ErrorMsg)
    end.

data_store_file_length() ->
    case file:open(?data_store_file_name, [read, binary, raw]) of
        {error, Reason} ->
            exit(Reason);
        {ok, IoDevice} ->
            {ok, Head} = file:pread(IoDevice, 0, ?data_head_size),
            file:close(IoDevice),
            list_to_integer(content_of_binary(Head))
    end.

content_of_binary(Bin) ->
    [ X || X <- binary_to_list(Bin), X /= 0].




