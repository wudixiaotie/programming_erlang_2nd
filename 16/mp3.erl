-module (mp3).

-export ([get_info/1]).

get_info(FileName) ->
    case file:open(FileName, [read, binary, raw]) of
        {ok, FileStream} ->
            FileSize = filelib:file_size(FileName),
            {ok, Tag} = file:pread(FileStream, FileSize - 128, 128),
            io:format("~p~n", [parse_v1_tag(Tag)]);
        _Error ->
            error
    end.

parse_v1_tag(<<$T, $A, $G,
                Title:30/binary, Artist:30/binary,
                Album:30/binary, Year:4/binary,
                Comment:28/binary, 0:8, Track:8, Genre:8>>) ->
    {"ID3v1.1",
     [{title, trim(Title)}, {artist, trim(Artist)}, {album, trim(Album)},
      {year, Year}, {comment, Comment}, {track, trim(<<Track>>)},
      {genre, trim(<<Genre>>)}]};

parse_v1_tag(<<$T, $A, $G,
                Title:30/binary, Artist:30/binary,
                Album:30/binary, Year:4/binary,
                Comment:30/binary, Genre:8>>) ->
    {"ID3v1",
     [{title, trim(Title)}, {artist, trim(Artist)}, {album, trim(Album)},
      {year, Year}, {comment, Comment}, {genre, trim(<<Genre>>)}]};

parse_v1_tag(_) ->
    error.

trim(Bin) ->
    list_to_binary(trim_blanks(binary_to_list(Bin))).
trim_blanks(X) -> lists:reverse(skip_blanks_and_zero(lists:reverse(X))).

skip_blanks_and_zero([$\s|T]) -> skip_blanks_and_zero(T);
skip_blanks_and_zero([0|T]) -> skip_blanks_and_zero(T);
skip_blanks_and_zero(X) -> X.