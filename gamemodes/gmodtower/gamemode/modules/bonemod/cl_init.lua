include("shared.lua")

BoneMod = {}
BoneMod.Bip = "ValveBiped.Bip01_"

local ScaleNormal = Vector( 1, 1, 1 )

net.Receive( "BoneMod", function( len )

	local ply = net.ReadEntity()
	if !IsValid( ply ) then return end

	ply.BoneMod = net.ReadInt( 6 ) or 0

	BoneMod:ApplyBoneMod( ply.BoneMod, ply )

end )

function BoneMod:ApplyBoneMod( mod, ply )

	--ply:ManualEquipmentDraw()

	self:ModNormal( ply ) // reset first

	// I wish Lua had switch...

	if mod == BONEMOD_CUTE then
		self:ModCute( ply )
	end

	if mod == BONEMOD_FAT then
		self:ModFat( ply )
	end

	if mod == BONEMOD_SKINNY then
		self:ModSkinny( ply )
	end

	if mod == BONEMOD_DKMODE then
		self:ModDKMode( ply )
	end

	if mod == BONEMOD_SMALLHEAD then
		self:ModSmallHead( ply )
	end

	if mod == BONEMOD_BIGHEAD then
		self:ModBigHead( ply )
	end

	if mod == BONEMOD_FLAT then
		self:ModFlat( ply )
	end

	if mod == BONEMOD_ALIEN then
		self:ModAlien( ply )
	end

	if mod == BONEMOD_ADDICT then
		self:ModAddict( ply )
	end

	if mod == BONEMOD_BOUNCER then
		self:ModBouncer( ply )
	end

	if mod == BONEMOD_BIGFOOT then
		self:ModBigfoot( ply )
	end

	if mod == BONEMOD_CARTOON then
		self:ModCartoon( ply )
	end

	if mod == BONEMOD_PINHEAD then
		self:ModPinHead( ply )
	end

	if mod == BONEMOD_LADY then
		self:ModLady( ply )
	end

	if mod == BONEMOD_HANDY then
		self:ModHandy( ply )
	end

	if mod == BONEMOD_HEADLESS then
		self:ModHeadless( ply )
	end

	if mod == BONEMOD_BIGPANTS then
		self:ModBigPants( ply )
	end

	if mod == BONEMOD_STICK then
		self:ModStickman( ply )
	end

end

function BoneMod:ScaleBone( ply, bone, scale, position )

	if !scale then scale = ScaleNormal end
	if !position then position = ScaleNormal end

	if type( scale ) != "Vector" then
		scale = Vector( scale, scale, scale )
	end

	if IsValid( ply ) then

		local boneIndex = ply:LookupBone( self.Bip .. bone )
		if boneIndex then

			ply:ManipulateBoneScale( boneIndex, scale )
			ply:ManipulateBonePosition( boneIndex, ( scale / 4 ) * position )

			/*local boneMatrix = ply:GetBoneMatrix( boneIndex )

			if boneMatrix then

				boneMatrix:Scale( scale )
				ply:SetBoneMatrix( boneIndex, boneMatrix )
			end*/

		end

	end

end

function BoneMod:GetBoneScale( ply, bone )

	if !IsValid( ply ) then return Vector( 1, 1, 1 ) end

	local boneIndex = ply:LookupBone( self.Bip .. bone )

	if boneIndex then

		local boneMatrix = ply:GetBoneMatrix( boneIndex )
		if boneMatrix then
			return boneMatrix:GetScale()
		end

	end

end

function BoneMod:ScalePlayer( ply, scale )

	ply:SetModelScale( scale, 0 )
	ply:SetRenderBounds( Vector( -16, -16, 0 ) * scale, Vector( 16,  16,  72 ) * scale )
	ply:SetStepSize( math.Clamp( 18 * scale, 1, 36 ) )

end

// Copy from this to make new mod
function BoneMod:ModNormal( ply )

	for boneId = 0, ply:GetBoneCount() do
		ply:ManipulateBoneScale( boneId, Vector( 1, 1, 1 ) )
		ply:ManipulateBonePosition( boneId, Vector( 0, 0, 0 ) )
	end

end

function BoneMod:ModCute( ply )

	self:ScaleBone( ply, "Head1", Vector( 3, 3, 3 ) )
	self:ScaleBone( ply, "L_Forearm", Vector( 1.5, 1.5, 1.5 ) )
	self:ScaleBone( ply, "R_Forearm", Vector( 1.5, 1.5, 1.5 ) )
	self:ScaleBone( ply, "L_Calf", Vector( 1, 1.5, 1.5 ) )
	self:ScaleBone( ply, "R_Calf", Vector( 1, 1.5, 1.5 ) )

end

