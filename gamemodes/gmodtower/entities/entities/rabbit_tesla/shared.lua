
ENT.Type = "anim"
ENT.Base = "gmt_cosmeticbase"


function ENT:GetPosHead( ply )
	
	local BoneIndex = ply:LookupBone("ValveBiped.Bip01_Head1")
	
	if BoneIndex == -1 then
		return
	end
	
	local Scale = ply:GetModelScale()
	
   return ply:GetBonePosition( BoneIndex )
	
end