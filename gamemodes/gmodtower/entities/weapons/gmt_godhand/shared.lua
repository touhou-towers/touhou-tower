
if SERVER then
	AddCSLuaFile( "shared.lua" )
	hook.Add("PlayerDeath", "GodHandStop", function(victim, inflictor, attacker)
			local weapon = victim:GetWeapon("weapon_godhand")
			if weapon and weapon.GodHandPower then weapon:GodHand( false ) end
		end)
end

SWEP.Base = "weapon_base"

SWEP.PrintName = "God Hand"
SWEP.Slot = 0
SWEP.SlotPos = 0

SWEP.Spawnable = true
SWEP.AdminSpawnable	= true

SWEP.ViewModel = "models/weapons/v_pvp_ire.mdl"
SWEP.WorldModel = "models/weapons/w_pvp_ire.mdl"
SWEP.ViewModelFlip = false

SWEP.Primary.Force = 80
SWEP.Primary.Delay = .10

SWEP.Secondary.Force = 10000
SWEP.Secondary.Delay = 10

SWEP.FistHit = "GModTower/pvpbattle/Rage/RageHit.wav"

SWEP.FistHitFlesh = {Sound("GModTower/pvpbattle/Rage/RageFlesh1.wav"),
					Sound("GModTower/pvpbattle/Rage/RageFlesh2.wav"),
					Sound("GModTower/pvpbattle/Rage/RageFlesh3.wav"),
					Sound("GModTower/pvpbattle/Rage/RageFlesh4.wav")}

SWEP.FistMiss = {Sound("GModTower/pvpbattle/Rage/RageMiss1.wav"),
				Sound("GModTower/pvpbattle/Rage/RageMiss2.wav")}

SWEP.God = {["Hand"] = Sound("GModTower/misc/godhand_ko.wav"),
			["HandInit"] = Sound("GModTower/misc/godhand_initialize.wav"),
			["HandStop"] = Sound("GModTower/misc/godhand_end.wav"),
			["HandMusic"] = "GModTower/misc/godhand_music.mp3"}

SWEP.GodHandToggle = 0.0

SWEP.Beat = 0

SWEP.HoldType = "fist"

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )

	self.BGM = CreateSound( self.Weapon, self.God.HandMusic )
end

function SWEP:Precache()
end

function SWEP:PlayGODHAND()
	if !self.BGM then return end

	self.BGM:PlayEx(.5, 100)
end

function SWEP:StopGODHAND()
	if !self.BGM then return end

	self.BGM:Stop()
end

function SWEP:PrimaryAttack()
	--if !self:CanPrimaryAttack() then return end
	if self.Owner:GetPos():Distance(self.Owner:GetEyeTrace().Entity:GetPos()) > 50 then return end

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self:Punch( self.Primary.Force )
end

