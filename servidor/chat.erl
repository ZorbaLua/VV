-module(chat).
-export([server/1]).
-import(server,[start/0, create_account/2, close_account/2, login/2, logout/1, online/0]).

server(Port) ->
    start(),
    Room = spawn(fun()-> room([]) end),
    {ok, LSock} = gen_tcp:listen(Port, [binary, {packet, line}]),
    acceptor(LSock, Room).

acceptor(LSock, Room) ->
    {ok, Sock} = gen_tcp:accept(LSock),
    gen_tcp:send(Sock,<<"Entrou~n">>),
    Room ! {new_user, Sock},
    gen_tcp:controlling_process(Sock, Room),
    acceptor(LSock, Room).

%lists:flatten(io_lib:format("~p", [{ok,okay}])). %meter qualquer coisa em string
command(Arg, Sockets) ->
    case Arg of
        [Comm, Args] ->
            case {Comm, string:split(Args," ",all)} of
                {<<"create_account">>, [User, Pass]} ->
                    Msg = create_account(User, Pass),
                    MsgS = lists:flatten(io_lib:format("~p", [Msg])),
                    [gen_tcp:send(Socket, MsgS) || Socket <- Sockets];
                {<<"close_account">>, [User, Pass]} ->
                    Msg = close_account(User, Pass),
                    MsgS = lists:flatten(io_lib:format("~p", [Msg])),
                    [gen_tcp:send(Socket, MsgS) || Socket <- Sockets];
                {<<"login">>, [User, Pass]} ->
                    Msg = login(User, Pass),
                    MsgS = lists:flatten(io_lib:format("~p", [Msg])),
                    [gen_tcp:send(Socket, MsgS) || Socket <- Sockets];
                {<<"logout">>, [User]} ->
                    Msg = logout(User),
                    MsgS = lists:flatten(io_lib:format("~p", [Msg])),
                    [gen_tcp:send(Socket, MsgS) || Socket <- Sockets];
                _Else ->
                    io:fwrite("Mau comando ou maus argumentos")
            end;
        [Comm]       ->
            io:fwrite("Comm:~p~n",[Comm]),
            case Comm of
                <<"online">> ->
                    Msg = online(),
                    MsgS = lists:flatten(io_lib:format("~p", [Msg])),
                    [gen_tcp:send(Socket, MsgS) || Socket <- Sockets];
                _Else ->
                    io:fwrite("Mau comando ou maus argumentos,~p~n",[Comm])
            end;
        _End         ->
            io:fwrite("Maus argumentos")
    end.

room(Sockets) ->
    receive
        {new_user, Sock} ->
            io:format("new user~n", []),
            room([Sock | Sockets]);

        {tcp, _, Data} ->
            io:fwrite("receive "),
            case Data of
                <<$\\, T/bitstring>> ->
                    command(string:split(string:chomp(T)," "), Sockets),
                    io:fwrite("comando usado~n");
                _Else ->
                    [gen_tcp:send(Socket, Data) || Socket <- Sockets]
            end,
            io:fwrite(Data),
            room(Sockets);

        {tcp_closed, Sock} ->
            io:format("user disconnected~n", []),
            room(Sockets -- [Sock]);

        {tcp_error, Sock, _} ->
            io:format("tcp error~n", []),
            room(Sockets -- [Sock])
    end.
