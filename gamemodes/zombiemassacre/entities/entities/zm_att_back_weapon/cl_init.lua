include('shared.lua')
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.ShouldDraw = false
function ENT:Initialize()
	self:DrawShadow( false )
end
function ENT:Draw()

	if ( !self.ShouldDraw ) then return end
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
	if ( !self.ShouldDraw ) then return end
	self:Draw()
end
local function SetClientWeapon( um )
	local ent = um:ReadEntity()
	if !IsValid( ent) then return end
	local wep = um:ReadString()
	if ( wep == "" ) then
		ent.ShouldDraw = false
		return
	end
	ent:SetModel( wep )
	ent.ShouldDraw = true
end
usermessage.Hook( "SetBack", SetClientWeapon )
