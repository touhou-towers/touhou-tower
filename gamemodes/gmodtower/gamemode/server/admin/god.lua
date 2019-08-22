
hook.Add("AdminCommand", "EnableGodMode", function( args, admin, ply )

	if args[1] == "god" then		
		ClientSettings:Set( ply, "God mode", !ply.GTGodMode )
	end

end )


hook.Add("ClientSetting", "CheckGodMode", function( ply, id, val )

	if hook.Call("AllowSpecialAdmin", GAMEMODE, ply ) == false then
		return
	end

	if ClientSettings:CompareId( id, "GTGodMode" ) then
	
		if val == true then
			ply:GodEnable()
		else
			ply:GodDisable()
		end
		
	end

end )

hook.Add("PlayerSpawn", "AdminCheckGodmode", function( ply )
	
	if hook.Call("AllowSpecialAdmin", GAMEMODE, ply ) == false then
		return
	end
	
	if ply:GetSetting( "GTGodMode" ) == true then
		ply:GodEnable()
	end

end )

function FixPlayerFrozen(ply)
	if IsValid(ply) then
		ply:Freeze(false)
	end
end
hook.Add( "PlayerSilentDeath", "GTowerFixFrozenSilent", FixPlayerFrozen)
hook.Add("PlayerDeath", "GTowerFixFrozen", FixPlayerFrozen)

local Meta = FindMetaTable( "Player" )

if Meta then
	if gamemode.Get( "deathrun" ) then
		local oldFreeze = Meta.Freeze
		function Meta:Freeze(value)
			if self:IsAdmin() && value == true then
				return
			end
		
			oldFreeze(self, value)
		end
	end
	
	function Meta:ResetGod()
		
		if self:GetSetting( "GTGodMode" ) == true then
			self:GodEnable()
		else
			self:GodDisable()
		end
	end

end