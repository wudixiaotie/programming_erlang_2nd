-module(q3).
-export([all_houses/0, find_house/1]).

all_houses() ->
  House1 = {
    house,
    {address, "2501"},
    {owner, "xiaotie"},
    {area, "133"}
  },

  House2 = {
    house,
    {address, "2502"},
    {owner, "zhangsan"},
    {area, "75"}
  },

  House3 = {
    house,
    {address, "2503"},
    {owner, "lisi"},
    {area, "75"}
  },

  House4 = {
    house,
    {address, "2504"},
    {owner, "wangwu"},
    {area, "90"}
  },

  [House1, House2, House3, House4].

find_house(Address) ->
  find_house(all_houses(), Address).

find_house([H|T], Address) ->
  {_,{_,HouseAddress},{_,_},{_,_}} = H,
  if
    HouseAddress == Address ->
      H;
    true ->
      find_house(T, Address)
  end.
