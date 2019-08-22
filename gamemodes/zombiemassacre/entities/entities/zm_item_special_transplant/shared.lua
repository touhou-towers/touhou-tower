ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Radius 			= 256
ENT.RemoveDelay 	= 20

ENT.Model = ""

//ENT.Sound = Sound( "GModTower/zom/powerups/shock.wav" )
//ENT.LoopSound = Sound( "GModTower/zom/powerups/electrocute.wav" )
function ENT:GetCenterPos()
	local owner = self:GetOwner()
	if !owner then return self:GetPos() end
	return util.GetCenterPos( owner )
end
function ENT:GetEnemyPos( enemy )
	if !IsValid( enemy ) then return end
	local Torso = enemy:LookupBone( "ValveBiped.Bip01_Spine2" ) 
	if !Torso then return enemy:GetPos() + Vector( 0, 0, 20 ) end
	local pos, ang = enemy:GetBonePosition( Torso )
	return pos
end
function ENT:IsInRadius( ent, radius )
	local center = self:GetPos()
	if IsValid( self:GetOwner() ) then
		center = self:GetOwner():GetPos()
	end
	return center:Distance( ent:GetPos() ) < radius
end
function ENT:ShouldHealPlayer( ply )
	return self:IsInRadius( ply, self.Radius * 2 ) && !ply:IsHealthFull() && ply:Alive()
end