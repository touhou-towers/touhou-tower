ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Radius 		= 256
ENT.RemoveDelay = 10
ENT.Model = ""
ENT.Sound = Sound( "GModTower/zom/powerups/shock.wav" )
ENT.LoopSound = Sound( "GModTower/zom/powerups/electrocute.wav" )
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