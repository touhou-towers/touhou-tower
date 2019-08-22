
include('shared.lua')
include("cl_admin.lua")
include('player.lua')
include("cl_admingui.lua")

usermessage.Hook("PlySett", function(um)

	local PlyId = um:ReadChar()
	local ply = ents.GetByIndex( PlyId )
	local IsAdmin = um:ReadBool()
	
	if !IsValid( ply ) then
		return
	end
	
	if !ply._ClientSetting then
		ply._ClientSetting = {}
	end
	
	if ClientSettings.DEBUG then Msg("Recieving NW of " .. tostring( ply ) .. "\n") end
	
	for k, v in ipairs( ClientSettings.Items ) do
		if ( IsAdmin || ( v.SendType == true && ply == LocalPlayer() ) ) && um[ "Read" .. v.NWType ] then
			
			local OldVal = ply._ClientSetting[ k ]
			local NewVal 
			
			if v.NWType == "Bool" then	
				NewVal = um:ReadBool()
				if ClientSettings.DEBUG then Msg("\t Recieving ".. v.Name .. " bool: ".. tostring(NewVal) .. "\n") end
			else
				local IsDefault = um:ReadBool()
				
				if IsDefault then
					NewVal = v.Default
				else
					NewVal = um[ "Read" .. v.NWType ]( um )
				end
				
				if ClientSettings.DEBUG then Msg("\t Recieving " .. v.Name .. " value(".. tostring(IsDefault) .."): ".. tostring(NewVal) .. "\n") end
			end
			
			
			ply._ClientSetting[ k ] = NewVal
			
			if OldVal != ply._ClientSetting then
				hook.Call("ClientSetting", GAMEMODE, ply, k, NewVal )
			end
			
			if v.Var then
				ply[ v.Var ] = NewVal
			end
			
		end
	end
	
end )

hook.Add("Initialize", "ResetClientSettings", function( ply )
	ClientSettings:ResetValues( LocalPlayer() )
end )