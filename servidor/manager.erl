-module(manager).
-export([server/1]).

server(Port) ->
    GM = spawn(fun()-> game_manager([]) end),
    LM = spawn(fun()-> login_manager(#{},GM) end),
    register(?MODULE, LM),
    {ok, LSock} = gen_tcp:listen(Port, [binary, {packet, line}]),
    acceptor(LSock, GM).

acceptor(LSock, GM) ->
    {ok, Sock} = gen_tcp:accept(LSock),
    Player = spawn(fun() -> start_player(Sock, GM) end),
    gen_tcp:controlling_process(Sock, Player),
    acceptor(LSock, GM).


% create or Login? %
start_player(Sock, GM) ->
    gen_tcp:send(Sock, <<"Register? (send 1)\n">>),
    gen_tcp:send(Sock, <<"Login?    (send 2)\n">>),
    receive
        {tcp, _, Ans}->
            case Ans of
                <<"1\n">> -> create(Sock, GM);
                <<"2\n">> -> login(Sock, GM);
                _         -> 
                    gen_tcp:send(Sock, <<"please try again\n">>),
                    start_player(Sock, GM)
            end
    end.

create(Sock, GM) ->
    gen_tcp:send(Sock, <<"User Name:\n">>),
    User = receive
               {tcp, _, Ans_User}->
                   string:chomp(Ans_User)
           end,
    gen_tcp:send(Sock, <<"Password:\n">>),
    Pass = receive
               {tcp, _, Ans_Pass}->
                   string:chomp(Ans_Pass)
           end,
    ?MODULE ! {create, User, Pass, self()},
    receive
        {ok, ?MODULE}  ->
            Player = spawn(fun() -> player(Sock, GM, User, Pass) end),
            gen_tcp:send(Sock, <<"success\n\\help for command list\n">>),
            gen_tcp:controlling_process(Sock, Player);
        {Err, ?MODULE} ->
            gen_tcp:send(Sock, io:format(<<"~p\n">>, [Err])),
            create(Sock, GM)
    end.

login(Sock, GM) ->
    gen_tcp:send(Sock, <<"User Name:\n">>),
    User = receive
               {tcp, _, Ans_User}->
                   string:chomp(Ans_User)
           end,
    gen_tcp:send(Sock, <<"Password:\n">>),
    Pass = receive
               {tcp, _, Ans_Pass}->
                   string:chomp(Ans_Pass)
           end,
    ?MODULE ! {login, User, Pass, self()},
    receive
        {ok, ?MODULE}  ->
            Player = spawn(fun() -> player(Sock, GM, User, Pass) end),
            gen_tcp:send(Sock, <<"success\n\\help for command list\n">>),
            gen_tcp:controlling_process(Sock, Player);
        {Err, ?MODULE} ->
            gen_tcp:send(Sock, io:format(<<"~p\n">>, [Err])),
            login(Sock, GM)
    end.


% Processos Principais %

player(Sock, GM, User, Pass) ->
    receive
        {tcp, _, Msg} -> 
            case string:chomp(Msg) of
                <<"\\ok">> -> 
                    ?MODULE ! {ok, self()},
                    player(Sock, GM, User, Pass);
                <<"\\help">> -> 
                    gen_tcp:send(Sock, [<<"\\ok - check the connection\n">>,
                                        <<"\\help - command list\n">>]),
                    player(Sock, GM, User, Pass);
                _ ->  
                    gen_tcp:send(Sock, Msg),
                    player(Sock, GM, User, Pass)
            end;
        {ok, ?MODULE} ->
            gen_tcp:send(Sock, <<"ok, I can hear you\n">>),
            player(Sock, GM, User, Pass)
    end.


login_manager(Map, GM) ->
    receive
        {create, User, Pass, From} ->
            case maps:find(User, Map) of
                error ->
                    From ! {ok, ?MODULE},
                    login_manager(maps:put(User, {Pass, true}, Map), GM);
                _     ->
                    From ! {user_exists, ?MODULE},
                    login_manager(Map, GM)
            end;
        {login, User, Pass, From} ->
            case maps:find(User, Map) of
                error ->
                    From ! {invalid_user, ?MODULE},
                    login_manager(Map, GM);
                {ok, {Value, _}} ->
                    if
                        Value == Pass ->
                            From ! {ok, ?MODULE},
                            login_manager(maps:remove(User, Map), GM);
                        true ->
                            From ! {invalid_pass, ?MODULE},
                            login_manager(Map, GM)
                    end
            end;
        {ok, From} ->
            From ! {ok, ?MODULE}
    end.


game_manager(_) ->
    receive
        _ -> io:fwrite("ola\n")
    end.

