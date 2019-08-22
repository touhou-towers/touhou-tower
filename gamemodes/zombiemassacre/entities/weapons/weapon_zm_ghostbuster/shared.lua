SWEP.Base = "weapon_zm_base"
if SERVER then
	AddCSLuaFile( "shared.lua" )
end
SWEP.PrintName 				= "Proton Cannon"
SWEP.WorldModel				= Model( "models/Weapons/w_physics.mdl" )
SWEP.HoldType				= "physgun"

SWEP.Primary.ClipSize		= 200
SWEP.Primary.Delay			= 0
SWEP.Primary.Cone			= 0.03
SWEP.Primary.Automatic		= true

SWEP.Primary.Damage			= 75
SWEP.Primary.Sound			= Sound( "GModTower/zom/weapons/ghostbuster/ghost_beam.wav" )
SWEP.ProtonEndSound			= Sound( "GModTower/zom/weapons/ghostbuster/ghost_stop.wav" )

SWEP.Offsets				= nil

function SWEP:Holster()
	self:TurnOff()
	return true
end
function SWEP:OnRemove()
	self:TurnOff()
end
function SWEP:Think()
	if SERVER && self:Clip1() == 0 then
		self.Owner:StripWeapon( self:GetClass() )
		return
	end
	if IsValid( self.Owner ) then
		if self.Owner:KeyReleased( IN_ATTACK ) then
			self:TurnOff()
			return
		end
		self:UpdateSucker()
	end
end
function SWEP:TurnOn()
	self.IsOn = true
	// Sounds
	if !self.ProtonSound then
		self.ProtonSound = CreateSound( self.Owner, self.Primary.Sound )
		self.ProtonSound:Play()
	else
		if !self.ProtonSound:IsPlaying() then
			self.ProtonSound:Play()
		end
	end
	if CLIENT then return end
	// Create the beam
	if !IsValid( self.Owner.ProtonStream ) then
		local ent = ents.Create("zm_protonstream")
		ent:SetParent( self )
		ent:SetOwner( self )
		ent:Spawn()
		self.Owner.ProtonStream = ent
	end
end
function SWEP:TurnOff()
	self.IsOn = false
	// Sounds
	if self.ProtonSound && self.ProtonSound:IsPlaying() then
		self.ProtonSound:Stop()
		if !self.ProtonSoundEnd && IsValid( self.Owner ) then
			self.ProtonSoundEnd = CreateSound( self.Owner, self.ProtonEndSound )
			self.ProtonSoundEnd:Play()
		else
			if self.ProtonSoundEnd then
				if self.ProtonSoundEnd:IsPlaying() then
					self.ProtonSoundEnd:Stop()
				end
				self.ProtonSoundEnd:Play()
			end
		end
	end
	if CLIENT then return end
	self.Owner:SetNWEntity( "Ghost", nil )
	// Remove the beam
	if IsValid( self.Owner.ProtonStream ) then
		self.Owner.ProtonStream:Remove()
	end
end
function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return true end
	self:SetNextPrimaryFire( CurTime() / 150 )
	if !self.IsOn then
		self:TurnOn()
	end
	if CLIENT then return end
	// Don't drain too much ammo.
	local amt = math.random( 1, 6 )
	if amt == 1 then
		self:TakePrimaryAmmo( 1 )
	end
	self:UpdateSucker()
end
function SWEP:UpdateSucker()
	if !SERVER || !self.IsOn then return end
	// Find something to attach to
	if !IsValid( self.Owner:GetNWEntity( "Ghost" ) ) then
		local tr = util.TraceLine( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() + Vector( 0, 0, -0.05 ) ) * 5000,
			filter = self.Owner
		} )
		if IsValid( tr.Entity ) then
		
			// Great, let's attach on.
			if tr.Entity:IsNPC() && tr.Entity:Health() > 0 then
				self.Owner:SetNWEntity( "Ghost", tr.Entity )
			else // Set anything else on fire
				self:IgniteThink( tr.Entity )
			end
		end
		return
	end

	// Check if the ghost died
	if self.Owner:GetNWEntity( "Ghost" ):Health() <= 0 then
		self:GhostDie()
		return
	end
	//Detach if we're aiming a bit far from them.
	local tr = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() + Vector( 0, 0, -0.05 ) ) * 5000,
		filter = self.Owner
	})
	local dist = tr.HitPos:Distance( self.Owner:GetNWEntity( "Ghost" ):GetPos() )
	if dist > 500 then
		self.Owner:SetNWEntity( "Ghost", nil )
		return
	end
	//Detach if we've hit a wall
	local tr2 = util.TraceLine ({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetNWEntity( "Ghost" ):GetPos(),
		filter = self.Owner
	} )
	if tr2.HitWorld then
		self.Owner:SetNWEntity( "Ghost", nil )
		return
	end
	//Suck away their health.
	self.Owner:GetNWEntity( "Ghost" ):TakeDamage( math.random( 2, 8 ), self.Owner )
end
function SWEP:GhostDie()
	/*local effect = EffectData()
		effect:SetOrigin( self.Owner:GetNWEntity( "Ghost" ):GetPos() )
	util.Effect( "ghost", effect )*/
	self.Owner:GetNWEntity( "Ghost" ):Death( self.Owner )
	self.Owner:SetNWEntity( "Ghost", nil )
end
function SWEP:IgniteThink( ent )

	if ent:IsPlayer() then return end
	if !self.IgniteEnt || ent != self.IgniteEnt then
		self.IgniteEnt = ent
		self.IgniteDelay = CurTime() + 2
	end
	if self.IgniteDelay && self.IgniteDelay < CurTime() then
		ent:Ignite( 3 )
		self.IgniteEnt = nil
	end
end