-module(num_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(StartType, _StartArgs) ->
    StartType:start_link().

stop(_State) ->
    ok.
