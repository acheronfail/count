-module(count).
-export([start/1, count/2]).

start(Input) ->
    Target = list_to_integer(atom_to_list(hd(Input))),
    count(0, Target).

count(N, T) when N < T ->
    count((N+1) % 2000000000, T);
count(N, _) ->
    io:fwrite("~B~n", [N]),
    init:stop(0).
