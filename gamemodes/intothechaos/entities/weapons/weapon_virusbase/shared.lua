if SERVER then
	AddCSLuaFile( "shared.lua" )
end

/*if !VirusBaseIncludeGuard then
	RegisterNWTablePlayer({
		{"Iron", false, NWTYPE_BOOLEAN, REPL_PLAYERONLY},
		{"Reloading", false, NWTYPE_BOOLEAN, REPL_PLAYERONLY}
	})
end*/
VirusBaseIncludeGuard = true

//Basic Setup
SWEP.PrintName				= "Virus Base"
SWEP.Slot					= -1
SWEP.SlotPos				= 0

//Types
SWEP.HoldType				= "ar2"
SWEP.GunType				= "default"  //for muzzle/shell effects  (default, shotgun, rifle, highcal, or scifi)

//Models
SWEP.ViewModel				= nil
SWEP.WorldModel				= nil

//Primary
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay			= 0
SWEP.Primary.Recoil	 		= 2
SWEP.Primary.Cone			= 0.08
SWEP.Primary.Damage			= nil
SWEP.Primary.NumShots		= 1
SWEP.Primary.AmmoAmount		= 1

//Secondary
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.Delay		= 0
SWEP.Secondary.Recoil	 	= 2
SWEP.Secondary.Cone			= 0.08
SWEP.Secondary.Damage		= nil
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.AmmoAmount	= 1
SWEP.Secondary.Anim 		= ACT_VM_PRIMARYATTACK

//Parameters
SWEP.AutoReload				= true
SWEP.RemoveOnEmpty			= false
SWEP.Ricochet				= nil
SWEP.ReloadDelay			= SWEP.Primary.Delay

//Muzzle/Shell
SWEP.MuzzleAttachment		= "1" //1 for css, muzzle for hl2
SWEP.ShellEjectAttachment	= "2" //2 for css, 1 for hl2

//Effects
SWEP.Effect					= nil
SWEP.Trace					= nil
SWEP.TraceHit				= nil
SWEP.TraceDecal				= nil
SWEP.HitEffect				= nil

//Sounds
SWEP.Primary.Sound			= nil
SWEP.Secondary.Sound		= nil
SWEP.SoundReload			= nil
SWEP.SoundEmpty		 		= "Weapon_Pistol.Empty"
SWEP.SoundDeploy			= nil
SWEP.AnimDeploy				= nil
SWEP.ExtraSounds			= nil

//Ironsight&Zoom
SWEP.IronTime				= 0.3
SWEP.IronZoom				= false
SWEP.IronZoomFOV			= 62
SWEP.IronFOVTime			= 0.2
SWEP.IronZoomSound			= Sound("GModTower/virus/weapons/iron_in.wav")
SWEP.IronUnZoomSound		= Sound("GModTower/virus/weapons/iron_out.wav")
SWEP.IronPost				= false

function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )

end

function SWEP:Precache()
end

function SWEP:Reload()

	if ( self.Owner:IsPlayer() && self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 ) || self.Weapon:Clip1() >= self.Primary.ClipSize then
		return
	end

	self:Ironsight( false )

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

	if ( self.Owner.GetViewModel ) then
		local ViewModel = self.Owner:GetViewModel()
		if IsValid( ViewModel ) then
			ViewModel:SetColor( Color( 255, 255, 255, 255 ) )
		end
	end

	self.Owner.Iron = false
	self.Owner.Reloading = false

	return true

end

function SWEP:Holster()

	self:Ironsight(false)

	if ( self.Owner.GetViewModel ) then
		local ViewModel = self.Owner:GetViewModel()
		if IsValid( ViewModel ) then
			ViewModel:SetColor( Color( 255, 255, 255, 255 ) )
		end
	end

	return true

end

function SWEP:PrimaryAttack()

	if !self:CanPrimaryAttack() then return true end

	if !self.Primary.UnlimitedAmmo && self.Weapon:Clip1() - self.Primary.AmmoAmount < 0 then
		return true
	end

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )

	self:ShootBullet( self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone, self.Primary.Ammo )
	self:ShootEffects( self.Primary.Sound, self.Primary.Recoil, self.Effect, ACT_VM_PRIMARYATTACK, self.GunType )

	self:TakePrimaryAmmo( self.Primary.AmmoAmount )

end

