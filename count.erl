-module(count).
-export([start/0, loop/1]).

start() ->
    loop(0).

loop(N) when N < 1000000000 ->
    loop(N+1);
loop(N) ->
    io:fwrite("~B~n", [N]),
    ok.
