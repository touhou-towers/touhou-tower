
-----------------------------------------------------
include( "shared.lua" )



ENT.RemovedBones = {}

function ENT:Draw()

	self:DrawModel()

end



usermessage.Hook( "ZMSpawnRagdoll", function( um )



	local ent = um:ReadEntity()

	if !IsValid( ent ) then return end



	local rag = ent:BecomeRagdollOnClient()



	rag.BleedTime = CurTime() + 1

	rag.RemovedBones = ent.RemovedBones



	ApplyBones( rag )



end )



usermessage.Hook( "ZMRemoveBone", function( um )



	local ent = um:ReadEntity()

	if !IsValid( ent ) then return end



	local boneid = um:ReadChar()



	if !ent.RemovedBones then ent.RemovedBones = {} end

	

	local bleed = um:ReadBool()

	if bleed then

		ent.BleedTime = CurTime() + .25

	end



	if !table.HasValue( ent.RemovedBones, boneid ) then

		table.insert( ent.RemovedBones, boneid )

	end



	ApplyBones( ent )



end )



/*hook.Add( "OnEntityCreated", "AddBoneGib", function( ent ) 



	if IsValid( ent ) && !ent:IsPlayer() then



		ent.BuildBonePositions = function( self, NumBones, NumPhysBones )

 

			ApplyBones( self )

 

		end



	end



end )*/