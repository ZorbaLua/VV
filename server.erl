
% TIRADO DA AULA PODE SER QUE ESTEJA TUDO ERRADO...

-module(login_manager).
-export([start/0, create_account/2, close_account/2, login/2, logout/1, online/0]).

start() ->
  pID = spawn(fun() -> loop(#{}) end),
  register(?MODULE,Pid).

create_account (User, Pass) -> ok | user_exists
  ?MODULE ! {create_account User, Pass, self()},
  receive {Res, ?MODULE} -> end.
close_account  (User, Pass) -> ok | invalid
  ?MODULE ! {close_account User, Pass, self()},
  receive {Res, ?MODULE} -> end.
login          (User, Pass) -> ok | invalid
  ?MODULE ! {login  User, Pass, self()},
  receive {Res, ?MODULE} -> end.
logout         (User)       -> ok
  ?MODULE ! {logout User,self()},
  receive {Res, ?MODULE} -> end.
%online         ()           -> [User]
%  ?MODULE ! {online self()},
%  receive {Res, ?MODULE} -> end.

loop(Map) ->
  receive

    {create_account, User, Pass, From} ->
      case maps:find(User, Map) of
        error ->
          From ! {ok, ?MODULE},
          loop(maps:put(User, {Pass, true}, Map));
        _->
          From ! {invalid, ?MODULE},
          loop(Map)
      end;

    {close_account, User, Pass, From} ->
      case maps:find(User, Map) of
        {ok, {Pass, _}} ->
          From ! {ok, ?MODULE},
          loop(maps:remove(User, Map));
        _->
          From ! {invalid, ?MODULE},
          loop(Map)
      end;

    {login, User, Pass, From} ->
      case maps:find(User, Map) of
        {ok, {Pass, _}} ->
          % CONTADOR + 1
          From ! {ok, ?MODULE},
          loop(maps:login(User, Map));
        _->
          From ! {invalid, ?MODULE},
          loop(Map)
      end

    {logout, User, From} ->
      case maps:find(User, Map) of
        {ok, {Pass, _}} ->
          % CONTADOR - 1
          From ! {ok, ?MODULE},
          loop(maps:logout(User, Map));
        _->
          From ! {invalid, ?MODULE},
          loop(Map)
      end;

    {online, From} ->

      end;

  end.
