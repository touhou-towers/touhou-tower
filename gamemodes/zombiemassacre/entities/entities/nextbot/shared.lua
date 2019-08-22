ENT.Base = "base_nextbot"
ENT.Models = { Model( "models/Zed/malezed_04.mdl" ),
			Model( "models/Zed/malezed_06.mdl" ),
			Model( "models/Zed/malezed_08.mdl" ),
}
hook.Add( "ShouldCollide", "NextBotShouldCollide", function( ent1, ent2 )
	if ent1.Base == "base_nextbot" && ent2.Base == "base_nextbot" then
		return false
	end
end )
function BoneScale( ent, boneid, size )
	ent:ManipulateBoneScale( boneid, Vector( size, size, size ) )
end
function BleedBone( ent, boneid )

	if !ent.BleedTime then
		ent.BleedTime = CurTime() + .5
	end
	if ent.BleedTime < CurTime() then return end
	local amt = ( ent.BleedTime - CurTime() ) / 4
	local bonepos, boneang = ent:GetBonePosition( boneid )
	if !bonepos then return end
	local randVec = Vector( math.random( -4, 4 ), math.random( -4, 4 ), math.random( -4, 4 ) )
	local effectdata = EffectData()
		effectdata:SetOrigin( bonepos + randVec )
		effectdata:SetNormal( Vector( boneang ) )
		effectdata:SetScale( 1.3 * ( amt + .5 ) )
	util.Effect( "bloodspit", effectdata, true, true )
end
function ApplyBones( ent )
	if !IsValid( ent ) || !ent.RemovedBones then return end
	for _, boneid in pairs( ent.RemovedBones ) do
		BoneScale( ent, boneid, 0 )
		BleedBone( ent, boneid )
		MsgN( "REMOVED BONE " .. boneid )
	end
end
function ENT:IsInRadius( ent, radius )
	if !IsValid( self ) || !IsValid( ent ) then return false end
	return self:GetPos():Distance( ent:GetPos() ) < radius
end