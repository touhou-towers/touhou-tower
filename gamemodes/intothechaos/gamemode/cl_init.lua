
// === FILE INCLUDING ===

include( "shared.lua" )
include( "meta_player.lua" )
include( "sh_sfx.lua" )
include( "cl_doors.lua" )
include( "cl_hud.lua" )

// === GENERAL FUNCTIONS ===

function GM:Think()
	local dlight = DynamicLight( LocalPlayer():EntIndex() )
	if ( dlight ) then
		dlight.pos = LocalPlayer():GetShootPos()
		dlight.r = 10
		dlight.g = 75
		dlight.b = 255
		dlight.brightness = 255
		dlight.Decay = 1000
		dlight.Size = 100
		dlight.DieTime = CurTime() + 1
	end
end

// === HIDE HUD ELEMENTS ===

local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
  ["CHudAmmo"] = true,
  ["CHudSecondaryAmmo"] = true,
}

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if ( hide[ name ] ) then return false end
end )

// === DISABLES JUMPING ===

hook.Add( "PlayerBindPress", "DisableJump", function( ply, bind, pressed )
	if ( bind == "+jump" && ply:Alive() ) then return true end
end )


hook.Add( "PlayerBindPress", "GetOutOfTrain", function( ply, bind, pressed )
	if bind == "+use" && ply:InVehicle() then
		RunConsoleCommand("gmt_leavetrain")
    return true
  end
end )