function BoneMod:ModFat( ply )

	self:ScaleBone( ply, "Spine", 1.5 )
	self:ScaleBone( ply, "Spine2", 1.15 )
	self:ScaleBone( ply, "pelvis", 1.15 )

	self:ScaleBone( ply, "L_UpperArm", 1.5, Vector( 1.5, 0, 0 ) )
	self:ScaleBone( ply, "R_UpperArm", 1.5, Vector( 1.5, 0, 0 ) )

	self:ScaleBone( ply, "L_Thigh", 1.5 )
	self:ScaleBone( ply, "L_Foot",  1.5 )

	self:ScaleBone( ply, "R_Thigh", 1.5 )
	self:ScaleBone( ply, "R_Foot", 1.5 )

end

function BoneMod:ModSkinny( ply )

	self:ScaleBone( ply, "Spine", .85 )
	self:ScaleBone( ply, "Spine2", .85 )
	self:ScaleBone( ply, "pelvis", .85 )

	self:ScaleBone( ply, "L_UpperArm", .75 )
	self:ScaleBone( ply, "R_UpperArm", .75 )

	self:ScaleBone( ply, "L_Thigh", .75 )
	self:ScaleBone( ply, "L_Foot", .75 )

	self:ScaleBone( ply, "R_Thigh", .75 )
	self:ScaleBone( ply, "R_Foot", .75 )

	self:ScaleBone( ply, "L_Hand", .75 )
	self:ScaleBone( ply, "R_Hand", .75 )

end

function BoneMod:ModFlat( ply )

	for boneId = 0, ply:GetBoneCount() do
		ply:ManipulateBoneScale( boneId, Vector( 1, 0.025, 1 ) )
	end

end

function BoneMod:ModStickman( ply )

	for boneId = 0, ply:GetBoneCount() do
		ply:ManipulateBoneScale( boneId, Vector( 1, 0.025, 0.025 ) )
	end

end

function BoneMod:ModDKMode( ply )

	self:ScaleBone( ply, "Spine", 1.45 )
	self:ScaleBone( ply, "Spine2", 1.5 )

	self:ScaleBone( ply, "L_UpperArm", 1.65, Vector( 1.5, 0, 0 ) )
	self:ScaleBone( ply, "R_UpperArm", 1.65, Vector( 1.5, 0, 0 ) )

	self:ScaleBone( ply, "L_Thigh", .75 )
	self:ScaleBone( ply, "L_Foot", .5 )

	self:ScaleBone( ply, "R_Thigh", .75 )
	self:ScaleBone( ply, "R_Foot", .5 )

	self:ScaleBone( ply, "L_Hand", 1.5, Vector( 0, 0, -2 ) )
	self:ScaleBone( ply, "R_Hand", 1.5, Vector( 0, 0, -2 ) )

end

function BoneMod:ModAlien( ply )

	self:ScaleBone( ply, "Head1", 1.2, Vector( -10, -10, 0 ) )
	self:ScaleBone( ply, "Spine2", .75, Vector( -10, -20, 0 ) )
	self:ScaleBone( ply, "pelvis", .75 )

	self:ScaleBone( ply, "L_Thigh", .75 )
	self:ScaleBone( ply, "L_Foot", .5 )

	self:ScaleBone( ply, "R_Thigh", .75 )
	self:ScaleBone( ply, "R_Foot", .5 )

end

function BoneMod:ModBigHead( ply )

	self:ScaleBone( ply, "Head1", 2 )

end

function BoneMod:ModSmallHead( ply )

	self:ScaleBone( ply, "Head1", .7 )

end

function BoneMod:ModAddict( ply )

	self:ScaleBone( ply, "R_UpperArm", Vector( 1.05, 1.45, 1.37 ) )
	self:ScaleBone( ply, "L_UpperArm", Vector( 1.05, .75, .8 ) )

	self:ScaleBone( ply, "L_Thigh", Vector( 1.02, .75, .8 ) )
	self:ScaleBone( ply, "R_Thigh", Vector( 1.02, .75, .8 ) )

	self:ScaleBone( ply, "R_Forearm", Vector( 1.00, 1.29, 1.3 ) )
	self:ScaleBone( ply, "L_Hand", Vector( .5, 1.17, 1.08 ) )

	self:ScaleBone( ply, "Spine2", Vector( 1, .84, .84 ) )
end

function BoneMod:ModBouncer( ply )

	self:ScaleBone( ply, "L_UpperArm", Vector( 1.05, 1.45, 1.37 ) )
	self:ScaleBone( ply, "R_UpperArm", Vector( 1.05, 1.45, 1.37 ) )

	self:ScaleBone( ply, "L_Thigh", Vector( 1.02, .75, .8 ) )
	self:ScaleBone( ply, "R_Thigh", Vector( 1.02, .75, .8 ) )

	self:ScaleBone( ply, "L_Forearm", Vector( 1.00, 1.29, 1.3 ) )
	self:ScaleBone( ply, "R_Forearm", Vector( 1.00, 1.29, 1.3 ) )

	self:ScaleBone( ply, "L_Hand", Vector( .5, 1.17, 1.08 ) )
	self:ScaleBone( ply, "R_Hand", Vector( .5, 1.17, 1.08 ) )

	self:ScaleBone( ply, "Spine2", Vector( 1.1, 1.14, 1.02 ) )
	self:ScaleBone( ply, "Neck1", Vector( 1.2, 1.2, 1.2 ) )

