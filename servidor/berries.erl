-module(berries).
-export([start/2, eval/3]).

%--------------------------------------------------
% API

start(Game, Color) ->
    spawn(fun() -> loop(Game, Color,[]) end).

eval(Champion, Players, DiffTime) -> 
    Champion ! {eval, Players, DiffTime, self()}.

%--------------------------------------------------

loop(Game, Color, Berries) ->
    receive
        {eval, Players, Dtime, Game} -> 
            NewBerries = update(Berries, Color, Players, Dtime),
            StringState = toString(NewBerries),
            Game ! {state, StringState, self()},
            loop(Game, Color, Berries);

        {send_enemy,Game} ->
            New_Berries = addBerrie(Berries),
            loop(Game, Color, New_Berries)

    end.

%--------------------------------------------------


addBerrie(Berries) ->
    {rand:uniform(), rand:uniform()} ++ Berries.


update(Berries, Color, Players, Dtime) when Color == red    -> updateRed(Berries, Players, Dtime);
update(Berries, Color, Players,_Dtime) when Color == green  -> updateGreen(Berries, Players).



updateGreen(Berries, {P1, P2}) ->
    C1 = lists:filter(fun(B) -> noCollision(B, P1) end, Berries),
    C2 = lists:filter(fun(B) -> noCollision(B, P2) end, Berries),
    {ordsets:intersection(C1, C2), lists:flatlength(C1), lists:flatlength(C2)}.

updateRed(Berries, {P1, P2},_Dtime) ->
    C1 = lists:filter(fun(B) -> noCollision(B, P1) end, Berries),
    C2 = lists:filter(fun(B) -> noCollision(B, P2) end, Berries),
    {ordsets:intersection(C1, C2), lists:flatlength(C1), lists:flatlength(C2)}.



noCollision({Bx, By}, {Px,Py}) ->
    math:sqrt( math:pow((Px-Bx),2) + math:pow((Py-By),2) ) < 24.

% tranformar em sring
toString(Berries) ->
    BerriesString = lists:foldr(fun(X) -> berrieToString(X) end, "",Berries),
    io_lib:format("[" ,BerriesString ,"]").

berrieToString({X, Y}) ->
    io_lib:format("~p,~p", [X,Y]).
