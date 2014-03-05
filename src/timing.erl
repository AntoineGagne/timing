-module(timing).

-export([
    function/1,
    function/2,
    function/3
]).

-define(N, 20000).
-define(P, 20).

%% public
function(Fun) ->
    function(Fun, ?N).

function(Fun, N) ->
    function(Fun, N, ?P).

function(Fun, N, P) ->
    function_spawn_loop(self(), Fun, N, P),
    Samples = lists:append(receive_loop(P)),
    bear:get_statistics(Samples).

%% private
function_loop(_Fun, 0) ->
    [];
function_loop(Fun, N) ->
    [function_time(Fun) | function_loop(Fun, N - 1)].

function_spawn_loop(_Pid, _Fun, _N, 0) ->
    ok;
function_spawn_loop(Pid, Fun, N, P) ->
    spawn_link(fun () -> Pid ! function_loop(Fun, trunc(N / P)) end),
    function_spawn_loop(Pid, Fun, N, P - 1).

function_time(Fun) ->
    Timestamp = os:timestamp(),
    Fun(),
    timer:now_diff(os:timestamp(), Timestamp).

receive_loop(0) ->
    [];
receive_loop(N) ->
    [receive X -> X end | receive_loop(N - 1)].
