-module(game).
-export([start/2, pleft/1, pfront/1, pright/1, rleft/1, rfront/1, rright/1]).

%GInfo    : {{ pos1, vel1, acc1, a1, va1, acca1 }, { pos2, vel2, acc2, a2, va2, acca2 }, [VVm], {VVd, VVd} }
ini_GInfo() -> {{{0.1, 0.5}, {0, 0}, {0, 0}, 0, 0, 0},
                {{0.4, 0.5}, {0, 0}, {0, 0}, math:pi(), 0, 0},
                [],
                {{rand:uniform(), rand:uniform()}, {rand:uniform(), rand:uniform()}}
                }.

%Interval : #{ Key => {{p|r, TS, T1}, {p|r, TS, T2}}}
ini_Interval() -> #{left  => {{release, 0, 0}, {release, 0, 0}},  % left
                    front => {{release, 0, 0}, {release, 0, 0}},  % front
                    right => {{release, 0, 0}, {release, 0, 0}}}. % right

start(Player1, Player2) ->
    G = spawn(fun() -> game(Player1, Player2, ini_GInfo(), ini_Interval()) end),
    {ok, _} = timer:send_interval(100, G, send_now),
    {ok, _} = timer:send_interval(10000, G, send_enemy),
    G.

pleft(Game)  -> Game ! {press  , left , self()}.
pfront(Game) -> Game ! {press  , front, self()}.
pright(Game) -> Game ! {press  , right, self()}.
rleft(Game)  -> Game ! {release, left , self()}.
rfront(Game) -> Game ! {release, front, self()}.
rright(Game) -> Game ! {release, right, self()}.

%Raio do jogador = ?
%Raio das vagas  = ?
%
% 0 <= X < 1
% 0 <= Y < 1
%
%Player   : {User, Pid}
%VVd, VVm : {x, y}
game(Player1, Player2, GInfo, Interval) ->
    {_, Pid1} = Player1,
    {_, Pid2} = Player2,
    {PlState1, PlState2, VVm, VVd} = GInfo,
    receive
        {press, Key, From}  ->
            {ok, {P1, P2}} = maps:find(Key, Interval),
            New_Interval = case From of
                               Pid1 ->
                                   {_, _, T1} = P1,
                                   maps:update(Key, {{press, erlang:timestamp(), T1}, P2}, Interval);
                               Pid2 -> 
                                   {_, _, T2} = P2,
                                   maps:update(Key, {P1, {press, erlang:timestamp(), T2}}, Interval);
                               _    -> Interval
                           end,
            game(Player1, Player2, GInfo, New_Interval);
        {release, Key, From} ->
            {ok, {P1, P2}} = maps:find(Key, Interval),
            New_Interval = case From of
                               Pid1 -> 
                                   {_, TS1, T1} = P1,
                                   maps:update(Key, {{release, 0, T1 + timer:now_diff(erlang:timestamp(), TS1)}, P2}, Interval);
                               Pid2 -> 
                                   {_, TS2, T2} = P2,
                                   maps:update(Key, {P1, {release, 0, T2 + timer:now_diff(erlang:timestamp(), TS2)}}, Interval);
                               _    -> Interval
                           end,
            game(Player1, Player2, GInfo, New_Interval);

        send_now -> 
            {New_GInfo, New_Interval} = update(GInfo, Interval),
            Pid2 ! Pid1 ! {game_info, New_GInfo},
            game(Player1, Player2, New_GInfo, New_Interval);
        send_enemy ->
            game(Player1, Player2, 
                 {PlState1, PlState2, 
                  [{rand:uniform(), rand:uniform()} | VVm], 
                  VVd}, Interval)
    end.


