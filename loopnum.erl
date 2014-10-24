-module(loopnum).
-behaviour(gen_server).
-define(SERVER, ?MODULE).

%% ------------------------------------------------------------------
%% API Function Exports
%% ------------------------------------------------------------------

-export([start_link/0]).

%% ------------------------------------------------------------------
%% gen_server Function Exports
%% ------------------------------------------------------------------

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

%% ------------------------------------------------------------------
%% API Function Definitions
%% ------------------------------------------------------------------
-record (number, {id,num,check}).


start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%% ------------------------------------------------------------------
%% gen_server Function Definitions
%% ------------------------------------------------------------------

init([]) ->
	ets:new(number,[public,set,named_table,{keypos,#number.id}]),
	% ets:new(number,[public,set,named_table]),
	ets:new(mark,[public,set,named_table]),
	getsegment(),
    {ok, []}.

%%获取号码
handle_call(getnum,_From,State) ->
	Reply = getnum(),
	{reply,Reply,State};

% %%删除非空号
% handle_call({true,Numbers},_From,State) ->
% 	% Value = ets:match(number,{number,'$1',Numbers}),
% 	% Reply = case Value of
% 	% 		[[ID]] ->
% 	% 			ets:delete(number,ID);
% 	% 		_ ->
% 	% 			io:format("Value.....................:~p~n",[[Numbers,Value]])	
% 	% 	end,
% 	{reply,Reply,State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.



handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% ------------------------------------------------------------------
%% Internal Function Definitions
%% ------------------------------------------------------------------

getsegment() ->
	% {_,_,_,[[Segment,Code]],_}
	% {_,_,_,Values,_} = emysql:execute(pool,<<"SELECT segment,codels FROM nosegment WHERE area like '江苏%' AND remark like '%移动%' AND count='0' LIMIT 1;">>),
	[{_,_,_,[[Segment,Code]],_},_] = emysql:execute(pool,<<"call selectsegment()">>),
	% io:format("Segment:~p~n",[[Segment,Code]]),
	ets:insert(mark,{1,1,Segment,Code}),
	Phonenum = Segment * 10000,
	loopsegment(Phonenum,1).
	% V = ets:match(number,'$1'),
	% io:format("V:~p~n",[V]).
	% loop(V,Segment).

loopsegment(Phonenum,10001) ->ok;
loopsegment(Phonenum,Num) ->
	% Insert = #number{id=Num,num=integer_to_list(Phonenum)},
	Insert = #number{id=Num,num=Phonenum,check=0},
	ets:insert(number,Insert),
	loopsegment(Phonenum+1,Num+1).

getnum() ->
	[{_,F,S,C}] = ets:lookup(mark,1),
	if
		F == 10001 ->
			update(S,C),
			getsegment();
		true ->		
			[{_,ID,Number,_}] = ets:lookup(number,F),
			ets:update_counter(mark,1,+1),
			%GGG = ets:update_counter(mark,1,+1),
			%io:format("GGGGGGGGGGGGGGGGGG:~p~n",[GGG]),
			[ID,Number]
	end.

update(S,C) ->
	SQL = "update nosegment SET runcount=1,updatetime=UNIX_TIMESTAMP(now())  WHERE segment="++integer_to_list(S),
	emysql:execute(pool,list_to_binary(SQL)),
	V = ets:select(number,[{#number{id='_',num='$1',check=0},[],['$1']}]),
	nullnumber(V,C),
    V1 = ets:select(number,[{#number{id='_',num='$1',check=1},[],['$1']}]),
	nonullnumber(V1,C).

%%是空号 
nullnumber(V,C)->
	        case V of
				[]->
					ok;
				_->
					
					VA = lists:flatten(io_lib:write(V)),
					Codes = lists:append("0",integer_to_list(C)),
					% io:format("Codes:~p~n",[Codes]),
					SQL1 = "call updatesegment('"++Codes++"',\""++VA++"\")",
					AAA = emysql:execute(pool,list_to_binary(SQL1)),
					io:format("nullnulnulnulnull:~p~n",[AAA])
			end.
%%             io:format("nullAAAAAAAAAAAA:~p~n",[V]).
%% 不是空号
nonullnumber(V1,C)->
		      case V1 of
				[]->
					ok;
				_->
				    VA = lists:flatten(io_lib:write(V1)),
					Codes = lists:append("0",integer_to_list(C)),
					% io:format("Codes:~p~n",[Codes]),
					SQL1 = "call updatesegmentnonull('"++Codes++"',\""++VA++"\")",
					AAA = emysql:execute(pool,list_to_binary(SQL1)),
					io:format("nonononononull:~p~n",[AAA])
			  end.
%% 			io:format("onnullBBBBBBBBBBBB:~p~n",[V1]).
				   
						

	
