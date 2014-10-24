erl_pcik
========

首先准备 emysql 连接库 这里可以下载  http://laoyaos.iteye.com/blog/2022930



有两种启动方法 （rebar 比较简单 安装rebar方法 http://laoyaos.iteye.com/blog/2022679）
rebar 启动方式

    erl -pa ebin/ -pa deps/*/ebin/
    
    num_app:start(num_sup,[]).
    
    worker:start(输入线程条数).
普通启动方式

    c:cd("目标文件路径").
      
    c(目标文件名).
      
    num_app:start(num_sup,[]).
      
    worker:start(输入线程条数).
    
    Good Luck!
