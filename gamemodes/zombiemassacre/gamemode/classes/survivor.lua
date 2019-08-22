
-----------------------------------------------------
local CLASS = {}

CLASS.Name = "Survivor"
CLASS.PlayerModel = ""

CLASS.SpecialItemName = "Blade Trap"
CLASS.SpecialItemDesc = "Having played too much Half-Life 2 before the outbreak, the Survivor constructed his own blade trap, with a twist: it sucks zombies in if they get too close."
CLASS.SpecialItem = "zm_item_special_blade"
CLASS.SpecialItemDelay = 60

CLASS.PowerName = "Ramming Shield"
CLASS.PowerDesc = "The Survivor took a page out of someone’s book and decided to ram into the zombies, except he took a shield, too."
CLASS.PowerLength = 10
CLASS.PowerGotSound = "GModTower/zom/powerups/powerup_generic.wav"

if CLIENT then
	CLASS.SpecialItemMat = surface.GetTextureID( "gmod_tower/zom/hud_item_blade" )
	CLASS.PowerMat = surface.GetTextureID( "gmod_tower/zom/hud_power_ramming" )
end

function CLASS:Setup( ply )

	self.Player = ply
	//ply:SetModel( self.PlayerModel )
	
end

function CLASS:PowerStart( ply )

	local ent = ents.Create( "zm_item_special_shield" )
	if !IsValid( ply.ShieldEnt ) then
		ent:SetPos( ply:GetPos() )
		--ent:SetShield( ply )
		ent:SetOwner(ply)
		ent:Spawn()

		ply.ShieldEnt = ent

		ply:SpeedUp()
		ply:EmitSound( "weapons/cguard/charging.wav", 100, 120 )
	end

end

function CLASS:PowerEnd( ply )

	if IsValid( ply.ShieldEnt ) then
		ply.ShieldEnt:Remove()
	end

	ply:ResetSpeeds()
	ply:EmitSound( "ambient/energy/powerdown2.wav", 100, 120 )

end

classmanager.Register( "survivor", CLASS )