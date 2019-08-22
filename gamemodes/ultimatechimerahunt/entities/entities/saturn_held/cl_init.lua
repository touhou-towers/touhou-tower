include('shared.lua')

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()

	self:SetModel( self.Model )
	self:DrawShadow( false )

end

function ENT:Draw()

	if !IsValid( self:GetOwner() ) then return end

	if LocalPlayer() == self:GetOwner() && !LocalPlayer().IsTaunting then return end

	local Hand = self:GetOwner():LookupBone( "ValveBiped.Bip01_R_Hand" ) 
	local pos, ang = self:GetOwner():GetBonePosition( Hand )

	//pos = pos + ( ang:Right() * -4 )
	pos = pos + ( ang:Forward() * 8 )

	self:SetPos( pos )
	self:SetAngles( ang )

	self:DrawModel()
	
end

function ENT:DrawTranslucent()

	if !IsValid( self:GetOwner() ) then return end
	
	self:Draw()
	
end