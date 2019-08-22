

-----------------------------------------------------
if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.Category		 = "PVP Battle"
SWEP.PrintName 		 = "PVP Base"
SWEP.Slot		 	 = -1
SWEP.SlotPos		 = 0

SWEP.Spawnable		= true
SWEP.AdminSpawnable	= true

SWEP.Weight		= 5
SWEP.AutoSwitchTo	= false
SWEP.AutoSwitchFrom	= false

SWEP.HoldType		= "ar2"

SWEP.ViewModel		= ""
SWEP.WorldModel		= ""

SWEP.AutoReload		= true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		= "none"
SWEP.Primary.Delay		= 0
SWEP.Primary.Recoil	 	= 2
SWEP.Primary.Cone		= 0.08

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"
SWEP.Secondary.Delay		= 0

SWEP.HitSound		= nil
SWEP.HitEffect		= nil

SWEP.SoundEmpty		= nil

SWEP.SoundDeploy	= nil
SWEP.AnimDeploy		= nil

SWEP.IronTime		= 0.3
SWEP.IronZoom		= false
SWEP.IronZoomFOV	= 62
SWEP.IronFOVTime	= 0.2
SWEP.IronZoomSound	= "weapons/sniper/sniper_zoomin.wav"
SWEP.IronUnZoomSound	= "weapons/sniper/sniper_zoomout.wav"
SWEP.IronPost		= false
SWEP.IconSightTime  = .25

SWEP.HideViewModel	= 0

SWEP.Description	= ""
SWEP.StoreBuyable	= false
SWEP.StorePrice		= 0	

SWEP.HitDecals = {
	[MAT_FLESH] = "Impact.BloodyFlesh",
	[MAT_CONCRETE] = "Impact.Concrete",
	[MAT_GLASS] = "Impact.Glass",
	[MAT_SAND] = "Impact.Sand",
	[MAT_WOOD] = "Impact.Wood",
}

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:Reload()

	if self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 || self.Weapon:Clip1() >= self.Primary.ClipSize then
		return
	end

	self:Ironsight(false)

	if self.SpecialReload && self:SpecialReload() then
		return
	end

	if self.SoundReload && IsFirstTimePredicted() then
		self:EmitSound( self.SoundReload )
	end

	self.Weapon:DefaultReload( ACT_VM_RELOAD )
	self.Owner:SetAnimation( PLAYER_RELOAD )

end

function SWEP:Deploy()

	if self.SoundDeploy && IsFirstTimePredicted() then
		self:EmitSound( self.SoundDeploy )
	end

	self:SendWeaponAnim( self.AnimDeploy or ACT_VM_DRAW )

	self.Owner.Iron = false
	self.Owner.Reloading = false

	return true

end

function SWEP:Holster()

	self.HideViewModel = 0
	self:Ironsight(false)

	return true

end

function SWEP:PrimaryAttack()

	if !self:CanPrimaryAttack() then return true end

	if !self.Primary.NoSecondaryDelay then
		self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	end

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone, self.Primary.Ammo)
	self:ShootEffects(self.Primary.Sound, self.Primary.Recoil, self.Primary.Effect, ACT_VM_PRIMARYATTACK)

	if !self.Primary.UnlimAmmo then
		self:TakePrimaryAmmo( 1 )
	end

end

function SWEP:SecondaryAttack()

	if !self:CanSecondaryAttack() then return true end

	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Secondary.Delay )
	
	self:ShootBullet(self.Secondary.Damage, self.Secondary.NumShots, self.Secondary.Cone, self.Primary.Ammo, self.Secondary.Effect)
	self:ShootEffects(self.Secondary.Sound, self.Secondary.Recoil, self.Primary.Effect, ACT_VM_SECONDARYATTACK)

	if !self.Primary.UnlimAmmo then
		self:TakePrimaryAmmo( 1 )
	end

end

function SWEP.ShootBulletRicochet(ply, bullet)

	if !IsValid(ply) then return end
	ply:FireBullets(bullet)

end

function SWEP:RicochetCallback(att, tr, dmginfo, num)

	if CLIENT then return end
	if tr.HitNonWorld || tr.HitSky then return end

	local fx = EffectData()
		fx:SetOrigin( tr.HitPos )
		fx:SetNormal( tr.HitNormal )
	util.Effect( "StunstickImpact", fx, true )

	local fx = EffectData()
		fx:SetOrigin( tr.HitPos )
		fx:SetNormal( tr.HitNormal )
	util.Effect( "bulletsmoke", fx, true )

	if num > self.Ricochet then return end

	local DotProduct = tr.HitNormal:Dot( tr.Normal * -1 )

	local bullet = {}
	
	bullet.Num		= 1
	bullet.Src		= tr.HitPos
	bullet.Dir		= ( 2 * tr.HitNormal * DotProduct ) + tr.Normal
	bullet.Spread 		= Vector( 0, 0, 0 )
	bullet.Tracer		= 1
	bullet.TracerName 	= "ragingbull_trace"
	bullet.Force		= 1
	bullet.Damage		= math.random( 75, 90 )
	bullet.AmmoType		= self.Primary.Ammo
	bullet.Callback		= function( a, b, c )
		if IsValid(self) && self.RicochetCallback then
			self:RicochetCallback( a, b, c, num + 1 )
		end
	end

	timer.Simple( 0.03 * num, self.ShootBulletRicochet, self.Owner, bullet )

end

