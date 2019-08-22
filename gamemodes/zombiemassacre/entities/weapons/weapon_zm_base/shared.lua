SWEP.Base					= "weapon_base"
SWEP.AutoSwitchTo			= true
SWEP.AutoSwitchFrom			= false
SWEP.WorldModel				= ""
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 30000
SWEP.Primary.Automatic		= false
SWEP.Primary.Delay			= 0
SWEP.Primary.Cone			= 0.08
SWEP.Primary.NumShots		= 1
SWEP.Primary.Damage			= nil
SWEP.Primary.Sound			= nil
SWEP.Primary.Effect			= nil
SWEP.Primary.Trace			= "trace"
SWEP.Primary.Force			= nil
SWEP.Primary.HitDecal		= nil
SWEP.Primary.HitEffect		= nil
SWEP.Primary.HitSound		= nil
SWEP.SoundMHitW				= nil
SWEP.SoundMHitP				= nil
SWEP.SoundMHitPAlt			= nil
SWEP.SoundMMiss				= nil
SWEP.Offsets				= nil
SWEP.Tier					= DropManager.COMMON
SWEP.IsMelee				= false
SWEP.MaxDurability			= nil
if SERVER then
	SWEP.Durability			= nil
end
SWEP.QuickMelee				= false
function SWEP:Initialize()
		self:SetNWInt( "Durability", self.Durability )	
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:Reload()
	return false
end
function SWEP:Deploy()
	/*if SERVER && !self.IsMelee && !IsValid( self.Owner.LaserEntity ) then
		local ent = ents.Create("zm_laser_regular")
		ent:SetParent( self.Weapon )
		ent:SetOwner( self.Weapon )
		ent:Spawn()
		self.Owner.LaserEntity = ent
	end*/
	return true
end
function SWEP:Holster()
	/*if IsValid( self.Owner.LaserEntity ) then
		self.Owner.LaserEntity:Remove()
	end*/
	return true

end
function SWEP:Melee()
end
function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return true end
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:ShootBullet( self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone, self.Primary.Trace )
	self:ShootEffects( self.Primary.Sound, self.Primary.Effect, self.Primary.Force )
	self:TakePrimaryAmmo( 1 )
end

function SWEP:CanPrimaryAttack()
	return true
end
function SWEP:CanSecondaryAttack()
	return false
end
function SWEP:ShootBullet( dmg, numbul, cone, trceff, offset )
	local dmg	 = dmg or 0
	local numbul = numbul or 1
	local cone 	 = cone or 0
	local trceff = trceff or "trace"
	local attach = self:LookupAttachment("muzzle")
	if attach > 0 then
		attach = self:GetAttachment(attach)
		attach = attach.Pos
	else
		attach = self.Owner:GetShootPos()
	end
	if offset then
		attach = attach + offset
	end
	local bullet =
	{
		Num 		= numbul,
		Src 		= attach,
		Dir 		= self.Owner:GetAimVector() + Vector( 0, 0, -0.05 ),
		Spread 		= Vector( cone, cone, cone ),
		Tracer		= 1,
		Force		= 1,
		TracerName 	= trceff
	}
	if type( dmg ) == "table" then
		bullet.Damage	= math.random( dmg[1], dmg[2] )
	else
		//Let's so some randomization.
		local dmg2 = math.ceil( dmg * math.Rand( 0.5, 0.75 ) )
		bullet.Damage	= math.random( dmg2, dmg )
	end
	bullet.Callback = function( att, tr, dmginfo ) self:BulletCallback( att, tr, dmginfo ) end
	self.Owner:FireBullets( bullet )
