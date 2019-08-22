ENT.Type = "anim"
ENT.Base = "zm_item_special_base"
ENT.Radius 		= 256
ENT.RemoveDelay = 30
ENT.Model = Model( "models/weapons/w_vir_tnt.mdl" )
ENT.Sound = Sound( "GModTower/zom/powerups/laser.wav" )
ENT.ChargeSound = Sound( "GModTower/zom/powerups/lasercharge.wav" )
ENT.ShootDelay 	= .4
function ENT:IsInRadius( ent )
	return self:GetPos():Distance( ent:GetPos() ) < self.Radius
end
function ENT:Trace( ent )
	local tr = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:GetPos() + Vector( 0, 0, 2000 ),
	} )
	return !tr.HitWorld
end