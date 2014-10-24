erl_pcik
========
erl -pa ebin/ -pa deps/*/ebin/
num_app:start(num_sup,[]).
worker:start(输入线程条数).