function SWEP:SecondaryAttack()

	if !self:CanSecondaryAttack() then return true end

	if self.Weapon:Clip1() - self.Secondary.AmmoAmount < 0 then
		return true
	end

	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Secondary.Delay )

	self:ShootBullet( self.Secondary.Damage, self.Secondary.NumShots, self.Secondary.Cone, self.Primary.Ammo )
	self:ShootEffects( self.Secondary.Sound, self.Secondary.Recoil, self.Effect, self.Secondary.Anim, self.GunType )

	self:TakePrimaryAmmo( self.Secondary.AmmoAmount )

end

function SWEP:CanPrimaryAttack()

	if self.Primary.UnlimitedAmmo then
		return true
	end

	if self.Weapon:Clip1() <= 0 then

		if self.SoundEmpty && IsFirstTimePredicted() then
			if type(self.SoundEmpty) == "table" then
				self:EmitSound( self.SoundEmpty[math.random( 1, #self.SoundEmpty )] )
			else
				self:EmitSound( self.SoundEmpty )
			end
		end

		self:SetNextPrimaryFire( CurTime() + self.ReloadDelay )
		self:SetNextSecondaryFire( CurTime() + self.ReloadDelay )

		if self.AutoReload then self:Reload() end
		return false

	else

		return true

	end

end
SWEP.CanSecondaryAttack = SWEP.CanPrimaryAttack

function SWEP:ShootBullet( dmg, numbul, cone, ammo )

	dmg		= dmg		or 0
	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01

	local bullet = {}
	bullet.Num 			= numbul
	bullet.Src 			= self.Owner:GetShootPos()
	bullet.Dir 			= self.Owner:GetAimVector()
	bullet.Spread 		= Vector( cone, cone, 0 )
	bullet.Tracer		= 1

	if self.Trace then
		bullet.TracerName 	= self.Trace
	end

	bullet.Force		= .25

	if type(dmg) == "table" then
		bullet.Damage	= math.random( dmg[1],dmg[2] )
	else
		bullet.Damage	= dmg
	end

	if ammo != "none" then
		bullet.AmmoType	= ammo
	end

	bullet.Callback = function( att, tr, dmginfo ) self:BulletCallback( att, tr, dmginfo ) end

	//Don't shoot bullets at glass.
	/*local tr = self.Owner:GetEyeTrace()
	if tr.MatType == MAT_GLASS then

		if self.Trace then

			local attach = self:LookupAttachment( "muzzle" )
			if attach > 0 then
				attach = self:GetAttachment(attach)
				attach = attach.Pos
			else
				attach = self.Owner:GetShootPos() + Vector( 0, 5, 0 )
			end

			local effectdata = EffectData()
				effectdata:SetOrigin( tr.HitPos )
				effectdata:SetStart( attach )
				effectdata:SetAttachment( self.MuzzleAttachment )
				effectdata:SetEntity( self )
			util.Effect( self.Trace, effectdata )

		end

		util.Decal( "Impact.Glass", tr.HitPos + tr.HitNormal, tr.HitPos + tr.HitNormal * -20 + VectorRand() * 15 )
		return
	end*/

	self.Owner:FireBullets( bullet )

end

function SWEP:ShootEffects( sound, viewpunch, effect, anim, guntype )

	self.Weapon:SendWeaponAnim( anim or ACT_VM_PRIMARYATTACK )
	if !self.CustomMuzzleFlash then self.Owner:MuzzleFlash() end
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	if viewpunch then
		//self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * viewpunch, math.Rand( -0.1, 0.1 ) * viewpunch, 0 ) )
		self.Owner.ViewPunchAngle = Angle( math.Rand(-0.2,-0.1) * viewpunch, math.Rand( -0.1, 0.1 ) * viewpunch, 0 )
	end

	if !IsFirstTimePredicted() then return end

	if sound then

		if type(sound) == "table" then
			self.Weapon:EmitSound( sound[math.random(1, #sound)] )
		else
			self.Weapon:EmitSound( sound )
		end

	end

	if effect then

		local tr = self.Owner:GetEyeTrace()

		local attach = self:LookupAttachment( "muzzle" )
		if attach > 0 then
			attach = self:GetAttachment(attach)
			attach = attach.Pos
		else
			attach = self.Owner:GetShootPos() + Vector( 0, 5, 0 )
		end

		local effectdata = EffectData()
			effectdata:SetOrigin( tr.HitPos )
			effectdata:SetStart( attach )
			effectdata:SetAttachment( self.MuzzleAttachment )
			effectdata:SetEntity( self )
		util.Effect( effect, effectdata )

	end

	/*if guntype then

		local scale = 0
		if guntype == "shotgun" then
			scale = 1
		elseif guntype == "rifle" then
			scale = 2
		elseif guntype == "highcal" then
			scale = 3
		elseif guntype == "scifi" then
			scale = 4
		end

		//Muzzle disabled for the time being. I haven't coded the effect yet.
			local effectdata = EffectData()
				effectdata:SetEntity( self )
				effectdata:SetOrigin( self.Owner:GetShootPos() )
				effectdata:SetNormal( self.Owner:GetAimVector() )
				effectdata:SetAttachment( self.MuzzleAttachment )
				effectdata:SetScale( scale )  //this is a hack
			util.Effect( "muzzleflash", effectdata )


		local effectdata2 = EffectData()
			effectdata2:SetEntity( self )
			effectdata2:SetNormal( self.Owner:GetAimVector() )
			effectdata2:SetAttachment( self.ShellEjectAttachment )
			effectdata2:SetScale( scale )  //this is a hack
		util.Effect( "shelleject", effectdata2 )

	end*/

end

function SWEP.ShootBulletRicochet( ply, bullet, tr )

	if !IsValid(ply) then return end

	/*Msg( PrintTable( tr ) )
	if tr.MatType == MAT_GLASS then
		util.Decal( "Impact.Glass", tr.HitPos + tr.HitNormal, tr.HitPos + tr.HitNormal * -20 + VectorRand() * 15 )
		return
	end*/

	ply:FireBullets(bullet)

end

function SWEP:ShootZoom() self:Ironsight( !self.Owner.Iron ) end
function SWEP:Ironsight( enable )

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

function SWEP:GetMuzzlePos( vm )

	local attach = vm:LookupAttachment( "muzzle" )
	if attach > 0 then
		attach = vm:GetAttachment(attach)
	else
		attach = vm:GetAttachment(2)
	end

	return attach.Pos

end


// Syndicate like ammo
/*local gradientUp = surface.GetTextureID( "gui/gradient_up" )
local gradientDown = surface.GetTextureID( "gui/gradient_down" )

surface.CreateFont( "GunText", { font = "Bebas Neue", size = 32, weight = 100 } )
surface.CreateFont( "GunTextSmall", { font = "Bebas Neue", size = 16, weight = 100 } )

function SWEP:PostDrawViewModel( vm, wep, ply )

	local pos = self:GetMuzzlePos( vm ) + ( vm:GetRight() * -5 ) + ( vm:GetUp() * -2 )
	if !pos then return end
	local ang = LocalPlayer():EyeAngles()

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )

	local ammo_left = wep:Clip1()
	local ammo_total = wep:Ammo1()

	if ammo_left == -1 then return end

	cam.Start3D2D( pos, Angle( ang.p, ang.y, ang.r ), 0.05 )

		local text = ammo_left .."/".. ammo_total

		surface.SetDrawColor( 0, 0, 150, CosBetween( 50, 150, FrameTime() * 1000 ) )

		if self.Owner.Reloading then
			text = "RELOADING"
			surface.SetDrawColor( 150, 0, 0, CosBetween( 50, 150, FrameTime() * 1000 ) )
		end

		surface.SetFont( "GunText" )
		local w, h = surface.GetTextSize( text )
		h = h / 2

		local padding = 8

		if self.LastAmmo != ammo_left then
			self.LastAmmo = ammo_left
			padding = 10
		end

		local x = ( w / 2 + ( padding / 2 ) ) * - 1
		local y = ( h / 2 + ( padding / 2 ) ) * - 1

		// Draw box top
		surface.SetTexture( gradientUp )
		surface.DrawTexturedRect( x, y, w + padding, h + padding )

		// Draw box bottom
		surface.SetTexture( gradientDown )
		surface.DrawTexturedRect( x, y, w + padding, h + padding )

		// Draw dots
		surface.SetDrawColor( 80, 80, 255, 255 )
		if self.Owner.Reloading then
			surface.SetDrawColor( 255, 80, 80, 255 )
		end

		surface.DrawRect( x, y, 2, 2 )
		surface.DrawRect( x, y + h + padding - 1, 2, 2 )
		surface.DrawRect( x + w + padding - 1, y, 2, 2 )
		surface.DrawRect( x + w + padding - 1, y + h + padding - 2, 2, 2 )

		draw.SimpleText( text, "GunText", 0, 2, nil, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	cam.End3D2D()

end*/
