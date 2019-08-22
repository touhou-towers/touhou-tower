include('shared.lua')
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.ShouldDraw = false
function ENT:Initialize()
	self:DrawShadow( false )
	
end
function ENT:Draw()
	if !self.ShouldDraw then return end
	/*local Hand = self:GetOwner():LookupBone( "ValveBiped.Bip01_R_Hand" ) 
	local pos, ang = self:GetOwner():GetBonePosition( Hand )
	//pos = pos + ( ang:Right() * -4 )
	//pos = pos + ( ang:Forward() * 5 )
	self:SetPos( pos )
	self:SetAngles( ang )*/
	local Torso = self:GetOwner():LookupBone( "ValveBiped.Bip01_Spine2" ) 
	local pos, ang = self:GetOwner():GetBonePosition( Torso )
	ang:RotateAroundAxis( ang:Up(), 180 )
	ang:RotateAroundAxis( ang:Right(), 90 + 45 )
	pos = pos + ( ang:Right() * -4 )
	pos = pos + ( ang:Forward() * -10 )
	self:SetPos(pos)
	self:SetAngles(ang)
	self:DrawModel()
end
function ENT:DrawTranslucent()
	if !self.ShouldDraw then return end
	self:Draw()
end
local function SetClientItem( um )
	local ent = um:ReadEntity()
	if !IsValid( ent ) then return end
	local mdl = um:ReadString()
	if mdl == "" then
		ent.ShouldDraw = false
		return
	end
	ent:SetModel( mdl )
	ent.ShouldDraw = true
end
usermessage.Hook( "SetItem", SetClientItem )