-module (worker).
-export ([start/1]).

-record (number, {id,num,check}).

start(Num) ->
	inets:start(),
	go(Num).


go(0) -> ok;
go(Num) ->
	spawn(fun() ->getnums()end),
	go(Num-1).

getnums() ->
	Numbers = gen_server:call(loopnum,getnum),
	case Numbers of
		ok ->
			getnums();
		[ID,Number] ->	
		loopN([ID,Number])
	end.

loopN([ID,Number]) ->
	User_Agent = "User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.131 Safari/537.36",
	Referer = "http://service.js.10086.cn/wscz.jsp",	
	case catch httpc:request(post,{"http://service.js.10086.cn/actionDispatcher.do",[{"User-Agent", User_Agent},{"Referer",Referer}],"application/x-www-form-urlencoded", lists:concat(["reqUrl=" ,"copyOfNetPay" ,"&busiNum=" ,"WSCZYL","&mobile=",Number,"&fPayType=","check"])},[],[]) of
		{ok, {_,_,Body}} ->
			case catch json_eep:json_to_term(Body) of
				{Return} ->
					Success = proplists:get_value(<<"success">>, Return),
					case Success of
						true ->
							V = ets:update_element(number,ID,{#number.check,1}),
%% 							io:format("V:~p~n",[[Number,V]]),
							% V = ets:lookup(number,ID),
							% V = ets:select(number,[{#number{id='_',num='$1',check=0},[],['$1']}]),
							getnums();
							% case gen_server:call(loopnum,{true,Number}) of
							% 	true ->
							% 		getnums();
							% 		% ok;
							% 	_ ->
							% 		gen_server:call(loopnum,{true,Number}),
							% 		getnums()
									
							% end;	
							% io:format("Success:~p~n",[Success]),
							% getnums();
						false ->
 							io:format("V:~p~n",[Number]),
%% 							io:format("Success:~p",[Success]),
							getnums();
						_ ->
							loopN([ID,Number])	
					end;
				_ ->
					loopN([ID,Number])	
			end;	 
			
		_ ->
			loopN([ID,Number])			
	end.