end

function BoneMod:ModBigfoot( ply )

	self:ScaleBone( ply, "L_Foot", 1.5 )
	self:ScaleBone( ply, "R_Foot", 1.5 )

	self:ScaleBone( ply, "L_Toe", 1.5 )
	self:ScaleBone( ply, "R_Toe", 1.5 )

end

function BoneMod:ModBigPants( ply )

	self:ScaleBone( ply, "L_Foot",  1.5 )
	self:ScaleBone( ply, "R_Foot", 1.5 )

	self:ScaleBone( ply, "L_Thigh", 1.5 )
	self:ScaleBone( ply, "R_Thigh", 1.5 )

end

function BoneMod:ModCartoon( ply )

	self:ScaleBone( ply, "L_Toe", Vector( 1.5, 2.0, 1.5 ) )
	self:ScaleBone( ply, "R_Toe", Vector( 1.5, 2.0, 1.5 ) )

	self:ScaleBone( ply, "L_Foot", Vector( 1.1, 1.1, 1.1 ) )
	self:ScaleBone( ply, "R_Foot", Vector( 1.1, 1.1, 1.1 ) )

	self:ScaleBone( ply, "L_Calf", Vector( 1, 1.3, 1.3 ) )
	self:ScaleBone( ply, "R_Calf", Vector( 1, 1.3, 1.3 ) )

	self:ScaleBone( ply, "L_UpperArm", Vector( 1.1, 0.9, 0.9 ) )
	self:ScaleBone( ply, "R_UpperArm", Vector( 1.1, 0.9, 0.9 ) )

	self:ScaleBone( ply, "L_Forearm", Vector( 1.1, 1.3, 1.3 ) )
	self:ScaleBone( ply, "R_Forearm", Vector( 1.1, 1.3, 1.3 ) )

	self:ScaleBone( ply, "L_Hand", Vector( 1.2, 1.5, 1.5 ) )
	self:ScaleBone( ply, "R_Hand", Vector( 1.2, 1.5, 1.5 ) )

	self:ScaleBone( ply, "Head", Vector( 1.2, 1.2, 1.2 ) )
	self:ScaleBone( ply, "Spine1", Vector( 0.8, 0.8, 0.9 ) )

	self:ScaleBone( ply, "Spine2", Vector( 1, 1.2, 0.9 ) )
	self:ScaleBone( ply, "Spine3", Vector( 1, 0.9, 0.9 ) )

	self:ScaleBone( ply, "pelvis", Vector( 0.9, 1, 0.8 ) )

end

function BoneMod:ModPinHead( ply )

	self:ScaleBone( ply, "Head1", Vector( 1.25, .85, .85 ) )

end

function BoneMod:ModLady( ply )

	self:ScaleBone( ply, "pelvis", Vector( 1.0, 1.0, 0.8 ) )
	self:ScaleBone( ply, "Spine2", Vector( 0.9, 1.0, 1.15 ) )
	self:ScaleBone( ply, "Spine", Vector( 1.0, 0.85, 0.7 ) )

	self:ScaleBone( ply, "L_UpperArm", Vector( 1.0, 0.9, 0.9 ) )
	self:ScaleBone( ply, "L_Forearm", Vector( 1.0, 0.9, 0.9 ) )

	self:ScaleBone( ply, "R_UpperArm", Vector( 1.0, 0.9, 0.9 ) )
	self:ScaleBone( ply, "R_Forearm", Vector( 1.0, 0.9, 0.9 ) )

	self:ScaleBone( ply, "L_Thigh", Vector( 1.0, 0.8, 0.9 ) )
	self:ScaleBone( ply, "L_Calf", Vector( 1.0, 1.0, 0.85 ) )

	self:ScaleBone( ply, "R_Thigh", Vector( 1.0, 0.8, 0.9 ) )
	self:ScaleBone( ply, "R_Calf", Vector( 1.0, 1.0, 0.85 ) )

end

function BoneMod:ModHandy( ply )

	self:ScaleBone( ply, "L_ForeArm", 1.5 )
	self:ScaleBone( ply, "R_ForeArm", 1.5 )

	self:ScaleBone( ply, "L_Hand", 1.5, Vector( 0, 0, -2 ) )
	self:ScaleBone( ply, "R_Hand", 1.5, Vector( 0, 0, -2 ) )

end

function BoneMod:ModHeadless( ply )
	self:ScaleBone( ply, "Head1", 0 )
end
