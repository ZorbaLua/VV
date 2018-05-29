-module(game_manager).
-export([start/0, enroll/1]).


%--------------------------------------------------
% API

start() ->
    Pid = spawn(fun()-> loop(#{}) end),
    register(?MODULE, Pid).

enroll(PlayerInfo) ->
    {_User, _Pass, Level, _Exp} = PlayerInfo,
    ?MODULE ! {enroll, Level, self()},
    receive {GamePid, ?MODULE} -> GamePid
    end.

%--------------------------------------------------

loop(MapLevel) ->
    receive
        {enroll, Level, From} -> 
            Pid = findGame(MapLevel, Level, From),
            From ! {Pid, self()}
        %{end, From} ->
    end.

%--------------------------------------------------


findGame(MapLevel, Level, Client) -> findGame(MapLevel, Level-1, 3, Client).
findGame(MapLevel, Level, I, Client) when I==0 ->
    Pid = game:start(self()),
    game:addClient(Client),
    loop(MapLevel#{Level+1 => Pid});

findGame(MapLevel, Level, I, Client) when I>0 -> 
    case maps:find(Level, MapLevel) of
        error -> findGame(MapLevel, Level, I-1);
        % existe jogo disponivel acrescenta cliente ao jogo
        {ok, Game} -> 
            ok = game:addClient(Game, Client),
            Client ! {Game, self()},
            loop(MapLevel)
    end.
