-module(game).
-export([start/0, pleft/0, pfront/0, pright/0, rleft/0, rfront/0, rright/0]).

start() ->
    G = spawn(fun() -> game(INITIAL) end),
    register(?MODULE,G).

pleft()  -> ?MODULE ! pleft.
pfront() -> ?MODULE ! pfront.
pright() -> ?MODULE ! pright.
rleft()  -> ?MODULE ! rleft.
rfront() -> ?MODULE ! rfront.
rright() -> ?MODULE ! rright.

%Player   : {User, Pid}
%GInfo    : {{x1, y1, a1, vel1, va1}, {x2, y2, a2, vel2, va2}, [VVm], {VVd, VVd} }
%VVd, VVm : {x, y}
%Interval : {[{Act1, Time}], [{Act2, Time}]}
%Act      : pl | pf | pr | rl | rf | rr
game(Player1, Player2, GInfo, Interval) ->
    {_, Pid1} = Player1,
    {_, Pid2} = Player2,
    {Pos1, Pos2, VVm, VVd} = GInfo,
    {_, _} = Interval,
    receive
        pleft()  ->
            ;
        pfront() -> 
            ;
        pright() -> 
            ;
        rleft()  -> 
            ;
        rfront() -> 
            ;
        rright() -> 
            ;

        send_now -> 
            New_GInfo = update(GInfo, Interval),
            Pid2 ! Pid1 ! {game_info, New_GInfo},
            game(Player1, Player2, New_GInfo, {[], []});
        send_enemy ->
            game(Player1, Player2, 
                 {Pos1, Pos2, 
                  [{rand:uniform(), rand:uniform()} | VVm], 
                  VVd}, Interval)
    end.

update(GInfo, Interval) ->
    io:fwrite("ole~p~p\n", [GInfo, Interval]).


