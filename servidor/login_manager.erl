-module(login_manager).
-export([start/0, signin/2, close_account/2, login/2, logout/1]).

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

%--------------------------------------------------

loop(Map) ->
    receive
        {signin, User, Pass, From} -> aux_signin(User, Pass, From, Map);

        {close_account, User, Pass, From} -> aux_close_account(User, Pass, From, Map);

        {login, User, Pass, From} -> aux_login( User, Pass, From, Map);

        {logout, User, From} -> aux_logout(User, From, Map)

    end.

%--------------------------------------------------


aux_signin(User, Pass, From, Map) -> 
    case maps:find(User, Map) of
        error ->
            From ! {ok, ?MODULE},
            loop(maps:put(User ,{Pass, 0, 0, off}, Map));
        _     ->
            From ! {user_exists, ?MODULE},
            loop(Map)
    end.

aux_close_account(User, Pass, From, Map) ->
    case maps:find(User, Map) of
        error ->
            From ! {invalid_user, ?MODULE},
            loop(Map);
        {ok, {Value, _}} ->
            if
                Value == Pass ->
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
