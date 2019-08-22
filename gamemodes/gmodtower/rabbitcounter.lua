
local RabbitCount = {}
local InProgress = 0
local Users = 0
local TotalCount = 0

for _, v in pairs( RabbitItems ) do
	RabbitCount[ v.MysqlId ] = 0
end


local function AddToCount( data )
	
	local Data = GTowerItems:Decode( data )
	local HasSpecial = false
	
	for _, v in pairs( Data ) do 
			
		for _, v2 in pairs( RabbitItems ) do
			if v2.MysqlId == v[2] then
				RabbitCount[ v2.MysqlId ] = RabbitCount[ v2.MysqlId ] + 1
				TotalCount = TotalCount + 1
				
				if v2.Name == "GBuhyena Rabbit" then
					HasSpecial = true
				end
			end				
		end
	end
	
	return HasSpecial
end

local function SelectUsersfunction( res, status, err )

	if status != 1 then
		Error( err )
	end
	
	for _, v in pairs( res ) do
		
		local CountInv = AddToCount( v[1] )
		local CountBank = AddToCount( v[2] )
		
		if CountInv == true || CountBank == true then
			print( v[4], v[3] )
		end
		
		Users = Users + 1
	
	end
	
	InProgress = InProgress - 1
	
	if InProgress == 0 then
		Msg( "Users: " , Users, " (Rabbits found: ", TotalCount ,")\n" )
		
		local EndTable = {}
		
		for k, v in pairs( RabbitItems ) do
			table.insert( EndTable, {v.Name, RabbitCount[ v.MysqlId ] } )
		end
		
		table.sort( EndTable, function(a,b)
			return a[2] > b[2]
		end )
		
		for _, v in pairs( EndTable ) do
			print( v[1], " = ", v[2] )
		end
		
	end
	
end

local function StartSelectingUsers( res, status, err )

	if status != 1 then
		Error( err )
	end
	
	local Count = tonumber( res[1][1] )
	local Step = 500
	
	for i=0, Count, Step do
		
		InProgress = InProgress + 1
		SQL.getDB():Query("SELECT HEX(`inventory`),HEX(`bank`),`steamid`,`name` FROM `gm_users` LIMIT "..i..","..Step, SelectUsersfunction )

	end	

end

SQL.getDB():Query("SELECT COUNT(id) FROM `gm_users`", StartSelectingUsers )