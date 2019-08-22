
/*
lua_openscript GModTower/suitecheck.lua
Running script GModTower/suitecheck.lua...
Counted         3780     users.
 MinX =         -16.25
 MinY =         -305.79
 MinZ =         -305.79
 MaxX =         320.61
 MaxY =         730.8
 MaxZ =         730.8
 MinPa =        -90
 MinYa =        -180
 MinRa =        -180
 MaxPa =        90
 MaxYa =        180
 MaxRa =        180

 
 MinY = MinZ?!
 
Anyway, it seems to work.

*/

local InProgress = 0
local Count = 0

local MinX = 0
local MinY = 0
local MinZ = 0
local MaxX = 0
local MaxY = 0
local MaxZ = 0

local MinPa = 0
local MinYa = 0
local MinRa = 0
local MaxPa = 0
local MaxYa = 0
local MaxRa = 0



local function SelectUsersfunction( res, status, err )

	if status != 1 then
		Error( err )
	end
	
	for _, v in pairs( res ) do
	
		local Data = Hex( v[1] )
		
		while Data:CanRead( 42 ) do
	
			local ItemId = Data:Read( 4 )
			local PosX = (Data:Read( 8 ) - 2147483648) / 100
			local PosY = (Data:Read( 8 ) - 2147483648) / 100 
			local PosZ = (Data:Read( 8 ) - 2147483648) / 100 
			local AngP = (Data:Read( 5 ) - 18000) / 100
			local AngY = (Data:Read( 5 ) - 18000) / 100
			local AngR = (Data:Read( 5 ) - 18000) / 100
			
			MinX = math.min( PosX, MinX )
			MinY = math.min( PosY, MinY )
			MinZ = math.min( PosY, MinZ )
			
			MaxX = math.max( PosX, MaxX )
			MaxY = math.max( PosY, MaxY )
			MaxZ = math.max( PosY, MaxZ )
			
			MinPa = math.min( AngP, MinPa )
			MinYa = math.min( AngY, MinYa )
			MinRa = math.min( AngR, MinRa )
			
			MaxPa = math.max( AngP, MaxPa)
			MaxYa = math.max( AngY, MaxYa )
			MaxRa = math.max( AngR, MaxRa )
		
		end
		
		Count = Count + 1
	
	end
	
	InProgress = InProgress - 1
	
	if InProgress == 0 then
		
		print("Counted " ,Count, " users.")
		
		print(" MinX = ", MinX)
		print(" MinY = ", MinY)
		print(" MinZ = ", MinZ)
		print(" MaxX = ", MaxX)
		print(" MaxY = ", MaxY)
		print(" MaxZ = ", MaxZ)

		print(" MinPa = ", MinPa)
		print(" MinYa = ", MinYa)
		print(" MinRa = ", MinRa)
		print(" MaxPa = ", MaxPa)
		print(" MaxYa = ", MaxYa)
		print(" MaxRa = ", MaxRa)

		
	end
	
end
if string.StartWith(game.GetMap(),"gmt_build0s2b") or string.StartWith(game.GetMap(),"gmt_0c3") then
local WhereClause = "WHERE LastOnline>" .. (os.time()-60*60*24*7*8) .. " AND LENGTH(`roomdata`)>50" 
elseif string.StartWith(game.GetMap(),"gmt_build0h") or string.StartWith(game.GetMap(),"gmt_002a") then
local WhereClause = "WHERE LastOnline>" .. (os.time()-60*60*24*7*8) .. " AND LENGTH(`romdata`)>50" 
else
local WhereClause = "WHERE LastOnline>" .. (os.time()-60*60*24*7*8) .. " AND LENGTH(`rumdata`)>50" 
end
local function StartSelectingUsers( res, status, err )

	if status != 1 then
		Error( err )
	end
	
	local Count = res[1].data
	local Step = 500
	
	for i=0, Count, Step do
		
		InProgress = InProgress + 1
		if string.StartWith(game.GetMap(),"gmt_build0s2b") or string.StartWith(game.GetMap(),"gmt_0c3") then
		SQL.getDB():Query("SELECT HEX(`roomdata`) FROM `gm_users` "..WhereClause.." LIMIT "..i..","..Step, SelectUsersfunction )
		elseif string.StartWith(game.GetMap(),"gmt_build0h") or string.StartWith(game.GetMap(),"gmt_002a") then
		SQL.getDB():Query("SELECT HEX(`romdata`) FROM `gm_users` "..WhereClause.." LIMIT "..i..","..Step, SelectUsersfunction )
		else
		SQL.getDB():Query("SELECT HEX(`rumdata`) FROM `gm_users` "..WhereClause.." LIMIT "..i..","..Step, SelectUsersfunction )
		end

	end	

end

SQL.getDB():Query("SELECT COUNT(id) FROM `gm_users` " .. WhereClause, StartSelectingUsers )