-module(num_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
	%启动数据库
	start_mysql(),
	% inets:start(),
	% zlib:open(),
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
	Loopnum = ?CHILD(loopnum,worker),
	% Simple = ?CHILD(simple_sup,supervisor),
    {ok, { {one_for_one, 5, 10}, [Loopnum]} }.


%数据库连接
start_mysql() ->
	crypto:start(),
	application:start(emysql),
	emysql:add_pool(pool,1,
		"root","psswd","127.0.01",
			3306,"datadbname",utf8).
