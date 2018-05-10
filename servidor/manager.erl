-module(manager).
-export([server/1]).

%-import(game, [pleft/1, pfront/1, pright/1, rleft/1, rfront/1, rright/1]).
-import(game_manager, [start_gameM/0, play/2]).
-import(login_manager, [start_loginM/0, create_account/2, login/2, logout/1]).

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
    gen_tcp:send(Sock, <<"Register? (send 1)\n">>),
    gen_tcp:send(Sock, <<"Login?    (send 2)\n">>),
    receive
        {tcp, _, Ans}->
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
    Msg = case Mod of
              create_account -> create_account(User, Pass);
              login          -> login(User, Pass)
          end,
    case Msg of
        {ok, Level, Exp} -> 
            gen_tcp:send(Sock, <<"success\n\\help for command list\n">>),
            player(Sock, {User, Pass, Level, Exp});
        Err            ->
            gen_tcp:send(Sock, io_lib:format(<<"~p\n">>, [Err])),
            create_login(Sock, Mod)
    end.

% Processos Principais %
% Player : {User, Pass, Level, Exp}
player(Sock, Player) ->
    {User, Pass, Level, Exp} = Player,
    receive
        {tcp, _, Msg} -> 
            case string:split(string:chomp(Msg), <<" ">>, all) of
                [<<"\\help">>] -> 
                    gen_tcp:send(Sock, [<<"\\help - command list\n">>,
                                        <<"\\info - your info\n">>]),
                    player(Sock, Player);
                [<<"\\info">>] ->
                    gen_tcp:send(Sock, [<<"Username: ">>, User, <<"\n">>,
                                        <<"Password: ">>, Pass, <<"\n">>,
                                        io_lib:format(<<"Level: ~p~n">>,   [Level]),
                                        io_lib:format(<<"Exp: ~p~n">>,       [Exp])]),
                    player(Sock, Player);
                [<<"\\play">>] ->
                    play(User, Level),
                    player(Sock, Player);
                _ ->  
                    ?MODULE ! {send, Msg, User},
                    player(Sock, Player)
            end;
        {tcp_closed, _} ->
            logout(User);
        {tcp_error, _, _} ->
            io:format("tcp error~n", []),
            logout(User);

        {online, List, ?MODULE} ->
            gen_tcp:send(Sock, lists:join(<<"\n">>, List)),
            gen_tcp:send(Sock, <<"\n">>),
            player(Sock, Player);
        {send, Msg, User, ?MODULE} ->
            gen_tcp:send(Sock, [User, <<" said: ">>, Msg]),
            player(Sock, Player);
        {Err, ?MODULE} ->
            gen_tcp:send(Sock, io_lib:format("~p\n", [Err])),
            player(Sock, Player);
        {game_info, GInfo} ->
            gen_tcp:send(Sock, io_lib:format("~p\n", [GInfo])),
            player(Sock, Player)
    end.

