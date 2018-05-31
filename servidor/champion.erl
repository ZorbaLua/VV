-module(champion).
-export([start/3, keyFun/3, eval/2]).

%--------------------------------------------------
% API

start(Game, I, Time) ->
    if 
        I == 1 -> spawn(fun() -> loop(Game, {{0.3, 0.5}, {0.0, 0.0}, 0.0,  math:pi()/4, 0.0, 0.0}, {3,100}, Time) end);
        true   -> spawn(fun() -> loop(Game, {{0.7, 0.5}, {0.0, 0.0}, 0.0, -math:pi()/4, 0.0, 0.0}, {3,100}, Time) end)
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


        {eval, NowTime, Game} -> evalAux(Game, State, Life, LastTime, NowTime);


        {lostLife, I, Game} ->
            {Health, Stamina} = Life,
            NewHealth = Health-I,
            if 
                   Health<0 -> Game ! {dead, self()};
                   true -> loop(Game, State, {NewHealth, Stamina}, LastTime)
            end;

        {earnStamina, I,Game} ->
            {Health, Stamina} = Life,
            loop(Game, State, {Health, ((Stamina+I*30) rem 100)}, LastTime);

        {finish, Game} -> free


    end.


%--------------------------------------------------

evalAux(Game, State, Life, LastTime, NowTime) ->
    NewState = update(State, Life, LastTime-NowTime),
    {Pos,_,_,_,_,_} = NewState,
    {Health, Stamina} = Life,
    if 
        Health =< 0 -> Game ! {dead, self()};
        true ->
            {X, Y} = Pos, 
            if 
                (X>1) or (X<0) or (Y>1) or (Y<0) -> 
                    ResetState = {{0.5, 0.5},{0.0,0.0},0.0,math:pi(),0.0,0.0},
                    StringState = toString(ResetState,{Health-1, Stamina}),
                    Game ! {ok, {StringState, Pos}, self()},
                    loop(Game,ResetState, {Health-1, Stamina}, NowTime);

                true ->
                    StringState = toString(NewState, Life),
                    Game ! {ok, {StringState, Pos}, self()},
                    loop(Game, NewState, Life, NowTime)
            end
    end.






update(State, Life, Dtime) ->
    {Pos, Vel, Ace, A, Va, Acca} = State,
    {Health, Stamina} = Life,
    update(Pos, Vel, Ace, A, Va, Acca, Dtime, Health, Stamina).
update({Posx, Posy}, {Velx, Vely}, Ac, Angle, AngularVelocity, AngularAcelaration, Dtime, _Health, _Stamina) ->
    New_AngularVelocity= AngularAcelaration*Dtime + AngularVelocity,
    New_Angle = (New_AngularVelocity*Dtime + Angle),

    New_Acex = math:cos(New_Angle)*Ac,
    New_Acey = math:sin(New_Angle)*Ac,

    New_Velx = New_Acex*Dtime + Velx,
    New_Vely = New_Acey*Dtime + Vely,
    
    New_Posx = New_Velx*Dtime + Posx,
    New_Posy = New_Vely*Dtime + Posy,

    {{New_Posx, New_Posy}, {New_Velx, New_Vely}, Ac, New_Angle, New_AngularVelocity, AngularAcelaration}.


% fazer update, retornat estado com acelarçao mudad
aux_KeyFun(State, Life, Data, NowTime) ->
    [KeyState | [KeyCode | _]] = Data,
    {Pos, Vel, Acc, A, Va, Acca} = update(State, Life, NowTime),

    case KeyState of
        <<"press">> -> 
            case KeyCode of
                <<"up">>    -> {Pos, Vel, 1/10000000, A, Va, Acca};
                <<"left">>  -> {Pos, Vel, Acc, A, Va,  1/1000000};
                <<"right">> -> {Pos, Vel, Acc, A, Va, -1/1000000}
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
    {Pos, Vel, Ace, Ang, Av, Aa} = State,
    {Health, Stamina} = Life,
    {X, Y} = Pos,
    {VX, VY} = Vel,
    toString(X, Y, VX, VY, Ace, Ang, Av, Aa, Health, Stamina).
toString(X, Y, VX, VY, Ace, Ang, Av, Aa, Health, Stamina) ->
    io_lib:format("{~f,~f,~f,~f,~f,~f,~f,~f,~p,~p}", [X, Y, VX, VY, Ace, Ang, Av, Aa, Health, Stamina]).

