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
    receive 
        {GamePid, ?MODULE} -> 
            io:fwrite("* inscrito\n"), 
            GamePid 
    end.
    

%--------------------------------------------------

loop(MapLevel) ->
    receive
        {enroll, Level, From} -> 
            {NewMapLevel, Game} = findGame(MapLevel, Level, From),
            From ! {Game, ?MODULE},
            loop(NewMapLevel)
        %{end, From} ->
    end.

%--------------------------------------------------


findGame(MapLevel, Level, Client) -> 
    findGame(MapLevel, Level-1, Client, 3).

findGame(MapLevel, Level, Client, I) when I==0 ->
    Game = game:start(?MODULE, Client),
    io:fwrite("* novo jogo (Level:~p)\n",[Level+1]),
    {maps:put(Level+1, Game, MapLevel), Game};

findGame(MapLevel, Level, Client, I) when I>0 -> 
    case maps:find(Level+I, MapLevel) of
        error -> findGame(MapLevel, Level, Client, I-1);
        % existe jogo disponivel acrescenta cliente ao jogo
        {ok, Game} -> 
            ok = game:addClient(Game, Client, ?MODULE),
            io:fwrite("* inscreveu em jogo (Level:~p)\n",[Level+I]),
            Client ! {Game, self()},
            {maps:remove(Level+I, MapLevel), Game}
    end.
