-module(login_manager).
-export([start_loginM/0, create_account/2, login/2, logout/1, top3/0]).

start_loginM() ->
    LM = spawn(fun()-> login_manager(#{}) end),
    register(?MODULE, LM).

create_account(User, Pass) ->
    ?MODULE ! {create_account, User, Pass, self()},
    receive
        {ok, Level, Exp, ?MODULE} -> {ok, Level, Exp};
        {Err, ?MODULE} -> Err
    end.

login(User, Pass) ->
    ?MODULE ! {login, User, Pass, self()},
    receive
        {ok, Level, Exp, ?MODULE} -> {ok, Level, Exp};
        {Err, ?MODULE} -> Err
    end.

logout(User) ->
    ?MODULE ! {logout, User, self()},
    receive
        {Ans, ?MODULE} -> Ans
    end.

top3() ->
    ?MODULE ! {top3, self()},
    List = receive
               {M, ?MODULE} -> lists:map(fun({U, {_, _, L, E, _}}) -> {U, L, E} end, maps:to_list(M))
           end,
    case lists:reverse(lists:keysort(2, lists:keysort(3, List))) of
        [E1]                   -> {1, [E1]};
        [E1, E2]               -> {2, [E1, E2]};
        [E1 | [E2 | [E3 | _]]] -> {3, [E1, E2, E3]}
    end.

%online() ->
%    ?MODULE ! {online, self()},
%    receive
%        {ok, Level, Exp, ?MODULE} -> {ok, Level, Exp};
%        {Err, ?MODULE} -> Err
%    end.

% Map : #{User => {Pass, On, Level, Exp, Pid}}
login_manager(Map) ->
    receive
        {create_account, User, Pass, From} ->
            case maps:find(User, Map) of
                error ->
                    From ! {ok, 1, 0, ?MODULE},
                    login_manager(maps:put(User, {Pass, true, 1, 0, From}, Map));
                _     ->
                    From ! {user_exists, ?MODULE},
                    login_manager(Map)
            end;
        {login, User, Pass, From} ->
            case maps:find(User, Map) of
                error ->
                    From ! {invalid_user, ?MODULE},
                    login_manager(Map);
                {ok, {Value, _, _, Level, Exp}} ->
                    case Value of
                        Pass ->
                            From ! {ok, Level, Exp, ?MODULE},
                            login_manager(maps:update(User, {Pass, true, Level, Exp, From}, Map));
                        _ ->
                            From ! {invalid_pass, ?MODULE},
                            login_manager(Map)
                    end
            end;
        {logout, User, From} ->
            case maps:find(User, Map) of
                error ->
                    From ! {invalid_user, ?MODULE},
                    login_manager(Map);
                {ok, {Pass, _, Pid, Level, Exp}}->
                    From ! {ok, ?MODULE},
                    login_manager(maps:update(User, {Pass, false, Level, Exp, Pid}, Map))
            end;
        {top3, From} ->
            From ! {Map, ?MODULE},
            login_manager(Map)
    end.