end
function SWEP:ShootEffects( snd, eff, force, nosmoke )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	if !IsFirstTimePredicted() then return end
	if force && SERVER then
		self.Owner:SetVelocity( self.Owner:GetAimVector() * -force, 0 )
	end
	if snd then
		if type( snd ) == "table" then
			snd = snd[math.random(1, #snd )]
		end
		self.Weapon:EmitSound( snd, 100, math.random( 90, 120 ) )
		
	end
	if eff then
		local t = {}
		t.start = self.Owner:GetShootPos()
		t.endpos = t.start + self.Owner:GetAimVector() * 9000
		t.filter = self.Owner
		local tr = util.TraceLine(t)
		local effectdata = EffectData()
			effectdata:SetOrigin( tr.HitPos )
			effectdata:SetStart( self.Owner:GetShootPos() )
			effectdata:SetEntity( self.Owner )
		util.Effect( eff, effectdata )
	end
	if !nosmoke then
		// Smoke
		local eff = EffectData()
			eff:SetOrigin( self.Owner:GetShootPos() )
			eff:SetEntity( self.Weapon )
			eff:SetStart( self.Owner:GetShootPos() )
			eff:SetNormal( self.Owner:GetAimVector() )
			eff:SetAttachment( 1 )
		util.Effect( "gunsmoke", eff )
		// Flash
		local eff = EffectData()
			eff:SetOrigin( self.Owner:GetShootPos() )
			eff:SetEntity( self.Weapon )
			eff:SetStart( self.Owner:GetShootPos() )
			eff:SetNormal( self.Owner:GetAimVector() )
			eff:SetAttachment( 1 )
		util.Effect( "gunflash", eff )
	end
end
function SWEP:ShootMelee( dmg, hitworld_sound, hitply_sound, miss_sound, weff, heff, dura )
	local trace = util.TraceHull( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 50 ),
		mins = Vector( -12, -12, -12 ) * 2,
		maxs = Vector( 12, 12, 12 ) * 2,
		filter = self.Owner
	} )
	//self.Owner:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_STAND_PRIMARYFIRE )
	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	local dmg = dmg or 0
	local sound = miss_sound
	local eff = nil
	if trace.Hit then
		if IsValid( trace.Entity ) && !trace.Entity:IsPlayer() then
			sound = hitply_sound
			if trace.Entity:IsNPC() then
				eff = heff
			else
				eff = weff
			end
			if SERVER then
				if type( dmg ) == "table" then
					dmg	= math.random( dmg[1], dmg[2] )
				end
				self:Melee( trace.Entity )
				if trace.Entity:GetClass() == "prop_physics" then
					eff = weff
					trace.Entity:Fire( "Break", "", 0 )
				else
					trace.Entity:TakeDamage( dmg, self.Owner )
					// Subtract durability
					if self:GetNWInt( "Durability" ) then
						if !dura then dura = 1 end
						self:SetNWInt( "Durability", self:GetNWInt( "Durability" ) - dura )
					end
				
				end
			end
		else
			sound = hitworld_sound
			eff = weff
		end
	end
	if !IsFirstTimePredicted() then return end
	// Sound effect
	if sound then
	
		if sound != miss_sound then
			if type(miss_sound) == "table" then
				miss_sound = miss_sound[math.random(1, #miss_sound)]
			end
			self.Weapon:EmitSound( miss_sound )
		end
		if type(sound) == "table" then
			sound = sound[math.random(1, #sound)]
		end
		self.Weapon:EmitSound( sound )
	end
	// Effect
	if eff then
		local effectdata = EffectData()
			effectdata:SetOrigin( trace.HitPos )
			effectdata:SetNormal( self.Owner:GetAngles():Forward() )
		util.Effect( eff, effectdata )
	end
end
function SWEP:ShootEnt( class, force, dir )
	if CLIENT || !class then return end
	local force = force or 1500
	local dir = dir or -0.1
	local ent = ents.Create( class )
	if !IsValid(ent) then return end
	local AimVector = self.Owner:GetAimVector() + Vector( 0, 0, dir )
	ent:SetPos( self.Owner:GetShootPos() )
	ent:SetAngles( AimVector:Angle() )		
	ent:SetOwner( self.Owner )
	ent:SetPhysicsAttacker( self.Owner ) 
	ent:Spawn()
	ent:Activate()
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity( self.Owner:GetVelocity() + ( AimVector * force ) )
	end
end