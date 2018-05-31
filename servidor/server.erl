-module(server).
-export([start/1]).

%--------------------------------------------------
% API
start(Port) ->
    game_manager:start(),
    login_manager:start(),
    {ok, LSock} = gen_tcp:listen(Port, [binary, {packet, line}]),
    acceptor(LSock).

%--------------------------------------------------

acceptor(LSock) ->
    io:fwrite("",[]),
    {ok, Sock} = gen_tcp:accept(LSock),
    Client = spawn(fun() -> clientLoop_LoginManager(Sock) end),
    ok = gen_tcp:controlling_process(Sock, Client),
    acceptor(LSock).





%--------------------------------------------------
% comunicacao cliente com login manager
clientLoop_LoginManager(Sock) ->
    receive
        {tcp, _, Request}->
            [Comand | Args] = string:split(string:chomp(Request), " ", all),
            eval_lm(Sock, Comand, Args);
        %receber erro de tcp
        {tcp_closed, _} -> free;
        {tcp_error,  _} -> free;
        %receber qualquer coisa 
        _ -> clientLoop_LoginManager(Sock)
    end.

eval_lm(Sock, Comand, Args) ->
    case Comand of
        <<"login">> -> 
            io:fwrite("<-login\n"),
            [User | [Pass | [] ]] = Args,
            case login_manager:login(User, Pass) of 
                % login bem sucedido processo avanca proximo estado
                {ok, PlayerInfo} -> 
                    ok = gen_tcp:send(Sock, "ok\n"),
                    io:fwrite("->ok\n"),
                    clientLoop_GameManager(Sock, PlayerInfo);
                % login mal sucedido processo fica no mesmo estado
                _ ->
                    ok = gen_tcp:send(Sock, "error\n"),
                    io:fwrite("->error\n"),
                    clientLoop_LoginManager(Sock)
            end;

        <<"signin">> ->
            io:fwrite("<-signin\n"),
            [User | [Pass | [] ]] = Args,
            case login_manager:signin(User, Pass) of 
                % registo bem sucedido
                ok ->
                    ok = gen_tcp:send(Sock, "ok\n"),
                    io:fwrite("->ok\n"),
                    clientLoop_LoginManager(Sock);
                % registo mal sucedido
                _ -> 
                    ok = gen_tcp:send(Sock, "error\n"),
                    io:fwrite("->error\n"),
                    clientLoop_LoginManager(Sock)
            end
    end.
%--------------------------------------------------










%--------------------------------------------------
% comunicacao cliente com Game manager
clientLoop_GameManager(Sock, PlayerInfo) ->
    {User, _Pass, _Level, _Exp} = PlayerInfo,
    receive
        {tcp, _, Request} -> 
            eval_gm(Request, Sock, PlayerInfo);
        %receber erro de tcp
        {tcp_closed, _} -> login_manager:logout(User);
        {tcp_error,  _} -> login_manager:logout(User);
        %receber qualquer coisa 
        _ -> clientLoop_GameManager(Sock, PlayerInfo)
    end.


eval_gm(C, Sock, PlayerInfo) ->
    Comand = string:chomp(C),
    case Comand of
        % receber o pid do jogo, e espere pela mensagem start do game 
        <<"play">> ->
            io:fwrite("<-play\n"),
            Game = game_manager:enroll(PlayerInfo),
            clientLoop_Game(Sock, PlayerInfo, Game);

        % receber pedido de informacoes
        <<"info">> ->
            io:fwrite("<-info\n"),
            ok = gen_tcp:send(Sock, PlayerInfo),
            io:fwrite("->~p\n",[PlayerInfo]),
            clientLoop_GameManager(Sock, PlayerInfo);

        % receber qualquer coisa
        _ -> clientLoop_GameManager(Sock, PlayerInfo)
    end.
%--------------------------------------------------










%--------------------------------------------------
% comunicacao cliente com jogo a decorrer
clientLoop_Game(Sock, PlayerInfo, Game) ->
    {User, _, _, _} = PlayerInfo,
    receive
        % receber mensaegem do cliente
        {tcp, _ , Msg} ->
            Game ! {Msg, self()},
            clientLoop_Game(Sock, PlayerInfo, Game);

        % receber mensagem de start do jogo
        {start, Game} ->
            ok = gen_tcp:send(Sock, "ok\n"),
            clientLoop_Game(Sock, PlayerInfo, Game);
                    
        % receber estado do jogo
        {state, State, Game} -> 
            ok = gen_tcp:send(Sock, State),
            clientLoop_Game(Sock, PlayerInfo, Game);

        % receber fim de jogo 
        {won, Game} -> 
            login_manager:win(User),
            ok = gen_tcp:send(Sock, "end\n"),
            clientLoop_GameManager(Sock, PlayerInfo);
        {lost, Game} -> 
            ok = gen_tcp:send(Sock, "end\n"),
            clientLoop_GameManager(Sock, PlayerInfo);

        %receber erro de tcp
        {tcp_closed, _} -> login_manager:logout(User);
        {tcp_error,  _} -> login_manager:logout(User);
        %receber qualquer coisa 
        _ -> clientLoop_Game(Sock, PlayerInfo, Game)
    end.
%--------------------------------------------------
    
