include('shared.lua')
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

function ENT:Initialize()

	self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")

	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetUseType( SIMPLE_USE )

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end

end

function ENT:SetText( text )
	self:SetNetworkedString("Name", text )
end

function ENT:Think()

	local Pos = self:GetPos()

	for _, ply in ipairs( player.GetAll() ) do
		if Pos:Distance( ply:GetPos() ) < self.Distance then
			self:UseTouch( ply )
		end
	end

	self:NextThink( CurTime() + 0.2 )
end

function ENT:SetUse( func )
	self.UseFunc = func
end

function ENT:UseTouch( ply )

	if IsValid( ply.BallRaceBall ) then
		return
	end

	if self.UseFunc then
		self.UseFunc( ply )
	end

end
