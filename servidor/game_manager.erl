-module(game_manager).
-export([start_gameM/0, play/2]).
-import(game, [start/2]).

start_gameM() ->
    GM = spawn(fun()-> game_manager([]) end),
    register(?MODULE, GM).

play(User, Level) ->
    ?MODULE ! {play, User, Level, self()},
    receive
        {Gamepid, ?MODULE} -> Gamepid
    end.


% Player : {User, Level, Pid}
game_manager(Players) ->
    receive
        {play, User, Level, From} -> 
            case lists:filter(fun({_, L, _}) -> (L==Level) or (L==Level+1) or (L==Level-1) end, Players) of
                [] -> 
                    game_manager(Players ++ [{User, Level, From}]);
                [H | _] ->
                    {User_H, _, Pid_H} = H,
                    Gamepid = start({User_H, Pid_H}, {User, From}),
                    From ! Pid_H ! {Gamepid, ?MODULE},
                    game_manager(Players -- [H])
            end
    end.

