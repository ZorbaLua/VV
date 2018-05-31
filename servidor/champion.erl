-module(champion).
-export([start/3, keyFun/3, eval/2]).

%--------------------------------------------------
% API

start(Game, I, Time) ->
    if 
        I == 1 -> spawn(fun() -> loop(Game, {{0.3, 0.5}, {0.0, 0.0}, {0.0, 0.0}, math:pi()/2, 0.0, 0.0}, {0,0}, Time) end);
        true   -> spawn(fun() -> loop(Game, {{0.7, 0.5}, {0.0, 0.0}, {0.0, 0.0}, -math:pi()/2 , 0.0, 0.0}, {0,0}, Time) end)
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
            {Pos,_,_,_,_,_} = NewState,
            StringState = toString(NewState, Life),
            Game ! {ok, {StringState, Pos}, self()},
            loop(Game, NewState, Life, NowTime)
    end.


%--------------------------------------------------







update(State, Life, Dtime) ->
    {Pos, Vel, Ace, A, Va, Acca} = State,
    {Health, Stamina} = Life,
    update(Pos, Vel, Ace, A, Va, Acca, Dtime, Health, Stamina).
update({Posx, Posy}, {Velx, Vely}, {Acex, Acey}, Angle, AngularVelocity, AngularAcelaration, Dtime, _Health, _Stamina) ->
    New_AngularVelocity= AngularAcelaration*Dtime + AngularVelocity,
    New_Angle = (New_AngularVelocity*Dtime + Angle) / (math:pi()*2),

    New_Acex = math:cos(New_Angle)*Acex*Dtime,
    New_Acey = math:sin(New_Angle)*Acey*Dtime,

    New_Velx = math:cos(Angle - New_Angle)*New_Acex*Dtime + Velx,
    New_Vely = math:sin(Angle - New_Angle)*New_Acey*Dtime + Vely,
    
    New_Posx = New_Velx*Dtime + Posx,
    New_Posy = New_Vely*Dtime + Posy,

    {{New_Posx, New_Posy}, {New_Velx, New_Vely}, {New_Acex, New_Acey}, New_Angle, New_AngularVelocity, AngularAcelaration}.


% fazer update, retornat estado com acelarçao mudad
aux_KeyFun(State, Life, Data, NowTime) ->
    [KeyState | [KeyCode | _]] = Data,
    {Pos, Vel, Acc, A, Va, Acca} = update(State, Life, NowTime),

    case KeyState of
        <<"press">> -> 
            case KeyCode of
                <<"up">>    -> {Pos, Vel, {math:cos(A)*0.0000000001, math:cos(A)*0.0000000001}, A, Va, Acca};
                <<"left">>  -> {Pos, Vel, Acc, A, Va, -0.0000001};
                <<"right">> -> {Pos, Vel, Acc, A, Va, 0.0000001}
            end;


        <<"release">> -> 
            case KeyCode of
                <<"up">>    -> {Pos, Vel, {0.0, 0.0}, A, Va, Acca};
                <<"left">>  -> {Pos, Vel, Acc, A, Va, 0.0};
                <<"right">> -> {Pos, Vel, Acc, A, Va, 0.0}
            end
    end.



% tranformar em sring
toString(State, Life) ->
    {Pos, Vel, Ace, Ang, Av, Aa} = State,
    {Health, Stamina} = Life,
    {X, Y} = Pos,
    {VX, VY} = Vel,
    {AX, AY} = Ace,
    toString(X, Y, VX, VY, AX, AY, Ang, Av, Aa, Health, Stamina).
toString(X, Y, VX, VY, AX, AY, Ang, Av, Aa, Health, Stamina) ->
    io_lib:format("{~f,~f,~f,~f,~f,~f,~f,~f,~f,~p,~p}", [X, Y, VX, VY, AX, AY, Ang, Av, Aa, Health, Stamina]).

