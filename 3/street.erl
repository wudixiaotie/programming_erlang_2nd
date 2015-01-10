-module(street).
-export([init/0]).

init() ->
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
  Street = [House1, House2, House3, House4],
  receive
    {Somebody, {find_house, Address}} ->
      Somebody ! {self(), find_house(Street, Address)};
    {Worker, {build_house, House}} ->
      Worker ! {self(), build_house(Street, House)}
  end,
  init().

find_house([H|T], Address) ->
  {_,{_,HouseAddress},{_,_},{_,_}} = H,
  if
    HouseAddress == Address ->
      H;
    T == [] ->
      {error, "Can't find the house by address."};
    true ->
      find_house(T, Address)
  end.

build_house(Street, House) ->
  