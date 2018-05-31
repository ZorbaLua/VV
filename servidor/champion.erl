-module(champion).
-export([start/3, keyFun/3, eval/2]).

%--------------------------------------------------
% API

start(Game, I, Time) ->
    if 
        I == 1 -> spawn(fun() -> loop(Game, {{0.1, 0.5}, 0.0, 0.0, 0.0, 0.0, 0.0}, {0, 0}, Time) end);
        true   -> spawn(fun() -> loop(Game, {{0.4, 0.5}, 0.0, 0.0, math:pi(), 0.0, 0.0}, {0,0}, Time) end)
    end.

keyFun(Champion, TcpMesg, NowTime) -> 
    Data = string:split(string:chomp(TcpMesg), " ", all),
    Champion ! {keyFun, Data, NowTime, self()}.


eval(Champion, NowTime) -> 
    Champion ! {eval, NowTime, self()}.

%--------------------------------------------------

loop(Game, State, Life, LastTime) ->
    receive
        {keyFun, Data, NowTime, Game} -> 
            NewState = aux_KeyFun(State, Life, Data, LastTime-NowTime),
            loop(Game, NewState, Life, NowTime);

        {eval, NowTime, Game} -> 
            NewState = update(State, Life, LastTime-NowTime),
            StringState = toString(NewState, Life),
            Game ! {state, StringState, self()},
            loop(Game, NewState, Life, NowTime)
    end.

%--------------------------------------------------







update(State, Life, Dtime) ->
    {Pos, Vel, Acc, A, Va, Acca} = State,
    {Health, Stamina} = Life,
    update(Pos, Vel, Acc, A, Va, Acca, Dtime, Health, Stamina).
update({Posx, Posy}, Velocity, Acelaration, Angle, AngularVelocity, AngularAcelaration, Dtime, _Health, _Stamina) ->
    New_AngularVelocity= AngularAcelaration*Dtime + AngularVelocity,
    New_Angle = New_AngularVelocity*Dtime + Angle,

    New_Velocity = Acelaration*Dtime + Velocity,
    New_Posx = math:cos(New_Angle)*Velocity*Dtime + Posx,
    New_Posy = math:sin(New_Angle)*New_Velocity*Dtime + Posy,

    {{New_Posx, New_Posy}, New_Velocity, Acelaration, New_Angle, New_AngularVelocity, AngularAcelaration}.


% fazer update, retornat estado com acelarçao mudad
aux_KeyFun(State, Life, Data, NowTime) ->
    [KeyState | [KeyCode | _]] = Data,
    {Pos, Vel, Acc, A, Va, Acca} = update(State, Life, NowTime),
    case KeyState of
        <<"press">> -> 
            case KeyCode of
                <<"up">>    -> {Pos, Vel, 0.0001, A, Va, Acca};
                <<"left">>  -> {Pos, Vel, Acc, A, Va, -0.0001};
                <<"right">> -> {Pos, Vel, Acc, A, Va, 0.0001}
            end;


        <<"release">> -> 
            case KeyCode of
                <<"up">>    -> {Pos, Vel, 0.0, A, Va, Acca};
                <<"left">>  -> {Pos, Vel, Acc, A, Va, 0.0};
                <<"right">> -> {Pos, Vel, Acc, A, Va, 0.0}
            end
    end.



% tranformar em sring
toString(State, Life) ->
    {Pos, Pv, Pa, Ang, Av, Aa} = State,
    {Health, Stamina} = Life,
    {X, Y} = Pos,
    toString(X, Y, Pv, Pa, Ang, Av, Aa, Health, Stamina).
toString(X, Y, Pv, Pa, Ang, Av, Aa, Health, Stamina) ->
    io_lib:format("{~f,~f,~f,~f,~f,~f,~f,~p,~p}", [X, Y, Pv, Pa, Ang, Av, Aa, Health, Stamina]).

