
-----------------------------------------------------
local CLASS = {}

CLASS.Name = "Electrician"
CLASS.PlayerModel = ""

CLASS.SpecialItemName = "Home-made Turret"
CLASS.SpecialItemDesc = "Constructed from some scrap metal, the automatic targeting turret pops out of the ground and provides excellent area denial."
CLASS.SpecialItem = "zm_item_special_turret"
CLASS.SpecialItemDelay = 60

CLASS.PowerName = "Tesla Zap"
CLASS.PowerDesc = "Having adapted a tesla coil for his own needs, the Electrician can shock zombies within range."
CLASS.PowerLength = 10
CLASS.PowerGotSound = "GModTower/zom/powerups/powerup_electrician.wav"

if CLIENT then
	CLASS.SpecialItemMat = surface.GetTextureID( "gmod_tower/zom/hud_item_turret" )
	CLASS.PowerMat = surface.GetTextureID( "gmod_tower/zom/hud_power_tesla" )
end

function CLASS:Setup( ply )

	self.Player = ply
	//ply:SetModel( self.PlayerModel )

end

function CLASS:PowerStart( ply )

	local ent = ents.Create( "zm_item_special_tesla" )
	ent:SetPos( ply:GetPos() )
	ent:SetShocker( ply )
	ent:Spawn()

	ply.TeslaEnt = ent

end

function CLASS:PowerEnd( ply )

	if IsValid( ply.TeslaEnt ) then
		ply.TeslaEnt:Remove()
	end

end

classmanager.Register( "electrician", CLASS )
