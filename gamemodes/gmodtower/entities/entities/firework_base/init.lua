
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.Duration = 2  //how long you want it to last before it explodes/ends

ENT.RocketMultiplier = 1  //how much should we multiply the push

ENT.Spins = false  //should it spin around a lot?
ENT.SpinMultiplier = 10  //how much should we multiply the spin
ENT.SpinDirection = 1 //1 y, 2 p, 3 r

ENT.Shockwave = false  //should it make a shockwave on explode/end

ENT.State = 0 // 0 not used, 1 warm up, 2 ignition

function ENT:Initialize()

	self:SetModel( self.Model )

	self:UpdateSkin()

	self:SetSolid( SOLID_VPHYSICS )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )

	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion( true )
	else
		self:PhysicsInitSphere(8)
		phys = self:GetPhysicsObject()
	end

	if self.TrailColor then
		util.SpriteTrail( self, 0, self.TrailColor, false, 15, 1, 1, 1/(15+1)*0.5, "trails/plasma.vmt" )
	end

	self.Color = self:GetRandomColor()
	self.SpinDelay = CurTime()

	timer.Simple( 0.1, function()

		if !IsValid( self.Entity ) then return end

		umsg.Start( "FireworkColor", RecipientFilter():AddAllPlayers() )
			umsg.Entity( self.Entity )
			umsg.Short( self.Color.r )
			umsg.Short( self.Color.g )
			umsg.Short( self.Color.b )
		umsg.End()

	end )

	if self.TrailRandomColor then
		util.SpriteTrail( self, 0, self.Color, false, 40, 10, 1.5, 2, "trails/laser.vmt" )
	end

	self:SetBodygroup( 0, 0 )

end

function ENT:LoadRoom( owner )

	if owner == nil then return end // was called outside a suite

	self.PlayerOwner = owner
end

function ENT:Think()

	if self.State == 1 then

		local eff = EffectData()
		eff:SetOrigin( self:GetPos() )
		util.Effect( "MetalSpark", eff )

		local objs = ents.FindInSphere( self:GetPos(), 32 )
		for _, v in ipairs( objs ) do

			if IsValid( v ) && string.StartWith(v:GetClass(),"firework_") && v != self then

				timer.Simple( math.Rand( 1, 2 ), function()
					if !IsValid(v) then return end
					v:StartIgnite()
				end)

			end

		end

	elseif self.State == 2 then

		if self.ThinkEffect then

			local eff = EffectData()
			eff:SetOrigin( self:GetPos() )
			eff:SetEntity( self )
			util.Effect( self.ThinkEffect, eff )

		end

		if CurTime() > self.DurationTime then

			self:Remove()

		end

	end

end

function ENT:Use( ply )

	if !IsValid( ply ) then return end

	if self.PlayerOwner != ply && !ply:IsAdmin() then return end

	self.DisallowGrab = true

	self:StartIgnite()

end

function ENT:StartIgnite()

	if !IsValid( self ) || self.Used then return end

	self.Used = true
	self.State = 1

	timer.Simple(2,function()
		self:DoFirework()
	end)

end

function ENT:DoFirework()

	if !IsValid( self ) then return end

	self:SetBodygroup( 0, 1 )

	self:UpdateSkin()

	self.State = 2

	if self.Duration then

		self.DurationTime = CurTime() + self.Duration

	end

	if self.IsRocket then

		self.RandomDir = math.random( 1, 3 )
		self.RandomDirForce = math.random( -5, 5 )
		if self.Spins then self.SpinDelay = CurTime() + 0.1 end

	end

 	if self.SoundLiftOff then

		self:EmitSound( self.SoundLiftOff, 400, math.random( 85, 125 ) )

	end

	if !( self:GetClass() == "firework_fountain" || self:GetClass() == "firework_firefly" ) then

		local phys = self:GetPhysicsObject()
		if IsValid( phys ) then
			phys:Wake()
			phys:EnableMotion( true )
		end

	end

	umsg.Start( "FireworkUsed", RecipientFilter():AddAllPlayers() )
		umsg.Entity( self.Entity )
	umsg.End()

end

function ENT:PhysicsUpdate( physobj )

	if self.State != 2 then return end

	if self.IsRocket then

		if self.RandomDir == 1 then
			physobj:AddVelocity( Vector( 0, self.RandomDirForce, 0 ) )
		elseif self.RandomDir == 2 then
			physobj:AddVelocity( Vector( self.RandomDirForce, 0, 0 ) )
		else
			physobj:AddVelocity( Vector( self.RandomDirForce, self.RandomDirForce, 0 ) )
		end

		if !self.Spins then
			physobj:AddVelocity( self:GetUp() * 500 * self.RocketMultiplier )
		else
			physobj:AddVelocity( Vector( 0, 0, 500 * self.RocketMultiplier ) )
		end

	end

	if self.Spins && self.SpinDelay < CurTime() then

		if self.SpinDirection == 1 then
			physobj:AddAngleVelocity( Vector( 1200 * self.SpinMultiplier, 0, 0 ) )
		elseif self.SpinDirection == 2 then
			physobj:AddAngleVelocity( Vector( 0, 1200 * self.SpinMultiplier, 0 ) )
		else
			physobj:AddAngleVelocity( Vector( 0, 0, 1200 * self.SpinMultiplier ) )
		end

	end

end

function ENT:OnRemove()

	if self.State != 2 then return end

 	if self.SoundExplosion then

		//WorldSound( self.SoundExplosion, self:GetPos(), 160, math.random( 85, 125 ) )
		self:EmitSound( self.SoundExplosion, 100, math.random( 85, 125 ) )

	end

	local eff = EffectData()
		eff:SetOrigin( self:GetPos() )
		eff:SetEntity( self )
		eff:SetStart( Vector( self.Color.r, self.Color.g, self.Color.b ) ) //woo hacks
	util.Effect( "firework_pop", eff )

	if self.EndEffect then

		local eff = EffectData()
			eff:SetOrigin( self:GetPos() )
			eff:SetEntity( self )
			eff:SetStart( Vector( self.Color.r, self.Color.g, self.Color.b ) ) //woo hacks
		util.Effect( self.EndEffect, eff )

		util.ScreenShake( self:GetPos(), 2, 2.5, 1, 1024 )

	end

	if self.Shockwave then

		local eff = EffectData()
		eff:SetOrigin( self:GetPos() )
		eff:SetEntity( self )
		util.Effect( "firework_shockwave", eff )

	end

end

function ENT:GetRandomColor()

	local rand = math.random( 0, 6 )
	local color = Color( math.random( 125, 255 ), math.random( 125, 255 ), math.random( 125, 255 ) )
	if rand == 1 then
		color = Color( math.random( 125, 255 ), math.random( 30, 80 ), math.random( 30, 80 ) )
	elseif rand == 2 then
		color = Color( math.random( 30, 80 ), math.random( 125, 255 ), math.random( 30, 80 ) )
	elseif rand == 3 then
		color = Color( math.random( 30, 80 ), math.random( 30, 80 ), math.random( 125, 255 ) )
	elseif rand == 4 then
		color = Color( math.random( 30, 80 ), math.random( 125, 255 ), math.random( 125, 255 ) )
	elseif rand == 5 then
		color = Color( math.random( 125, 255 ), math.random( 30, 80 ), math.random( 125, 255 ) )
	elseif rand == 6 then
		color = Color( math.random( 125, 255 ), math.random( 125, 255 ), math.random( 30, 80 ) )
	end

	return color

end
