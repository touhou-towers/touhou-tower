AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.Model = ""
ENT.ActiveTime = 0

ENT.Sound1 = nil
ENT.Sound2 = nil

function ENT:Initialize()
	self:SetModel( self.Model )

	self:SetPos(self:GetPos() + Vector(0,0,15))

	self.Entity:SetSolid(SOLID_BBOX)

	self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
	self.Entity:SetCollisionBounds( Vector( -10, -10, -10 ), Vector( 10, 10, 10 )  )
	self.Entity:SetTrigger( true )
end

function ENT:Think()
	if IsValid(self.PoweredUpPly) then
		local ply = self.PoweredUpPly

		if CurTime() > ply.PowerUp then
			self:PowerUpOffBase( ply )
		end
	end

	if !self.RespawnTime then return end
	if CurTime() > self.RespawnTime then
		self.Disabled = false
		self:SetNoDraw( false )
		self:DrawShadow( true )
	end
end

function ENT:OnRemove()
	if IsValid(self.PoweredUpPly) then
		self:PowerUpOffBase( self.PoweredUpPly )
	end
end

function ENT:Touch( ply )
	if !ply:IsPlayer() || self.Disabled || CurTime() < ply.PowerUp then return end

	self.PoweredUpPly = ply

	ply.PowerUp = CurTime() + self.ActiveTime + 1
	ply.PowerUpSound = CreateSound( ply, self.Sound1 )
	ply.PowerUpSound:PlayEx( 10, 100)

	if self:GetClass() != "pvp_powerup_supply" then
		net.Start( "MusicEvent" )
		net.WriteInt( 3 , 4 )
		net.WriteBool( true )
		net.WriteInt( 1, 8 )
		net.Send( ply )
	end

	local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
	util.Effect( "pvp_powerup_explosion", effectdata, true, true )

	self:PowerUpOn( ply )
	self.Disabled = true
	self:SetNoDraw( true )
	self:DrawShadow( false )
	self.RespawnTime = CurTime() + 60

end

function ENT:PowerUpOffBase( ply )

	if ply.PowerUp && ply.PowerUp > 0 then

		ply.PowerUp = 0
		ply.PowerUpSound:Stop()
		ply.PowerUpSound = nil
		self:PowerUpOff( ply )
		self.PoweredUpPly = nil

		if self.Sound2 then
			ply:EmitSound( self.Sound2, 500 )
		end

		if self:GetClass() != "pvp_powerup_supply" then
			music.Play( 1, 1, ply )
		end

	end

end

function ENT:PrecacheSounds()
end

function ENT:PowerUpOn( ply )
end

function ENT:PowerUpOff( ply )
end
