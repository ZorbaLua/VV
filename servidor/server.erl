-module(server).
-export([start/0, create_account/2, close_account/2, login/2, logout/1, online/0]).


start() ->
    Pid = spawn(fun() -> loop(#{}) end),
    register(?MODULE, Pid). %MODULE? e tipo um define para o nome do modulo


create_account(User, Pass) -> 
    ?MODULE ! {create_account, User, Pass, self()},
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

online() ->
    ?MODULE ! {online, self()},
    receive {Res, ?MODULE} -> Res end.

loop(Map) ->
    receive
        {create_account, User, Pass, From} ->
            case maps:find(User, Map) of
                error ->
                    From ! {ok, ?MODULE},
                    loop(maps:put(User, {Pass, false}, Map));
                _     ->
                    From ! {user_exists, ?MODULE},
                    loop(Map)
            end;

        {close_account, User, Pass, From} ->
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
            end;
        {login, User, Pass, From} ->
            case maps:find(User, Map) of
                error ->
                    From ! {invalid_user, ?MODULE},
                    loop(Map);
                {ok, {Value, On}} ->
                    if
                        On ->
                            From ! {already_On, ?MODULE},
                            loop(Map);
                        Value == Pass ->
                            From ! {ok, ?MODULE},
                            loop(maps:update(User, {Pass, true},  Map));
                        true ->
                            From ! {invalid_pass, ?MODULE},
                            loop(Map)
                    end
            end;
        {logout, User, From} ->
            case maps:find(User, Map) of
                error ->
                    From ! {invalid_user, ?MODULE},
                    loop(Map);
                {ok, {Value, On}} ->
                    if
                        not On ->
                            From ! {already_Off, ?MODULE},
                            loop(Map);
                        true ->
                            From ! {ok, ?MODULE},
                            loop(maps:update(User, {Value, false},  Map))
                    end
            end;
        {online, From} ->
            From ! {maps:keys(maps:filter(fun(_,{_,V}) -> V end, Map)), ?MODULE},
            loop(Map)

    end.
