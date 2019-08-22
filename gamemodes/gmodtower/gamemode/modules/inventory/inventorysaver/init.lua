
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_load.lua")

include("shared.lua")
include("load.lua")

module("InventorySaver", package.seeall )

function IsSaving( ply )
	return ply._InvSaveName != nil
end

function CanSelect( ply )
	return IsSaving( ply ) && Allow( ply )
end

function Select( ply, ent )

	if !CanSelect( ply ) then
		return
	end
	
	local InvId = GTowerItems:FindByEntity( ent )
	
	if InvId == nil then
		return
	end
	
	if table.HasValue( ply._InvSaveEntities, ent ) then
		return
	end
	
	table.insert( ply._InvSaveEntities, ent )
	ent:SetMaterial( SaveMaterial )	

end

function UnSelect( ply, ent )

	if !IsSaving( ply ) then
		return
	end
	
	for k, v in pairs( ply._InvSaveEntities ) do
		
		if v == ent then
			table.remove( ply._InvSaveEntities, k )
			ent:SetMaterial("")			
		end
		
	end
	
end

function Clean( ply )
	
	if ply._InvSaveEntities then
		
		for k, v in pairs( ply._InvSaveEntities ) do
			
			v:SetMaterial("")
		
		end
		
		ply._InvSaveEntities = {}
		
	end
	
	ply._InvSaveName = nil
	
end

concommand.Add("gmt_invsaveName", function( ply, cmd, args )
	
	if !InventorySaver.Allow( ply ) then
		return
	end
	
	if args[1] == nil then
		Clean( ply )
		return
	end
	
	ply._InvSaveName = args[1]
	ply._InvSaveEntities = {}

end )

concommand.Add("gmt_invsaveend", function( ply, cmd, args )

	if !CanSelect( ply ) then
		return
	end
	
	if ply._InvSaveName && ply._InvSaveEntities then
		Save( ply, ply._InvSaveName, ply._InvSaveEntities )
	end

end )

function Save( ply, Name, EntList )
	
	local OldPlayerAngles = ply:GetAngles()
	ply:SetAngles( Angle(0,0,0) )
	
	local Data = Hex()
	local Min, Max = nil, nil
	
	for k, ent in pairs( EntList ) do
		
		if IsValid( ent ) then
		
			if !Min then
				Min, Max = ent:WorldSpaceAABB()
			else
				
				local NewMin, NewMax = ent:WorldSpaceAABB()
				
				if NewMin.x < Min.x then Min.x = NewMin.x end
				if NewMin.y < Min.y then Min.y = NewMin.y end
				if NewMin.z < Min.z then Min.z = NewMin.z end
				if NewMax.x > Max.x then Max.x = NewMax.x end
				if NewMax.y > Max.y then Max.y = NewMax.y end
				if NewMax.z > Max.z then Max.z = NewMax.z end
				
			end
		
		end
		
	end
	
	if Min == nil || Max == nil then
		Error("Unable to save inventory (debug EntList: " .. table.Count(EntList) .. ")")
	end
	
	Data:WriteVector( ply:WorldToLocal( Min ) )
	Data:WriteVector( ply:WorldToLocal( Max ) )
	
	for k, ent in pairs( EntList ) do
		
		if IsValid( ent ) then
			
			local Pos = ply:WorldToLocal( ent:GetPos() )
			local Ang = ply:WorldToLocalAngles( ent:GetAngles() )
			local InvItem = GTowerItems:FindByEntity( ent )
			
			Data:Write( InvItem, 4 )
			Data:WriteVector( Pos )
			Data:WriteAngles( Ang )
		
		end
		
	end
	
	ply:SetAngles( OldPlayerAngles )
	Clean( ply )
	
	local CleanName =  SQL.getDB():Escape( Name )
	
	local Query = "REPLACE INTO `gm_invsaves`(`Name`,`data`,`owner`) VALUES('".. CleanName .."',".. Data:Get() ..",".. ply:SQLId() ..")"
	
	 SQL.getDB():Query( Query, function(result, status, error)
		if status != 1 then     
			SQLLog('error', "DatabaseUpdate error " .. tostring(error) )
		end
	end )

end