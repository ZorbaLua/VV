-module(champion).
-export([start/2, keyFun/3, eval/2]).

%--------------------------------------------------
% API

start(Game, I) ->
    if 
        I == 1 -> spawn(fun() -> loop(Game, {{0.1, 0.5}, {0, 0}, {0, 0}, 0, 0, 0}) end);
        true   -> spawn(fun() -> loop(Game, {{0.4, 0.5}, {0, 0}, {0, 0}, math:pi(), 0, 0}) end)
    end.

keyFun(Champion, TcpMesg, NowTime) -> 
    {KeyState, KeyCode} = strings:split(TcpMesg, ""),
    Champion ! {keyFun, list:toAtom(KeyState), list:toAtom(KeyCode), NowTime, self()}.


eval(Champion, NowTime) -> 
    Champion ! {eval, NowTime, self()}.

%--------------------------------------------------

loop(Game, State) ->
    receive
        {keyFun, KeyState, KeyCode, NowTime, Game} -> 
            State = updateKey(State, KeyState, KeyCode, NowTime),
            loop(Game, State);

        {eval, NowTime, Game} -> 
            NewState = update(State, NowTime),
            Game ! {toString(NewState), self()},
            loop(Game, NewState)
    end.

update(State, NowTime) ->
    {Pos, Vel, Acc, A, Va, Acca} = State,
    update(Pos, Vel, Acc, A, Va, Acca, NowTime).
update(Pos, Vel, Acc, A, Va, Acca, NowTime) ->
    %% formula update jogador
%
%    %angulo P1 
%    New_Va1 = 0.1*New_Acca1 + Va1,
%    New_A1  = 0.1*New_Va1 + A1,
%
%    %pos P1 
%    {New_Acc1x, New_Acc1y} = New_Acc1,
%    {Vel1x, Vel1y} = Vel1,
%    {Pos1x, Pos1y} = Pos1,
%    New_Vel1 = {0.1*New_Acc1x + Vel1x, 0.1*New_Acc1y + Vel1y},
%    {New_Vel1x, New_Vel1y} = New_Vel1,
%    New_Pos1 = {0.1*New_Vel1x + Pos1x, 0.1*New_Vel1y + Pos1y},
    {Pos, Vel, Acc, A, Va, Acca, NowTime}.


% fazer update, retornat estado com acelarçao mudad
updateKey(State, KeyState, KeyCode, NowTime) ->
    {Pos, Vel, Acc, A, Va, Acca} = update(State, NowTime),
    case KeyState of
        press -> 
            case KeyCode of
                up   -> {Pos, Vel, 1, A, Va, Acca};
                left -> {Pos, Vel, Acc, A, Va, -1};
                rigt -> {Pos, Vel, Acc, A, Va, 1}
            end;


        release -> 
            case KeyCode of
                up   -> {Pos, Vel, 0, A, Va, Acca};
                left -> {Pos, Vel, Acc, A, Va, 0};
                rigt -> {Pos, Vel, Acc, A, Va, 0}
            end
    end.



% tranformar em sring
toString(State) ->
    {Pos, Vel, Acc, A, Va, Acca} = State,
    toString(Pos, Vel, Acc, A, Va, Acca).
toString(Pos, Vel, Acc, _A, _Va, _Acca) ->
    {X, Y} = Pos,
    {VX, VY} = Vel,
    {AX, AY} = Acc,
    strings:format("{{~p,~p},{~p,~p},{~p,~p}}", [X, Y, VX, VY, AX, AY]).