function SWEP:ShootMelee( dmg, hitworld_sound, hitply_sound, miss_sound )

	local trace = util.TraceHull({start=self.Owner:GetShootPos(),
			endpos=self.Owner:GetShootPos() + self.Owner:GetAimVector() * 100,
			mins=Vector(-10, -10, -10), maxs=Vector(10, 10, 10),
			filter=self.Owner})

	local sound = miss_sound
		
	if sound && IsFirstTimePredicted() then
		if type(sound) == "table" then
			self.Weapon:EmitSound( sound[math.random(1, #sound)] )
		else
			self.Weapon:EmitSound( sound )
		end
	end

	util.Decal( self.HitDecals[trace.MatType] or "Impact.Metal", trace.HitPos + trace.HitNormal, trace.HitPos + trace.HitNormal * -20 + VectorRand() * 2 )

	if trace.Hit then

		if !IsValid(trace.Entity) then
			sound = hitworld_sound

			local effectdata = EffectData()
				effectdata:SetOrigin( trace.HitPos )
			util.Effect( "MetalSpark", effectdata, true, true )
		end
		
		if sound && IsFirstTimePredicted() then
			if type(sound) == "table" then
				self.Weapon:EmitSound( sound[math.random(1, #sound)] )
			else
				self.Weapon:EmitSound( sound )
			end
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

		trace.Entity:TakeDamage(bdmg, self.Owner)

		sound = hitply_sound
		if sound && IsFirstTimePredicted() then

			if type(sound) == "table" then
				self.Weapon:EmitSound( sound[math.random(1, #sound)] )
			else
				self.Weapon:EmitSound( sound )
			end

			if trace.Entity:IsPlayer() then
				local effectdata = EffectData()
					effectdata:SetOrigin( trace.HitPos )
					effectdata:SetNormal( trace.HitNormal )
					effectdata:SetScale( 4 )
				util.Effect( "bloodcloud", effectdata, true, true )
			end

		end

	end
end


function SWEP:ShootBullet( dmg, numbul, cone, ammo )
	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01

	local bullet = {}
	bullet.Num 		= numbul
	bullet.Src 		= self.Owner:GetShootPos()
	bullet.Dir 		= self.Owner:GetAimVector()
	bullet.Spread 	= Vector( cone, cone, 0 )
	bullet.Tracer	= 1
	bullet.Force	= 1

	if type(dmg) == "table" then
		bullet.Damage	= math.random(dmg[1],dmg[2])
	else
		bullet.Damage	= dmg
	end

	if ammo != "none" then
		bullet.AmmoType	= ammo
	end

	bullet.Callback = function(att, tr, dmginfo)
		self:BulletCallback(att, tr, dmginfo)
	end
	
	self.Owner:FireBullets( bullet )
end

function SWEP:ShootEffects(sound, viewpunch, effect, anim)
	if sound && IsFirstTimePredicted() then
		if type(sound) == "table" then
			self.Weapon:EmitSound( sound[math.random(1, #sound)] )
		else
			self.Weapon:EmitSound( sound )
		end
	end

	if viewpunch then
		self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * viewpunch, 0, 0 ) )
	end

	if effect && IsFirstTimePredicted() then
		local tr = self.Owner:GetEyeTrace()
		local effectdata = EffectData()
			effectdata:SetOrigin( tr.HitPos )
			effectdata:SetStart( self.Owner:GetShootPos() + Vector( 0, 5, 0 ) )
			effectdata:SetAttachment( 1 )
			effectdata:SetEntity( self )
		util.Effect( effect, effectdata )
	end

	local effectdata = EffectData()
		effectdata:SetOrigin( self.Owner:GetShootPos() )
		effectdata:SetEntity( self.Weapon )
		effectdata:SetStart( self.Owner:GetShootPos() )
		effectdata:SetNormal( self.Owner:GetAimVector() )
		effectdata:SetAttachment( 1 )
	util.Effect( "gunsmoke", effectdata )

	self.Weapon:SendWeaponAnim( anim or ACT_VM_PRIMARYATTACK )
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:ShootZoom()
	self:Ironsight(!self.Owner.Iron)
end

function SWEP:CanPrimaryAttack()
	if self.Weapon:Clip1() == 0 then
		if self.SoundEmpty && IsFirstTimePredicted() then
			if type(self.SoundEmpty) == "table" then
				self:EmitSound( self.SoundEmpty[math.random(1,#self.SoundEmpty)] )
			else
				self:EmitSound( self.SoundEmpty )
			end
		end

		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

		if self.AutoReload then self:Reload() end
		return false
	else
		return true
	end
end

SWEP.CanSecondaryAttack = SWEP.CanPrimaryAttack

function SWEP:Ironsight(enable)
	if !IsFirstTimePredicted() || self.Owner.Iron == enable then return end

	self.Owner.Iron = enable

	if self.IronZoom then
		if enable then
			if self.IronPost then
				//PostEvent( self.Owner, "isights_on" )
			else
				self.HideViewModel = CurTime() + self.IronTime
			end

			if SERVER then
				self.Owner:SetFOV(self.IronZoomFOV, self.IronFOVTime)
			else
				surface.PlaySound( self.IronZoomSound )
			end
		else
			if self.IronPost then
				//PostEvent( self.Owner, "isights_off" )
			end

			if SERVER then
				self.Owner:SetFOV(0, self.IronFOVTime)
				self.Owner:DrawViewModel( true )
			else
				surface.PlaySound( self.IronUnZoomSound )
			end
		end
	end
end
