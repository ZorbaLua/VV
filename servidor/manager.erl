-module(manager).
-export([server/1]).

-import(game, [pleft/1, pfront/1, pright/1, rleft/1, rfront/1, rright/1]).
-import(game_manager, [start_gameM/0, play/2]).
-import(login_manager, [start_loginM/0, create_account/2, login/2, logout/1, top3/0]).

server(Port) ->
    start_loginM(),
    start_gameM(),
    {ok, LSock} = gen_tcp:listen(Port, [binary, {packet, line}]),
    acceptor(LSock).

acceptor(LSock) ->
    {ok, Sock} = gen_tcp:accept(LSock),
    Player = spawn(fun() -> start_player(Sock) end),
    gen_tcp:controlling_process(Sock, Player),
    acceptor(LSock).


% create_account or Login? %
start_player(Sock) ->
    receive
        {tcp, _, Ans}->
            io:fwrite("1ou2:~p\n", [Ans]),    
            case Ans of
                <<"1\n">> -> create_login(Sock, create_account);
                <<"2\n">> -> create_login(Sock, login);
                _         ->
                    gen_tcp:send(Sock, <<"please try again\n">>),
                    start_player(Sock)
            end
    end.

% fazer no player
create_login(Sock, Mod) ->
    _User = receive
               {tcp, _, Ans_User}->
                   string:split(string:chomp(Ans_User), <<" ">>, all)
           end,
    _Pass = receive
               {tcp, _, Ans_Pass}->
                   string:split(string:chomp(Ans_Pass), <<" ">>, all)
           end,
    {User, Pass} = case {_User, _Pass} of
                       {[U], [P]} -> {U, P};
                       _          -> {none, none}
                   end,
    Msg = case Mod of
              _ when {User, Pass} =:= {none, none} -> self() ! user_pass_invalid;
              create_account -> create_account(User, Pass);
              login          -> login(User, Pass)
          end,
    io:fwrite("User:~p\nPass:~p\n", [User, Pass]),    
    case Msg of
        {ok, Level, Exp} ->
            gen_tcp:send(Sock, <<"ok\n">>),
            player(Sock, {User, Pass, Level, Exp}, none);
        Err            ->
            gen_tcp:send(Sock, io_lib:format(<<"~p~n">>, [Err])),
            start_player(Sock)
    end.

update_level(Player, Result) ->
    {User, Pass, Level, Exp} = Player,
    case Result of
        win  ->
            Exp = Exp+1,
            if
                Level == Exp ->
                    Level = Level+1,
                    Exp = 0
            end;
        _    ->
            Level = Level+1
    end,
    {User, Pass, Level, Exp}.


% Processos Principais %
% Player : {User, Pass, Level, Exp}
player(Sock, Player, GPid) ->
    {User, Pass, Level, Exp} = Player,
    receive
        {tcp, _, Msg} ->
            io:fwrite("input:~p\n", [Msg]),    
            case string:split(string:chomp(Msg), <<" ">>, all) of
                [<<"info">>] ->
                    gen_tcp:send(Sock, [ User, <<"\n">>,
                                         Pass, <<"\n">>,
                                         io_lib:format(<<"~p~n">>, [Level]),
                                         io_lib:format(<<"~p~n">>,   [Exp])
                                       ]),
                    player(Sock, Player, GPid);
                [<<"play">>] ->
                    New_GPid = play(User, Level),
                    player(Sock, Player, New_GPid);
                [<<"logout">>] ->
                    logout(User),
                    start_player(Sock);
                [<<"top3">>] ->
                    % top3() : {Len, [{User, Level, Exp}]}
                    {Q, L} = top3(),
                    gen_tcp:send(Sock, [io_lib:format(<<"~p~n">>, [Q])]),
                    case Q of
                        1 ->
                            [E1] = L,
                            gen_tcp:send(Sock, [io_lib:format(<<"~p~n">>, [E1])]);
                        2 ->
                            [E1, E2] = L,
                            gen_tcp:send(Sock, [io_lib:format(<<"~p~n">>, [E1])]),
                            gen_tcp:send(Sock, [io_lib:format(<<"~p~n">>, [E2])]);
                        3 -> 
                            [E1, E2, E3] = L,
                            gen_tcp:send(Sock, [io_lib:format(<<"~p~n">>, [E1])]),
                            gen_tcp:send(Sock, [io_lib:format(<<"~p~n">>, [E2])]),
                            gen_tcp:send(Sock, [io_lib:format(<<"~p~n">>, [E3])])
                    end,
                    player(Sock, Player, GPid);
                [<<"l">>] ->
                    pleft(GPid),
                    rleft(GPid),
                    player(Sock, Player, GPid);
                [<<"f">>] ->
                    pfront(GPid),
                    rfront(GPid),
                    player(Sock, Player, GPid);
                [<<"r">>] ->
                    pright(GPid),
                    rright(GPid),
                    player(Sock, Player, GPid);
                _ ->
                    player(Sock, Player, GPid)
            end;
        {tcp_closed, _} ->
            logout(User);
        {tcp_error, _, _} ->
            io:format("tcp error~n", []),
            logout(User);

        %{online, List, _} ->
        %    gen_tcp:send(Sock, lists:join(<<"\n">>, List)),
        %    gen_tcp:send(Sock, <<"\n">>),
        %    player(Sock, Player, GPid);
        {start_game, GamePid} ->
            gen_tcp:send(Sock, <<"ok\n">>),
            player(Sock, Player, GamePid);
        {game_info, GInfo} ->
            gen_tcp:send(Sock, io_lib:format("~p~n", [GInfo])),
            player(Sock, Player, GPid);
        {game_over, Result} ->
            gen_tcp:send(Sock, io_lib:format("~p~n", [Result])),
            player(Sock, update_level(Player, Result), none);
        Err ->
            gen_tcp:send(Sock, io_lib:format("~p~n", [Err])),
            player(Sock, Player, GPid)
    end.
