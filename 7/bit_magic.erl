-module (bit_magic).
-export ([find_sync/2, reverse_byte/1, reverse_bit/1, term_to_packet/1,
    packet_to_term/1, test/0]).

find_sync(Bin, N) ->
    case is_header(N, Bin) of
        { ok, Len1, _ } ->
            case is_header(N + Len1, Bin) of
                { ok, Len2, _ } ->
                    case is_header(N + Len1 + Len2, Bin) of
                        { ok, _, _ } ->
                            { ok, N };
                        error ->
                            find_sync(Bin, N + 1)
                    end;
                error ->
                    find_sync(Bin, N + 1)
            end;
        error ->
            find_sync(Bin, N + 1)
    end.

is_header(N, Bin) ->
    unpack_header(get_word(N, Bin)).

get_word(N, Bin) ->
    { _, <<C:4/binary, _/binary>> } = split_binary(Bin, N),
    C.

unpack_header(X) ->
    try decode_header(X)
    catch
        _:_ -> error
    end.

decode_header(X) -> 0.




% practise 1
reverse_byte(B) -> reverse_byte(B, <<>>).

reverse_byte(<<>>, Result) -> Result;
reverse_byte(<< X:1/binary, Rest/binary >>, Result) ->
    reverse_byte(Rest, << X/binary, Result/binary >>).


% practise 5
reverse_bit(B) -> reverse_bit(B, <<>>).

reverse_bit(<<>>, Result) -> Result;
reverse_bit(<< X:1/bits, Rest/bits >>, Result) ->
    reverse_bit(Rest, << X/bits, Result/bits >>).


% practise 2
term_to_packet(Term) ->
    Bin = term_to_binary(Term),
    Size = byte_size(Bin),
    Head = << Size:4/unit:8 >>,
    << Head/binary, Bin/binary >>.


% practise 3
packet_to_term(<<_Size:4/binary, Data/binary>>) -> binary_to_term(Data).


% practise 4
test() ->
    Term_origin = "abcd123efg",
    Packet = term_to_packet(Term_origin),
    Term = packet_to_term(Packet),
    Term = Term_origin,
    tests_worked.