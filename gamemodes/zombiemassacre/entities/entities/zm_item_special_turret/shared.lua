ENT.Type = "anim"ENT.Base = "zm_item_special_base"
ENT.Radius 		= 384
ENT.RemoveDelay = 30
ENT.Model = Model( "models/turret/miniturret.mdl" )
ENT.Sound = Sound( "Weapon_M4A1.Single" )
ENT.Sounds = {
	["Spawn"] = Sound( "ambient/tones/equip3.wav" ),
	["TargetFound"] = Sound( "ambient/tones/equip2.wav" ),
	["TargetFind"] = Sound( "ambient/tones/equip1.wav" ),
	["Shutdown"] = Sound( "ambient/energy/powerdown2.wav" ),
}
ENT.BlastSound = Sound( "weapon_AWP.Single" )
function ENT:GetShootPos()
	local attach = 1
	local AttachInfo = self:GetAttachment(attach)
	if !AttachInfo then
		return self:GetPos()
	end
	return AttachInfo.Pos
end
function ENT:GetShootAng()
	local attach = 1
	local AttachInfo = self:GetAttachment(attach)
	if !AttachInfo then
		return self:GetAngles()
	end
	return AttachInfo.Ang
end
function ENT:GetEnemyPos( enemy )
	if !IsValid( enemy ) then return end
	local Torso = enemy:LookupBone( "ValveBiped.Bip01_Spine2" ) 
	if !Torso then return enemy:GetPos() + Vector( 0, 0, 20 ) end
	local pos, ang = enemy:GetBonePosition( Torso )
	return pos
end