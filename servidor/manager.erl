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


% create_account or Login? %
start_player(Sock, GM) ->
    gen_tcp:send(Sock, <<"Register? (send 1)\n">>),
    gen_tcp:send(Sock, <<"Login?    (send 2)\n">>),
    receive
        {tcp, _, Ans}->
            case Ans of
                <<"1\n">> -> create_login(Sock, create_account, GM);
                <<"2\n">> -> create_login(Sock, login, GM);
                _         -> 
                    gen_tcp:send(Sock, <<"please try again\n">>),
                    start_player(Sock, GM)
            end
    end.

create_login(Sock, Mod, GM) ->
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
    ?MODULE ! {Mod, User, Pass, self()},
    receive
        {ok, ?MODULE}  ->
            Player = spawn(fun() -> player(Sock, GM, User, Pass) end),
            ?MODULE ! {login, User, Pass, Player},
            gen_tcp:send(Sock, <<"success\n\\help for command list\n">>),
            gen_tcp:controlling_process(Sock, Player);
        {Err, ?MODULE} ->
            gen_tcp:send(Sock, io_lib:format(<<"~p\n">>, [Err])),
            create_login(Sock, Mod, GM)
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
                                        <<"\\help - command list\n">>,
                                        <<"\\online - list of people online\n">>]),
                    player(Sock, GM, User, Pass);
                <<"\\online">> ->
                    ?MODULE ! {online, self()},
                    player(Sock, GM, User, Pass);
                _ ->  
                    ?MODULE ! {send, Msg, User},
                    player(Sock, GM, User, Pass)
            end;
        {tcp_closed, Sock} ->
            %io:format("user disconnected~n", []),
            ?MODULE ! {logout, User, self()};
        {tcp_error, Sock, _} ->
            io:format("tcp error~n", []);

        {online, List, ?MODULE} ->
            gen_tcp:send(Sock, lists:join(<<"\n">>, List)),
            gen_tcp:send(Sock, <<"\n">>),
            player(Sock, GM, User, Pass);
        {ok, ?MODULE} ->
            %gen_tcp:send(Sock, <<"ok, I can hear you\n">>),
            player(Sock, GM, User, Pass);
        {send, Msg, User, ?MODULE} ->
            gen_tcp:send(Sock, [User, <<" said: ">>, Msg]),
            player(Sock, GM, User, Pass);
        {Err, ?MODULE} ->
            gen_tcp:send(Sock, io_lib:format("~p\n", [Err])),
            player(Sock, GM, User, Pass)
    end.

login_manager(Map, GM) ->
    receive
        {create_account, User, Pass, From} ->
            case maps:find(User, Map) of
                error ->
                    From ! {ok, ?MODULE},
                    login_manager(maps:put(User, {Pass, true, From}, Map), GM);
                _     ->
                    From ! {user_exists, ?MODULE},
                    login_manager(Map, GM)
            end;
        {login, User, Pass, From} ->
            case maps:find(User, Map) of
                error ->
                    From ! {invalid_user, ?MODULE},
                    login_manager(Map, GM);
                {ok, {Value, _, _}} ->
                    case Value of
                        Pass ->
                            From ! {ok, ?MODULE},
                            login_manager(maps:update(User, {Pass, true, From}, Map), GM);
                        _ ->
                            From ! {invalid_pass, ?MODULE},
                            login_manager(Map, GM)
                    end
            end;
        {logout, User, _} ->
            case maps:find(User, Map) of
                error ->
                    login_manager(Map, GM);
                {ok, {Pass, _, Pid}}->
                    login_manager(maps:update(User, {Pass, false, Pid}, Map), GM)
            end;
        {online, From} ->
            From ! {online, maps:keys(maps:filter(fun(_, {_, On, _}) -> On end, Map)), ?MODULE},
            login_manager(Map, GM);
        {send, Msg, User} ->
            [ Pid ! {send, Msg, User, ?MODULE} || Pid <- lists:map(fun({_, _, Pid}) -> Pid end, 
                                                                   maps:values(maps:filter(fun(_, {_, On, _}) -> On end, Map))) ],
            login_manager(Map, GM);
        {ok, From} ->
            From ! {ok, ?MODULE},
            login_manager(Map, GM)
    end.

game_manager(_) ->
    receive
        _ -> io:fwrite("ola\n")
    end.

