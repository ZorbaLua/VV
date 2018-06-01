-module(login_manager).
-export([start/0, signin/2, close_account/2, login/2, logout/1, top3level/0, win/1]).

%--------------------------------------------------
% API
%
start() ->
    Pid = spawn(fun() -> loop(#{}) end),
    register(?MODULE, Pid). %MODULE? e tipo um define para o nome do modulo

signin(User, Pass) -> 
    ?MODULE ! {signin, User, Pass, self()},
    receive {Res, ?MODULE} -> Res end.

close_account(User, Pass) ->
    ?MODULE ! {close_account, User, Pass, self()},
    receive {Res, ?MODULE} -> Res end.

login(User, Pass) ->
    ?MODULE ! {login, User, Pass, self()},
    receive {Res, ?MODULE} -> Res end.

logout(User) ->
    ?MODULE ! {logout, User, self()},
    receive {Res, ?MODULE} -> Res end.

top3level() ->
    ?MODULE ! {top3level, self()},
    List = receive
               {M, ?MODULE} -> lists:map(fun({U, {_, L, E, _}}) -> {U, L, E} end, maps:to_list(M))
           end,
    case lists:reverse(lists:keysort(2, lists:keysort(3, List))) of
        [E1]                   -> [E1];
        [E1, E2]               -> [E1, E2];
        [E1 | [E2 | [E3 | _]]] -> [E1, E2, E3]
    end.

win(User) -> 
    ?MODULE ! {win, User}.


%--------------------------------------------------

loop(Map) ->
    receive
        {signin, User, Pass, From} -> aux_signin(User, Pass, From, Map);

        {close_account, User, Pass, From} -> aux_close_account(User, Pass, From, Map);

        {login, User, Pass, From} -> aux_login( User, Pass, From, Map);

        {logout, User, From} -> aux_logout(User, From, Map);

        {win, User} -> aux_win(User, Map);

        {top3level, From} -> From ! {Map, ?MODULE}, loop(Map)
    end.

%--------------------------------------------------


aux_signin(User, Pass, From, Map) -> 
    case maps:find(User, Map) of
        error ->
            From ! {ok, ?MODULE},
            loop(maps:put(User ,{Pass, 1, 0, off}, Map));
        _     ->
            From ! {user_exists, ?MODULE},
            loop(Map)
    end.

aux_close_account(User, Pass, From, Map) ->
    case maps:find(User, Map) of
        error ->
            From ! {invalid_user, ?MODULE},
            loop(Map);
        {ok, {P, _}} ->
            if
                P == Pass ->
                    From ! {ok, ?MODULE},
                    loop(maps:remove(User, Map));
                true ->
                    From ! {invalid_pass, ?MODULE},
                    loop(Map)
            end
    end.

aux_login(User, Pass, From, Map) ->
    case maps:find(User, Map) of
        error ->
            From ! {invalid_user, ?MODULE},
            loop(Map);
        {ok, {P, Level, Exp, State}} ->
            if
                State == on ->
                    From ! {already_On, ?MODULE},
                    loop(Map);
                P == Pass ->
                    From ! {{ok, {P, Level, Exp, State}}, ?MODULE},
                    loop(maps:update(User, {P, Level, Exp, on},  Map));
                true ->
                    From ! {invalid_pass, ?MODULE},
                    loop(Map)
            end
    end.

aux_win(User, Map) ->
    io:fwrite("* end game\n"),
    case maps:find(User, Map) of 
        error -> loop(Map);
        {ok, {P, Level, Exp, State}} ->
            NewExp = Exp+1,
            if
                NewExp>=Level -> loop(maps:update(User, {P, Level+1, 0, State}, Map));
                true -> loop(maps:update(User, {P, Level, NewExp, State}, Map))
            end
    end.

aux_logout(User, From, Map) ->
    case maps:find(User, Map) of
        error ->
            From ! {invalid_user, ?MODULE},
            loop(Map);
        {ok, {Value, Level, Exp, On}} ->
            if
                not On ->
                    From ! {already_Off, ?MODULE},
                    loop(Map);
                true ->
                    From ! {ok, ?MODULE},
                    loop(maps:update(User, {Value, Level, Exp, off},  Map))
            end
    end.

