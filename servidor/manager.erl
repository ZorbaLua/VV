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
        {ok, Level, Exp, ?MODULE}  ->
            gen_tcp:send(Sock, <<"success\n\\help for command list\n">>),
            player(Sock, {User, Pass, Level, Exp}, GM);
        {Err, ?MODULE} ->
            gen_tcp:send(Sock, io_lib:format(<<"~p\n">>, [Err])),
            create_login(Sock, Mod, GM)
    end.

% Processos Principais %
% Player : {User, Pass, Level, Exp}
player(Sock, Player, GM) ->
    {User, Pass, Level, Exp} = Player,
    receive
        {tcp, _, Msg} -> 
            case string:split(string:chomp(Msg), <<" ">>, all) of
                [<<"\\help">>] -> 
                    gen_tcp:send(Sock, [<<"\\help - command list\n">>,
                                        <<"\\online - list of people online\n">>,
                                        <<"\\info - your info\n">>]),
                    player(Sock, Player, GM);
                [<<"\\online">>] ->
                    ?MODULE ! {online, self()},
                    player(Sock, Player, GM);
                [<<"\\info">>] ->
                    gen_tcp:send(Sock, [<<"Username: ">>, User, <<"\n">>,
                                        <<"Password: ">>, Pass, <<"\n">>,
                                        io_lib:format(<<"Level: ~p~n">>,   [Level]),
                                        io_lib:format(<<"Exp: ~p~n">>,       [Exp])]),
                    player(Sock, Player, GM);
                _ ->  
                    ?MODULE ! {send, Msg, User},
                    player(Sock, Player, GM)
            end;
        {tcp_closed, _} ->
            ?MODULE ! {logout, User, self()};
        {tcp_error, _, _} ->
            io:format("tcp error~n", []),
            ?MODULE ! {logout, User, self()};

        {online, List, ?MODULE} ->
            gen_tcp:send(Sock, lists:join(<<"\n">>, List)),
            gen_tcp:send(Sock, <<"\n">>),
            player(Sock, Player, GM);
        {ok, ?MODULE} ->
            %gen_tcp:send(Sock, <<"ok, I can hear you\n">>),
            player(Sock, Player, GM);
        {send, Msg, User, ?MODULE} ->
            gen_tcp:send(Sock, [User, <<" said: ">>, Msg]),
            player(Sock, Player, GM);
        {Err, ?MODULE} ->
            gen_tcp:send(Sock, io_lib:format("~p\n", [Err])),
            player(Sock, Player, GM)
    end.

% Map : #{ User => {Pass, On, Level, Exp, Pid} }
login_manager(Map, GM) ->
    receive
        {create_account, User, Pass, From} ->
            case maps:find(User, Map) of
                error ->
                    From ! {ok, 1, 0, ?MODULE},
                    login_manager(maps:put(User, {Pass, true, 1, 0, From}, Map), GM);
                _     ->
                    From ! {user_exists, ?MODULE},
                    login_manager(Map, GM)
            end;
        {login, User, Pass, From} ->
            case maps:find(User, Map) of
                error ->
                    From ! {invalid_user, ?MODULE},
                    login_manager(Map, GM);
                {ok, {Value, _, _, Level, Exp}} ->
                    case Value of
                        Pass ->
                            From ! {ok, Level, Exp, ?MODULE},
                            login_manager(maps:update(User, {Pass, true, Level, Exp, From}, Map), GM);
                        _ ->
                            From ! {invalid_pass, ?MODULE},
                            login_manager(Map, GM)
                    end
            end;
        {logout, User, _} ->
            case maps:find(User, Map) of
                error ->
                    login_manager(Map, GM);
                {ok, {Pass, _, Pid, Level, Exp}}->
                    login_manager(maps:update(User, {Pass, false, Level, Exp, Pid}, Map), GM)
            end;
        {online, From} ->
            From ! {online, maps:keys(maps:filter(fun(_, {_, On, _, _, _}) -> On end, Map)), ?MODULE},
            login_manager(Map, GM);
        {send, Msg, User} ->
            [ Pid ! {send, Msg, User, ?MODULE} || Pid <- lists:map(fun({_, _, _, _, Pid}) -> Pid end, 
                                                                   maps:values(maps:filter(fun(_, {_, On, _, _, _}) -> On end, Map))) ],
            login_manager(Map, GM);
        {ok, From} ->
            From ! {ok, ?MODULE},
            login_manager(Map, GM)
    end.

%Player : {User, Pid}
%GInfo  : {{x1, y1, a1}, {x2, y2, a2}, [VVm], {VVd, VVd}, Xlim, Ylim}
game(Player1, Player2, GInfo) ->
    {_, Pid1} = Player1,
    {_, Pid2} = Player2,
    receive
        send_now -> 
            Pid2 ! Pid1 ! {game_info, GInfo}
    end.

% Player : {User, Level, Pid}
game_manager(Players) ->
    receive
        {play, User, Level, From} -> 
            case lists:filter(fun({_, L, _}) -> (L==Level) or (L==Level+1) or (L==Level-1) end, Players) of
                [] -> 
                    game_manager(Players ++ [{User, Level, From}]);
                [H | _] ->
                    {User_H, _, Pid_H} = H,
                    Game = spawn(fun() -> game({User_H, Pid_H}, {User, From}, 
                                               {{100,200,0}, {300,200,math:pi()}, 
                                                [], {{rand:uniform()*400, rand:uniform()*400}, 
                                                     {rand:uniform()*400, rand:uniform()*400}}, 
                                                400, 400}) end),
                    {ok, _} = timer:send_interval(20, Game, update),
                    {ok, _} = timer:send_interval(100, Game, send_now),
                    {ok, _} = timer:send_interval(10000, Game, send_enemy),
                    game_manager(Players -- [H])
            end
    end.

