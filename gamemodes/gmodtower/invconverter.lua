
local InProgress = 0

function NewEncode( ItemList )

	local Data = Hex()
	
	for k, v in pairs( ItemList ) do
		
		Data:Write( v[1], 4 )
		Data:Write( v[2], 4 )
		Data:WriteString( v[3] or "" )
	
	end
	
	return Data:Get()

end 

local function UpdateResult( res, status, err  )
	
	if status != 1 then
		Error( err )
	end
	
	InProgress = InProgress - 1
	
	if InProgress % 100 == 0 then
		Msg("Progress: ".. InProgress .."!\n")
	end
	
	if InProgress == 0 then
		Msg("All process completed!\n")
	end

end

local function SelectUsersfunction( res, status, err )

	if status != 1 then
		Error( err )
	end
	
	for _, v in pairs( res ) do
	
		local InvData = NewEncode( GTowerItems:Decode( v[2] ) )
		local BankData = NewEncode( GTowerItems:Decode( v[3] ) )
		
		InProgress = InProgress + 1
		SQL.getDB():Query("UPDATE `gm_users` SET `inventory`="..InvData..",`bank`="..BankData.." WHERE id=".. v[1], UpdateResult )
	
	end
	
	Msg("Total in progress: " .. InProgress .. "\n")
	
end

local function StartSelectingUsers( res, status, err )

	if status != 1 then
		Error( err )
	end
	
	local Count = res[1].data[1]
	local Step = 500
	
	for i=0, Count, Step do
		
		SQL.getDB():Query("SELECT id,HEX(`inventory`),HEX(`bank`) FROM `gm_users` LIMIT "..i..","..Step, SelectUsersfunction )
		
	end	

end

SQL.getDB():Query("SELECT COUNT(id) FROM `gm_users`", StartSelectingUsers )