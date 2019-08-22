AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.Model = "models/gmt_money/twentyfive.mdl"
ENT.Sound = "GModTower/zom/health_pickup.wav"

function ENT:PickUp( ply )
	local points = math.random(1,30)
	
	self.BaseClass:PickUp( ply )

	ply:AddPoints( points )
	
	local effect = EffectData()
		effect:SetOrigin( self:LocalToWorld( self:OBBCenter() ) )
	util.Effect( "pickup_points", effect, true, true )
	
	// this is always picked up
	return true
end