function SWEP:Punch( force, isGodAttack )
	local trace = self.Owner:GetEyeTrace()
		/*util.TraceHull({["start"] = self.Owner:GetShootPos(),
		["endpos"] = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 50,
		["mins"] = Vector(-8, -8, -8), ["maxs"] = Vector(8, 8, 8),
		["filter"] = self.Owner})*/
	if !IsValid(trace.Entity) then return end

	local sound = self.FistMiss
	self.Victim = trace.Entity

	if trace.Hit then
		if IsValid(trace.Entity) && trace.Entity:IsPlayer() then
			sound = self.FistHitFlesh
		else
			sound = self.FistHit
		end
	end

	if sound && IsFirstTimePredicted() then
		if type(sound) == "table" then
			self.Weapon:EmitSound( sound[math.random(1, #sound)] )
		else
			self.Weapon:EmitSound( sound )
		end
	end

	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	if SERVER && IsValid(trace.Entity) then
		if trace.Entity:IsPlayer() then
			if isGodAttack then
				self:GodHandStart( trace.Entity )
			else
				trace.Entity:SetVelocity( self.Owner:GetAimVector() * force, 0 )
			end
		else
			local phys = trace.Entity:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity( self.Owner:GetVelocity() + (self.Owner:GetAimVector() * force * 3) )
			end
			/*local sfx2 = EffectData()
			sfx2:SetOrigin( self.Owner:GetPos() )
			util.Effect( "godhand_rocks", sfx2 )*/
		end
	end
end

function SWEP:SecondaryAttack()
	if !self:CanSecondaryAttack()
	or !self.Owner:GetEyeTrace().Entity:IsPlayer()
	or self.Owner:GetPos():Distance(self.Owner:GetEyeTrace().Entity:GetPos()) > 50 then return end

	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )

	self:Punch( self.Primary.Force, true )

	local sfx = EffectData()
	sfx:SetOrigin( self.Owner:GetPos() + Vector(0, 0, 30) )
	util.Effect( "godhand_ko", sfx )

	self:GodHandBeat(self.Owner:GetEyeTrace().Entity)

end

function SWEP:GodHandStart(ply)
	if !IsValid(ply) and !IsValid(self.Owner) then return end

	self.Owner.GHVictim = ply
	ply:EmitSound( self.God.Hand )
	ply:Freeze( true )

	local weaponowner = self.Owner
	local uid = weaponowner:UserID()

	timer.Simple(1.3, function()
			if IsValid(weaponowner) then
				timer.Create("GodHandBeat" .. uid, .1, 32, function(victim)
					if !IsValid(self) || !IsValid(weaponowner) || !self.Owner:Alive() || !IsValid(victim) then
						timer.Destroy("GodHandBeat" .. uid)
						return
					end

					self:GodHandBeat(victim)
				end, ply )
			end
		end)
end

function SWEP:GodHandBeat( victim )
	self.Beat = self.Beat + 1
	self:Punch( self.Primary.Force )

	self:GodHandJump( victim )
end

function SWEP:GodHandJump( victim )
	self.Owner:SetVelocity( Vector(0, 0, 250) )

	timer.Simple(1.5, function()
		if IsValid(self) && IsValid(self.Owner) && IsValid(victim) then
			self:GodHandEnd(victim)
		end
	end)

	local sfx = EffectData()
	sfx:SetOrigin( self.Owner:GetPos() )
	util.Effect( "godhand_jump", sfx )
end

function SWEP:GodHandEnd(ply)
	if IsValid(ply) then
		ply:Freeze( false )
	end

	self.Beat = 0

	local weaponowner = self.Owner
	timer.Simple(0.3, function()
		if IsValid(self) && IsValid(self.Owner) && IsValid(ply) then
			self:GodHandLastPunch(ply)
		end
	end)

	ply:ViewPunch( Angle( -30, 0, 0 ) )

	local sfx = EffectData()
	sfx:SetOrigin( ply:GetPos() )
	util.Effect( "gmt_adminsmoke_effect", sfx )

	sfx = EffectData()
	sfx:SetOrigin( self.Owner:GetPos() )
	util.Effect( "godhand_rocks", sfx )

	util.ScreenShake( ply:GetPos(), 32, 210, 1, 1024 )

	if CLIENT then return end

	local shake = ents.Create( "env_physexplosion" )
	shake:SetKeyValue( "radius", 512 )
	shake:SetKeyValue( "magnitude", 64 )
	shake:SetKeyValue( "spawnflags", "3" )
	shake:SetPos( ply:GetPos() )

	shake:Fire("Explode" , "", 0)
	shake:Fire("kill","", 2)
end

function SWEP:GodHandLastPunch(ply)
	ply:SetVelocity( self.Owner:GetAimVector() * self.Secondary.Force )

	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )

	ply:SetHealth( 1 )
end

function SWEP:Reload()
	if self.GodHandToggle > CurTime() then return end
	self.GodHandToggle = CurTime() + 1

	self:GodHand( !self.GodHandPower )

	if ValidPlayer(self.Victim) then
		self.Victim:Freeze(false)
		self.Victim = nil
	end
end

function SWEP:GodHand( isOn )
	if !IsValid(self.Owner) then return end
	self.GodHandPower = isOn

	if isOn then
		self:PlayGODHAND()

		local sfx = EffectData()
		sfx:SetOrigin( self.Owner:GetPos() )
		util.Effect( "godhand_initalize", sfx )

		timer.Create( "GodHand" .. self.Owner:UserID(), SoundDuration(self.God.HandMusic), 1, self.GodHand, self, false )

		if SERVER then
			self.Owner:EmitSound( self.God.HandInit )
			--self.Owner:SetAnimation( PLAYER_SIGNAL_HALT )
		end
	else
		self:StopGODHAND()

		self:GodHandClear()

		if SERVER then self.Owner:EmitSound( self.God.HandStop ) end
	end
end

function SWEP:CanPrimaryAttack()
	return self.GodHandPower
end

function SWEP:CanSecondaryAttack()
	return self.GodHandPower
end

function SWEP:GodHandClear()
	local timers = {"GodHand",
					"GodHandBeat",
					"GodHandLastPunch"}

	for _, v in ipairs(timers) do --Clears all timers currently running, this prevents any ongoing timers from causing any future errors.
		if timer.Exists( v .. self.Owner:UserID() ) then timer.Destroy( v .. self.Owner:UserID() ) end
	end

	if IsValid(self.Owner.GHVictim) then
		self.Owner.GHVictim:Freeze(false)
		self.Owner.GHVictim = nil
	end
end

hook.Add("PlayerDeath", "UnFreeze", function(ply)
	if IsValid(ply.GHVictim) then
		ply.GHVictim:Freeze( false )
		ply.GHVictim = nil
		return
	end
end)
hook.Add("PlayerSilentDeath", "UnFreeze", function(ply)
	if IsValid(ply.GHVictim) then
		ply.GHVictim:Freeze( false )
		ply.GHVictim = nil
		return
	end
end)
hook.Add("PlayerDisconnected", "UnFreeze", function(ply)
	if IsValid(ply.GHVictim) then
		ply.GHVictim:Freeze( false )
		ply.GHVictim = nil
		return
	end
end)
