
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_items.lua")
AddCSLuaFile("cl_admin.lua")
AddCSLuaFile("player.lua")
AddCSLuaFile("cl_admingui.lua")
AddCSLuaFile("vgui_commandbutton.lua")
include('shared.lua')
include('network.lua')
include('player.lua')
include('sql.lua')

function ClientSettings:Set( ply, id, value )
	
	if !ply._ClientSetting then
		ply._ClientSetting = {}
	end
	
	if type( id ) == "string" then
		local OldId = id
		id = self:FindByName( OldId ) or tonumber( OldId )
	end
	
	if !id then 
		if self.DEBUG then Msg("ClientSettings: Could not find id for item!\n") end
		return 
	end
	
	local Item = self.Items[ id ]
	
	if !Item then 
		if self.DEBUG then Msg("ClientSettings: Item '".. id .. "' does not exist!\n") end
		return 	
	end
	
	if value && Item.NWType != "String" then
		if Item.NWType == "Bool" then
			value = tobool( value )
		elseif Item.NWType == "Char" || Item.NWType == "Float" || Item.NWType == "Long" || Item.NWType == "Short" then
			value = tonumber( value )
			
			if Item.NWType != "Float" then
				value = math.Round( value )
			end
			
			if Item.MinValue && Item.MaxValue then
				value = math.Clamp( value, Item.MinValue, Item.MaxValue )
			end
		end
	end
		
	local OldVal = ply._ClientSetting[ id ]
	if value == nil then
		ply._ClientSetting[ id ] = Item.Default
	else
		ply._ClientSetting[ id ] = value
	end
	
	if Item.Var then
		ply[ Item.Var ] = ply._ClientSetting[ id ]
	end
	
	
	if self.DEBUG then
		Msg("CLIENTSETTING: Setting " .. Item.Name .. " of " .. tostring(ply) .. " to '" .. tostring(value) .. "' ('".. tostring(ply._ClientSetting[ id ]) .."')\n")
	end

	
	hook.Call("ClientSetting", GAMEMODE, ply, id, ply._ClientSetting[ id ] )
	
	if OldVal != ply._ClientSetting[ id ] then
		self:ValueChanged( ply )
	end

end

function ClientSettings:Reset( ply )
	
	for k, Item in pairs( self.Items ) do
		
		if Item.AllowReset != false && self:Get( ply, k ) != Item.Default then
			self:Set( ply, k, Item.Default )
		end	
		
	end	
	
end

hook.Add("Initialize", "CheckClientSettings", function()

	for k, v in pairs( ClientSettings.Items ) do
		if !umsg[ v.NWType ] then
			Msg("ATTETION: Did not find '" .. v.Name .. "' NWType for ClientSettings\n")		
		end	
	end

end )

concommand.Add("gmt_clientset", function( ply, cmd, args )
	
	if !ply:IsAdmin() then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 5, cmd, args )
		end
		return
	end
	
	if ClientSettings.DEBUG then
		Msg( ply, " entry: \n")
		PrintTable( args )
	end
	
	local PlyId = tonumber( args[1] )
	if !PlyId then return end
	
	local TargetPly = ents.GetByIndex( PlyId )
	if IsValid( TargetPly ) && TargetPly:IsPlayer() then
		ClientSettings:Set( TargetPly, tonumber( args[2] ), args[3] )
	end

end )

concommand.Add("gmt_clientreset", function( ply, cmd, args )
	
	if !ply:IsAdmin() then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 5, cmd, args )
		end
		return
	end
	
	if ClientSettings.DEBUG then
		Msg( ply, " RESET: \n")
		PrintTable( args )
	end
	
	local PlyId = tonumber( args[1] )
	if !PlyId then return end
	
	local TargetPly = ents.GetByIndex( PlyId )
	if IsValid( TargetPly ) && TargetPly:IsPlayer() then
		ClientSettings:Reset( TargetPly ) 
	end

end )