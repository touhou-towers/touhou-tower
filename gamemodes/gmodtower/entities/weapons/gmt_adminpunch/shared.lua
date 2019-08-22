
if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.Base				= "weapon_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.PrintName 			= "Admin FistSmoke"
SWEP.Slot			= 0
SWEP.SlotPos			= 0

SWEP.ViewModel			= "models/weapons/v_pvp_ire.mdl"
SWEP.WorldModel			= "models/weapons/w_pvp_ire.mdl"
SWEP.ViewModelFlip		= false

SWEP.Primary.Force		= 5000
SWEP.Primary.Delay		= 0.3

SWEP.Secondary.Delay	= 1.5
SWEP.TelePos  			= nil
SWEP.TeleUse			= 0.0

SWEP.FistHit			= 	"GModTower/pvpbattle/Rage/RageHit.wav"
SWEP.FistHitFlesh		= {	"GModTower/pvpbattle/Rage/RageFlesh1.wav",
							"GModTower/pvpbattle/Rage/RageFlesh2.wav",
							"GModTower/pvpbattle/Rage/RageFlesh3.wav",
							"GModTower/pvpbattle/Rage/RageFlesh4.wav" }
SWEP.FistMiss			= {	"GModTower/pvpbattle/Rage/RageMiss1.wav",
							"GModTower/pvpbattle/Rage/RageMiss2.wav" }

SWEP.TeleSound			= "GModTower/balls/TubePop.wav"

SWEP.HoldType = "fist"

function SWEP:PunchingThink()

	if !self.Owner:KeyDown( IN_ATTACK ) then
		self.Think = EmptyFunction
		return
	end

	if !self.NextPunch || CurTime() > self.NextPunch then

		self:PunchRagdoll( self.Primary.Force, self.FistHit, self.FistHitFlesh, self.FistMiss )
		self.NextPunch = CurTime() + self.Primary.Delay

	end

end

function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )

end

function SWEP:Precache()
	GtowerPrecacheSoundTable(self.FistHitFlesh)
	GtowerPrecacheSoundTable(self.FistMiss)
	GtowerPrecacheSound(self.FistHit)
	GtowerPrecacheSound(self.TeleSound)
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self:PunchRagdoll( self.Primary.Force, self.FistHit, self.FistHitFlesh, self.FistMiss )
	self.Think = self.PunchingThink
end

function SWEP:SecondaryAttack()
	if !self:CanSecondaryAttack() then return end
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	self:SmokePort()
end

function SWEP:PunchRagdoll( force, hitworld_sound, hitply_sound, miss_sound )
	local mdmg = 0

	if type(dmg) == "table" then
		mdmg = math.random(dmg[1],dmg[2])
	else
		mdmg = dmg
	end

	local trace = util.TraceHull({start=self.Owner:GetShootPos(),
			endpos=self.Owner:GetShootPos() + self.Owner:GetAimVector() * 50,
			mins=Vector(-8, -8, -8), maxs=Vector(8, 8, 8),
			filter=self.Owner})

	local sound = miss_sound
	if trace.Hit then
		if IsValid(trace.Entity) && trace.Entity:IsPlayer() then
			sound = hitply_sound
		else
			sound = hitworld_sound
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
		local bdmg = 0

		if type(dmg) == "table" then
			bdmg	= math.random(dmg[1],dmg[2])
		else
			bdmg	= dmg
		end

		if trace.Entity:IsPlayer() then
			trace.Entity:SetVelocity( self.Owner:GetAimVector() * force, 0 )

			//Give the achivement for the player
			if self.Owner:IsAdmin() then
				trace.Entity:AddAchivement( 	ACHIVEMENTS.ADMINABUSE, 1 )
			end

		else
			local phys = trace.Entity:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity( self.Owner:GetVelocity() + (self.Owner:GetAimVector() * force) )
			end
		end
	end
end

function SWEP:SmokePort()
	if self.TelePos then
		self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )

		if SERVER then
			timer.Simple(0.8,function() self:SmokeEffects(self.Owner) end)
			timer.Simple(1,function() self:TeleportPlayer(self.Owner,self.TelePos) end)
			self.Owner:ChatPrint("You've escaped with style!")
		end
	else
		if SERVER then self.Owner:ChatPrint("You didn't think your cunning plan through, did you?") end
	end
end

function SWEP:TeleportPlayer(ply, pos)
	if !IsValid(ply) then return end

	ply:SetVelocity(Vector(0,0,0), 0)
	ply:SetPos(pos)
end

function SWEP:SmokeEffects(ply)
	if !IsValid(ply) || !self.TelePos then return end

	local curloc = ply:GetPos()
	local nextloc = self.TelePos

	ply:EmitSound( "GModTower/balls/TubePop.wav", 72, 100 )
	ply:ViewPunch( Angle( -20, 0, 0 ) )

	if SERVER then
		local sfx = EffectData()
			sfx:SetOrigin( curloc )
		util.Effect( "gmt_adminsmoke_effect", sfx )
	end

	local effectdata = EffectData()
		--effectdata:SetAngle( Vector( 180, 0, 0 ) )
		effectdata:SetStart( nextloc )
		effectdata:SetOrigin( nextloc )
		effectdata:SetScale( 6 )
	util.Effect( "cball_bounce", effectdata )

	util.ScreenShake( curloc, 32, 210, 1, 1024 )

	if CLIENT then return end
	local shake = ents.Create( "env_physexplosion" )
		shake:SetKeyValue( "radius", 512 )
		shake:SetKeyValue( "magnitude", 64 )
		shake:SetKeyValue( "spawnflags", "3" )
		shake:SetPos( curloc )

	shake:Fire("Explode" , "", 0)
	shake:Fire("kill","", 2)
end

function SWEP:Reload()
	if self.TeleUse > CurTime() then
		return
	end
	self.TeleUse = CurTime() + 1

	self.TelePos = self.Owner:GetPos()

	if SERVER then
		self.Owner:ChatPrint("You took a mental note of this spot...")
		self.TelePos = self.Owner:GetPos()
		--self.Owner:SetAnimation(PLAYER_SIGNAL_HALT)
	end

	return false
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return true
end
