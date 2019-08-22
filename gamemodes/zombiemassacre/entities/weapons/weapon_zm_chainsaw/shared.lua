
-----------------------------------------------------
SWEP.Base = "weapon_zm_base"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 				= "Chainsaw"

SWEP.WorldModel				= Model( "models/weapons/w_pvp_chainsaw.mdl" )
SWEP.HoldType				= "physgun"

SWEP.Primary.Automatic		= true
SWEP.Primary.Damage			= 30
SWEP.Primary.Delay			= 0.5

SWEP.MaxDurability			= 15
SWEP.IsMelee				= true

SWEP.Primary.Damage			= 75
SWEP.Primary.Sound			= Sound( "GModTower/zom/weapons/chainsaw/slice.wav" )
SWEP.SliceSound				= Sound( "GModTower/zom/weapons/chainsaw/hardslice.wav" )
SWEP.IdleSound				= Sound( "GModTower/zom/weapons/chainsaw/idle.wav" )
SWEP.IdleAngrySound			= Sound( "GModTower/zom/weapons/chainsaw/idleangry.wav" )
SWEP.StartSound				= Sound( "GModTower/zom/weapons/chainsaw/powerup.wav" )
SWEP.EndSound				= Sound( "GModTower/zom/weapons/chainsaw/powerdown.wav" )

SWEP.Offsets				= nil
SWEP.Tier 					= DropManager.RARE

SWEP.HitDecals = {
	[MAT_FLESH] = "Impact.BloodyFlesh",
	[MAT_CONCRETE] = "Impact.Concrete",
	[MAT_GLASS] = "Impact.Glass",
	[MAT_SAND] = "Impact.Sand",
	[MAT_WOOD] = "Impact.Wood",
}

function SWEP:Holster()

	self:TurnOff( true )
	return true

end

function SWEP:Deploy()

	self.SoundIdle = CreateSound( self, self.IdleSound )
	self.SoundIdle:Play()

	return true

end

function SWEP:OnRemove()

	self:TurnOff( true )

	if SERVER && IsValid( self.Owner ) then
		self.Owner:ResetSpeeds()
	end

end

function SWEP:Think()
	
	if SERVER && self.Durability == 0 then
		self.Owner:StripWeapon( self:GetClass() )
		return
	end

	if IsValid( self.Owner ) then

		if self.Owner:KeyReleased( IN_ATTACK ) then

			self:TurnOff()
			self.ForcedOff = false
			return
		end

		self:UpdateAttack()

	end

end

function SWEP:TurnOn()

	self.IsOn = true
	self:EmitSound( self.StartSound, 100, math.random( 80, 120 ) )
	self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )

	if SERVER then
		--self.Owner:SpeedDown()
	end

	timer.Simple( .5, function()

		if IsValid( self ) && self.IsOn then
			self.IdleAngry = CreateSound( self, self.IdleAngrySound )
			self.IdleAngry:Play()
		end

	end )

end

function SWEP:TurnOff( idleoff )

	self.IsOn = false

	if SERVER && IsValid( self.Owner ) then
		self.Owner:ResetSpeeds()
	end

	// Sounds
	if self.SoundSlice && self.SoundSlice:IsPlaying() then

		self.SoundSlice:Stop()
		self:PlayPowerOff()

	end

	if self.IdleAngry && self.IdleAngry:IsPlaying() then
		self.IdleAngry:Stop()
	end

	if idleoff then
		if self.SoundIdle && self.SoundIdle:IsPlaying() then
			self.SoundIdle:Stop()
		end
	end

end

function SWEP:PlayPowerOff()

	if !self.SoundPowerOff && IsValid( self.Owner ) then
		self.SoundPowerOff = CreateSound( self.Owner, self.EndSound )
		self.SoundPowerOff:Play()
	else
		if self.SoundPowerOff then

			if self.SoundPowerOff:IsPlaying() then
				self.SoundPowerOff:Stop()
			end

			self.SoundPowerOff:Play()

		end
	end

end

function SWEP:PrimaryAttack()

	if self.ForcedOff then return true end
	if !self:CanPrimaryAttack() then return true end
	self:SetNextPrimaryFire( CurTime() + 1 )

	if !self.IsOn then
		self:TurnOn()
	end

end

local function TestTrace( pos, ang, ply )

	local trace = util.TraceLine({
		start  = pos,
		endpos = pos + ang:Forward() * 128,
		filter = ply
	})
	
	if IsValid(trace.Entity) && trace.Entity:IsNPC() then
		return trace.Entity
	end

end

local function TestTraces( ply )
	
	local pos = ply:GetShootPos()
	local ang = ply:GetAimVector():Angle()
	
	return TestTrace( pos, ang, ply ) || 
		   TestTrace( pos, ang + Angle( 15, 0, 0 ), ply ) ||
		   TestTrace( pos, ang + Angle( 0, 15, 0 ), ply ) ||
		   TestTrace( pos, ang + Angle( 0, -15, 0 ), ply )
end

function SWEP:UpdateAttack()

	if !SERVER || !self.IsOn then return end
	if self.Delay && self.Delay > CurTime() then return end

	self.Delay = CurTime() + self.Primary.Delay

	self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	local trace = util.TraceHull({start=self.Owner:GetShootPos(),
			endpos=self.Owner:GetShootPos() + self.Owner:GetAimVector() * 75,
			mins=Vector(-10, -10, -10), maxs=Vector(10, 10, 10),
			filter=self.Owner})
	
	util.Decal( self.HitDecals[trace.MatType] or "Impact.Metal", trace.HitPos + trace.HitNormal, trace.HitPos + trace.HitNormal * -20 + VectorRand() * 2 )

	if trace.Hit then

		if !IsValid( trace.Entity ) then

			local effectdata = EffectData()
				effectdata:SetOrigin( trace.HitPos )
			util.Effect( "MetalSpark", effectdata, true, true )

			self:TurnOff()
			self:PlayPowerOff()
			self.ForcedOff = true

		end

	end
	
	local target = TestTraces( self.Owner )	
	
	if target then

		if SERVER then

			target:TakeDamage( math.random( 90, 95 ), self.Owner )
			
			// Subtract durability
			if self.Durability then
				if !dura then dura = 1 end
				self.Durability = self.Durability - dura
			end

		end
	
		if IsFirstTimePredicted() then
		
			local effectdata = EffectData()
				effectdata:SetOrigin( target:GetPos() )
				effectdata:SetNormal( self.Owner:GetAngles():Forward() )
			util.Effect( "gib_bloodemitter", effectdata, true, true )

			local rnd = math.random( 1, 2 )
			local slicesnd = self.Primary.Sound
			if rnd == 1 then
				slicesnd = self.SliceSound
			end

			// Sound
			if !self.SoundSlice then
				self.SoundSlice = CreateSound( self.Owner, slicesnd )
				self.SoundSlice:Play()
			else

				if self.SoundSlice:IsPlaying() then
					self.SoundSlice:FadeOut( .5 )
				end

				self.SoundSlice = CreateSound( self.Owner, slicesnd )
				self.SoundSlice:Play()

			end

		end

	end

end