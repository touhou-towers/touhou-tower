local GtowerLangush = GtowerLangush

module("minigames.fun")

GtowerLangush.AddWord( 1, "FunGameStart", "The Eruption of Fun has arrived!")

MinigameName = "Fun"
MinigameMessage = "FunGameStart"

------------------------------------------------------------------------------------------------------------
FunPerPlayer = 100 // This gets multiplied with the amount of players, and will be set as the max the funmeter can go.
JumpFun = 2 // The amount of fun you get from jumping. NOTE this value will have the RunFun added to it!
RunFun = 1 // The amount of fun you get for each step.
ChatFun = 5 // The amount of fun you get from chatting.
DanceFun = 10 // The amount of fun you get from dancing.
SpendFun = 10 // The amount of fun you get from spending.
------------------------------------------------------------------------------------------------------------