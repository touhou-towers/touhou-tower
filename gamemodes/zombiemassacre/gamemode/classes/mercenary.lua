
-----------------------------------------------------
local CLASS = {}

CLASS.Name = "Mercenary"
CLASS.PlayerModel = ""

CLASS.SpecialItemName = "A.L.P.S."
CLASS.SpecialItemDesc = "A.L.P.S., or Automatic Laser Protection System, sends a frequency up to a satellite in orbit, and uses precision lasers to take out its targets."
CLASS.SpecialItem = "zm_item_special_laser"
CLASS.SpecialItemDelay = 60

CLASS.PowerName = "Focus Shoot"
CLASS.PowerDesc = "The Mercenary has a steady trigger finger, but when he really focuses, he can aim and shoot without even thinking about it."
CLASS.PowerLength = 8
CLASS.PowerGotSound = "GModTower/zom/powerups/powerup_mercenary.wav"

if CLIENT then
	CLASS.SpecialItemMat = surface.GetTextureID( "gmod_tower/zom/hud_item_laser" )
	CLASS.PowerMat = surface.GetTextureID( "gmod_tower/zom/hud_power_focus" )
end

function CLASS:Setup( ply )

	self.Player = ply
	//ply:SetModel( self.PlayerModel )

end

function CLASS:PowerStart( ply )

	ply:SetNWBool( "IsFocused", true )

	ply:Give( "weapon_zm_special_focus" )

	ply._LastSelectedWeapon = ply:GetActiveWeapon():GetClass()
	ply:SelectWeapon( "weapon_zm_special_focus" )

	ply:EmitSound( "GModTower/zom/powerups/focus.wav" )

	timer.Simple(self.PowerLength,function()
		ply:SetNWBool( "IsPowerCombo", false )
		ply:SetNWInt( "Combo", 0 )
		ply:SetNWBool( "IsFocused", false )
		ply:SelectWeapon( ply._LastSelectedWeapon )
		ply:StripWeapon( "weapon_zm_special_focus" )
	end)

end

function CLASS:PowerEnd( ply )

	ply:SetNWBool( "IsFocused", false )

	ply:StripWeapon( "weapon_zm_special_focus" )
	ply:SelectWeapon( ply._LastSelectedWeapon )

end

if CLIENT then

	local function DrawFocusTarget( ent )

		if !IsValid( ent ) then return end

		local pos = ( ent:GetPos() ):ToScreen()
		local size = 64

		local x, y = pos.x, pos.y

		// Work out sizes.
		local a, b = size / 2, size / 6

		surface.SetDrawColor( 255, 255, 255, 255 )

		// Top left.
		surface.DrawLine(x - a, y - a, x - b, y - a)
		surface.DrawLine(x - a, y - a, x - a, y - b)

		// Bottom right.
		surface.DrawLine(x + a, y + a, x + b, y + a)
		surface.DrawLine(x + a, y + a, x + a, y + b)

		// Top right.
		surface.DrawLine(x + a, y - a, x + b, y - a)
		surface.DrawLine(x + a, y - a, x + a, y - b)

		// Bottom left.
		surface.DrawLine(x - a, y + a, x - b, y + a)
		surface.DrawLine(x - a, y + a, x - a, y + b)

	end

	hook.Add( "HUDPaint", "FocusTargeting", function()

		for _, ply in pairs( player.GetAll() ) do

			if ply:GetNWBool( "IsFocused" ) && IsValid( ply.FocusEnemy ) then
				DrawFocusTarget( ply.FocusEnemy )
			end

		end

	end )

end

classmanager.Register( "mercenary", CLASS )
