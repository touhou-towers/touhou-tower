ENT.Type = "anim"ENT.Base = "zm_item_special_base"
ENT.Radius 		= 230
ENT.RemoveDelay = 40
ENT.Model = Model( "models/items/healthkit.mdl" )
ENT.StartChargeSound = Sound( "items/smallmedkit1.wav" )
ENT.ChargingSound = Sound( "combine.sheild_loop" )
ENT.EndChargeSound = Sound( "buttons/combine_button2.wav" )
function ENT:IsInRadius( ent )
	return self:GetPos():Distance( ent:GetPos() ) < self.Radius
end