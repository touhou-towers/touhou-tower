


module("InventorySaver", package.seeall )

local ToLoad = {}
local Count = 0
local NextLoad = 0

local function ThinkLoadEnts()

	if NextLoad > CurTime() then
		return
	end
	
	if table.Count( ToLoad ) > 0 then
		local ItemInfo = table.remove( ToLoad )
	
		local Item = GTowerItems:CreateById( ItemInfo.InvItem, ItemInfo.owner )
		
		if !Item then
			return
		end
		
		local DropEnt = Item:OnDrop()
		local VarType = type( DropEnt )
		
		if VarType == "Entity" || VarType == "Weapon" then //Returned a entity to be set
			
			DropEnt:SetPos( ItemInfo.pos )
			DropEnt:SetAngles( ItemInfo.ang )
			DropEnt._GTInvSQLId = Item.MysqlId
		
			DropEnt:Spawn()

			local phys = DropEnt:GetPhysicsObject()
			
			if IsValid( phys ) then
				phys:EnableMotion(false)
			end
			
			if !DropEnt:IsInWorld() then
				DropEnt:Remove()
			end

		else
			SQLLog('sqldebug', "WARNING! ROOM: DROPPED ENT AND OnDrop DID NOT RETURN AN ENTITY!\n")
		end
		
		Count = Count + 1
		
		if Count == 10 then
			Count = 0
			NextLoad = CurTime() + 0.25
		end
	
	else
	
		hook.Remove("Think", "ThinkLoadEnts" )
		
	end
	
end

concommand.Add("gmt_invload", function( ply, cmd, args )

	if !Allow( ply ) then
		return
	end
	
	local SaveName = args[1]
	
	if !SaveName || string.len( SaveName ) <= 1 then
		return
	end
	
	local CleanSaveName =  SQL.getDB():Escape( SaveName )
	
	 SQL.getDB():Query( "SELECT HEX(`data`) FROM `gm_invsaves` WHERE `Name`='" .. CleanSaveName .. "'", function(result, status, error)
		if status != 1 then     
			SQLLog('error', "InvLoad error " .. tostring(error) )
			return
		end
		
		if table.Count( result ) == 0 then
			ply:Msg2("No saves found")
			return
		end
		
		local Data = Hex( result[1][1] )
		local MinVec = Data:ReadVector()
		local MaxVec = Data:ReadVector()
		ply._InvLoadingData = {}
		
		while Data:CanRead( 4 + 24 + 15 ) do
		
			local ItemId = Data:Read( 4 )
			local Pos = Data:ReadVector()
			local Ang = Data:ReadAngles()
			
			table.insert( ply._InvLoadingData, {
				["InvItem"] = ItemId,
				["pos"] = Pos,
				["ang"] = Ang
			}  )
			
		end
		
		umsg.Start( "InvSaver", ply )
			umsg.Char( 0 )
			umsg.Vector( MinVec )
			umsg.Vector( MaxVec )
		umsg.End()
		
	end )


end )

concommand.Add("gmt_invendload", function( ply, cmd, args )

	if !Allow( ply ) then
		return
	end
	
	umsg.Start( "InvSaver", ply )
		umsg.Char( 1 )
	umsg.End()
	
	if !ply._InvLoadingData then
		return
	end

	local OldPlayerAngles = ply:GetAngles()
	ply:SetAngles( Angle(0,0,0) )
	
	hook.Add("Think", "ThinkLoadEnts", ThinkLoadEnts )
	
	for _, v in pairs( ply._InvLoadingData ) do
		
		local Pos = ply:LocalToWorld( v.pos )
		local Ang = ply:LocalToWorldAngles( v.ang )
		
		table.insert( ToLoad, {
			["InvItem"] = v.InvItem,
			["pos"] = Pos,
			["ang"] = Ang,
			["owner"] = ply
		} )	
	
	end
	
	ply._InvLoadingData = nil
	
	ply:SetAngles( OldPlayerAngles )
	
end )