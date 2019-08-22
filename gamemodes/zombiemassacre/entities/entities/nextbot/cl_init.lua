include( "shared.lua" )
function ENT:Draw()
	self:DrawModel()
end
local HandBones = {
	"ValveBiped.Bip01_L_Finger4", "ValveBiped.Bip01_L_Finger41", "ValveBiped.Bip01_L_Finger42",
	"ValveBiped.Bip01_L_Finger3", "ValveBiped.Bip01_L_Finger31", "ValveBiped.Bip01_L_Finger32",
	"ValveBiped.Bip01_L_Finger2", "ValveBiped.Bip01_L_Finger21", "ValveBiped.Bip01_L_Finger22",
	"ValveBiped.Bip01_L_Finger1", "ValveBiped.Bip01_L_Finger11", "ValveBiped.Bip01_L_Finger12",
	"ValveBiped.Bip01_L_Finger0", "ValveBiped.Bip01_L_Finger01", "ValveBiped.Bip01_L_Finger02",
	"ValveBiped.Bip01_R_Finger4", "ValveBiped.Bip01_R_Finger41", "ValveBiped.Bip01_R_Finger42",
	"ValveBiped.Bip01_R_Finger3", "ValveBiped.Bip01_R_Finger31", "ValveBiped.Bip01_R_Finger32",
	"ValveBiped.Bip01_R_Finger2", "ValveBiped.Bip01_R_Finger21", "ValveBiped.Bip01_R_Finger22",
	"ValveBiped.Bip01_R_Finger1", "ValveBiped.Bip01_R_Finger11", "ValveBiped.Bip01_R_Finger12",
	"ValveBiped.Bip01_R_Finger0", "ValveBiped.Bip01_R_Finger01", "ValveBiped.Bip01_R_Finger02",
	"ValveBiped.Bip01_R_Hand", "ValveBiped.Bip01_L_Hand",
	"ValveBiped.Bip01_R_Forearm", "ValveBiped.Bip01_L_Forearm",
}
usermessage.Hook( "RemoveBone", function( um )
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
	local bonename = ent:GetBoneName( boneid )
	if bonename == "ValveBiped.Bip01_L_UpperArm" || bonename == "ValveBiped.Bip01_R_UpperArm" then
		for _, bonename in pairs( HandBones ) do
			local boneid = ent:LookupBone( bonename )
			table.insert( ent.RemovedBones, boneid )
		end
	end
	ApplyBones( ent )
end )