update(GInfo, Interval) ->
    {{ Pos1, Vel1, _, A1, Va1, _ }, { Pos2, Vel2, _, A2, Va2, _ }, Vm, Vd } = GInfo,

    {ok, {PL1, PL2}} = maps:find(left , Interval),
    {ok, {PF1, PF2}} = maps:find(front, Interval),
    {ok, {PR1, PR2}} = maps:find(right, Interval),
    
    {ModL1, TSL1, TL1} = PL1,
    {Aux_Acca1, New_PL1} = case ModL1 of
                               press   -> 
                                    Now1 = erlang:timestamp(),
                                    { (timer:now_diff(Now1, TSL1) + TL1)/100, {ModL1, Now1, 0}};
                               release -> {(TL1/100), {ModL1, TSL1, 0}}
                           end,
    
    {ModR1, TSR1, TR1} = PR1,
    {New_Acca1, New_PR1} = case ModR1 of
                               press   -> 
                                    Now2 = erlang:timestamp(),
                                    { Aux_Acca1 - (timer:now_diff(Now2, TSR1) + TR1)/100, {ModR1, Now2, 0}};
                               release -> {Aux_Acca1 - (TR1/100), {ModR1, TSR1, 0}}
                           end,

    {ModF1, TSF1, TF1} = PF1,
    {New_Acc1, New_PF1} = case ModF1 of
                               press   -> 
                                   Now3 = erlang:timestamp(),
                                   { {math:cos(A1)*(timer:now_diff(Now3, TSF1) + TF1)/100, math:sin(A1)*(timer:now_diff(Now3, TSF1) + TF1)/100}, 
                                     {ModF1, Now3, 0}};
                               release -> 
                                   { {math:cos(A1)*(TF1/100), math:sin(A1)*(TF1/100)}, 
                                    {ModF1, TSF1, 0}}
                           end,
    
    {ModL2, TSL2, TL2} = PL2,
    {Aux_Acca2, New_PL2} = case ModL2 of
                               press   -> 
                                    Now4 = erlang:timestamp(),
                                    { (timer:now_diff(Now4, TSL2) + TL2)/100, {ModL2, Now4, 0}};
                               release -> {(TL2/100), {ModL2, TSL2, 0}}
                           end,
   

    {ModR2, TSR2, TR2} = PR2,
    {New_Acca2, New_PR2} = case ModR2 of
                               press   -> 
                                    Now5 = erlang:timestamp(),
                                    { Aux_Acca2 - (timer:now_diff(Now5, TSR2) + TR2)/100, {ModR2, Now5, 0}};
                               release -> {Aux_Acca2 - (TR2/100), {ModR2, TSR2, 0}}
                           end,

    {ModF2, TSF2, TF2} = PF2,
    {New_Acc2, New_PF2} = case ModF2 of
                               press   -> 
                                   Now6 = erlang:timestamp(),
                                   { {math:cos(A2)*(timer:now_diff(Now6, TSF2) + TF2)/100, math:sin(A2)*(timer:now_diff(Now6, TSF2) + TF2)/100}, 
                                     {ModF2, Now6, 0}};
                               release -> 
                                   { {math:cos(A2)*(TF2/100), math:sin(A2)*(TF2/100)}, 
                                    {ModF2, TSF2, 0}}
                           end,

    New_Interval = #{left  => {New_PL1, New_PL2},
                     front => {New_PF1, New_PF2},
                     right => {New_PR1, New_PR2}},

    {ModL2, _, TL2} = PL2,

    %angulo P1 
    New_Va1 = 0.1*New_Acca1 + Va1,
    New_A1  = 0.1*New_Va1 + A1,

    %pos P1 
    {New_Acc1x, New_Acc1y} = New_Acc1,
    {Vel1x, Vel1y} = Vel1,
    {Pos1x, Pos1y} = Pos1,
    New_Vel1 = {0.1*New_Acc1x + Vel1x, 0.1*New_Acc1y + Vel1y},
    {New_Vel1x, New_Vel1y} = New_Vel1,
    New_Pos1 = {0.1*New_Vel1x + Pos1x, 0.1*New_Vel1y + Pos1y},

    %angulo P2 
    New_Va2 = 0.1*New_Acca2 + Va2,
    New_A2  = 0.1*New_Va2 + A2,

    %pos P2 
    {New_Acc2x, New_Acc2y} = New_Acc2,
    {Vel2x, Vel2y} = Vel2,
    {Pos2x, Pos2y} = Pos2,
    New_Vel2 = {0.1*New_Acc2x + Vel2x, 0.1*New_Acc2y + Vel2y},
    {New_Vel2x, New_Vel2y} = New_Vel2,
    New_Pos2 = {0.1*New_Vel2x + Pos2x, 0.1*New_Vel2y + Pos2y},
    
    New_GInfo = {{ New_Pos1, New_Vel1, New_Acc1, New_A1, New_Va1, New_Acca1 }, 
                 { New_Pos2, New_Vel2, New_Acc2, New_A2, New_Va2, New_Acca2 }, Vm, Vd },

    {New_GInfo, New_Interval}.

