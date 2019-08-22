
-----------------------------------------------------
ENT.Base = "base_ai"

ENT.Type = "ai"



ENT.AutomaticFrameAdvance = true



function ENT:SetAutomaticFrameAdvance( bUsingAnim )

	self.AutomaticFrameAdvance = bUsingAnim

end



function BoneScale( ent, boneid, size )



	ent:ManipulateBoneScale( boneid, Vector( size, size, size ) )



	/*local bonematrix = ent:GetBoneMatrix( boneid )



	bonematrix:Scale( Vector( size, size, size ) )



	ent:SetBoneMatrix( boneid, bonematrix )*/



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



		// Scale

		BoneScale( ent, boneid, 0 )



		MsgN( "REMOVED BONE " .. boneid )



		// Effect

		BleedBone( ent, boneid )



	end



end
