include('shared.lua')
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

function ENT:Initialize()

	self:DrawShadow( false )
	self:SetNotSolid( true )

end

function ENT:Think()

	local owner = self:GetOwner()

	if !IsValid( owner ) then
		self:Remove()
	else
		if !owner:Alive() then

			self:Remove()
			owner.TakeOn = nil

		end
	end

end

function ENT:SetTakeOn( ply )

	self:SetPos( ply:GetPos() )
	self:SetOwner( ply )
	self:SetParent( ply )

	if ply:GetInfoNum("gmt_takeonmat", 1) == 1 then
		ply:SetMaterial( "gmod_tower/pvpbattle/aha_skin" )
	end

	ply:SetWalkSpeed( 550 )
	ply.TakeOn = self

end

function ENT:ToggleMaterial()
	if IsValid( self:GetOwner() ) then
		if self:GetOwner():GetMaterial() != "" then
			self:GetOwner():SetMaterial( "" )
			self:GetOwner():SendLua("RunConsoleCommand('gmt_takeonmat','0')")
		else
			self:GetOwner():SetMaterial( "gmod_tower/pvpbattle/aha_skin" )
			self:GetOwner():SendLua("RunConsoleCommand('gmt_takeonmat','1')")
		end
	end
end

function ENT:OnRemove()

	local owner = self:GetOwner()

	if IsValid( owner ) then

		owner.TakeOn = nil
		owner:SetMaterial( "" )
		owner:SetWalkSpeed( 250 )

	end

end
