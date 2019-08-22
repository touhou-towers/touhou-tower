
-----------------------------------------------------
SWEP.Base 					= "weapon_virusbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
else
	SWEP.ViewModelFlip		= false
end

//Basic Setup
SWEP.PrintName				= "Sonic Shotgun"
SWEP.Slot					= 3

//Types
SWEP.HoldType				= "shotgun"
SWEP.GunType				= "shotgun"  //for muzzle/shell effects  (default, shotgun, rifle, highcal, or scifi)

//Models
SWEP.ViewModel				= Model("models/weapons/v_vir_scattergun.mdl")
SWEP.WorldModel				= Model("models/weapons/w_vir_scattergun.mdl")

//Primary
SWEP.Primary.ClipSize		= 6
SWEP.Primary.DefaultClip	= 12
SWEP.Primary.Ammo			= "buckshot"
SWEP.Primary.Delay			= 0.3
SWEP.Primary.Recoil	 		= 3
SWEP.Primary.Cone			= 0.05
SWEP.Primary.Damage			= { 12, 14 }
SWEP.Primary.NumShots		= 6

SWEP.Secondary.ClipSize		= 1 // hack! leave at least 1 bullet left so we can equip it
SWEP.Secondary.DefaultClip	= 1 // hack! leave at least 1 bullet left so we can equip it

//Parameters
SWEP.AutoReload				= true
SWEP.ReloadDelay			= 0.6

//Sounds
SWEP.Primary.Sound			= { Sound("GModTower/virus/weapons/SonicDispersionShotgun/shoot1.wav"),
								Sound("GModTower/virus/weapons/SonicDispersionShotgun/shoot2.wav") }

SWEP.Secondary.Sound		= { Sound("GModTower/virus/weapons/SonicDispersionShotgun/alt_shoot1.wav"),
								Sound("GModTower/virus/weapons/SonicDispersionShotgun/alt_shoot2.wav") }

SWEP.SoundReload			= Sound("GModTower/virus/weapons/SonicDispersionShotgun/reload.wav")
SWEP.SoundEmpty		 		= Sound("GModTower/virus/weapons/SonicDispersionShotgun/empty.wav")
SWEP.SoundDeploy			= Sound("GModTower/virus/weapons/SonicDispersionShotgun/deploy.wav")
SWEP.ExtraSounds			= { ["Charge"] = Sound("GModTower/virus/weapons/SonicDispersionShotgun/alt_chargestart.wav"),
								["Empty"] = Sound("GModTower/virus/weapons/SonicDispersionShotgun/alt_empty.wav") }

//Charge
SWEP.NextCharge 			= CurTime()
SWEP.Charging 				= false
SWEP.ChargeLvl				= 0

SWEP.ChargeIncrease			= 0.008
SWEP.NextChargeDelay		= 0.6

SWEP.BlastForce				= 3500

function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )
	self.ChargeSound = CreateSound( self, self.ExtraSounds.Charge )

end

function SWEP:Think()

	if !IsValid( self.Owner ) then return end

	if self.Owner:KeyPressed( IN_ATTACK2 ) then

		self:StartCharge()

	elseif self.Owner:KeyDown( IN_ATTACK2 ) then

		self:UpdateCharge()

	elseif self.Owner:KeyReleased( IN_ATTACK2 ) then

		self:EndCharge()

	end

	self:UpdateColor()

end

function SWEP:Deploy()

	self.ChargeLvl = 0
	self.Charging = false

	self.BaseClass.Deploy( self )

	return true

end

function SWEP:Holster()

	self.ChargeSound:Stop()

	return true

end

function SWEP:SpecialReload()

	return self:Clip1() > 0

end

function SWEP:SecondaryAttack() return end
function SWEP:CanSecondaryAttack() return false end

function SWEP:StartCharge()

	if self.NextCharge > CurTime() then

		self:EmitSound( self.ExtraSounds.Empty )
		return

	end

	self.ChargeLvl = 0
	self.Charging = true
	self.ChargeSound:PlayEx( 100, 100 )

end

function SWEP:UpdateCharge()

	if !self.Charging then return end

	if self.ChargeLvl < 1 then

		self.ChargeLvl = self.ChargeLvl + self.ChargeIncrease

	else

		self.ChargeLvl = 1
		self.ChargeSound:Stop()

	end

end

function SWEP:EndCharge()

	if !self.Charging then return end
	self.Charging = false

	self:ShootPush( math.Clamp( 800, ( self.BlastForce * self.ChargeLvl ), self.BlastForce ), self.ChargeLvl )

	self.ChargeLvl = 0
	self.NextCharge = CurTime() + self.NextChargeDelay
	self.ChargeSound:Stop()

end

local PushableProps = {
	"prop_physics",
	"prop_physics_respawnable",
	"prop_multiplayer",
	"prop_multiplayer_respawnable",
	"prop_dynamic",
	"func_physbox",
}

function SWEP:ShootPush( force, charge )

	//self.Owner:ChatPrint( "force: " .. tostring( force ) .. " charge: " .. tostring( self.ChargeLvl ) )

	self:AirBlastEffect( charge )
	self:EmitSound( self.Secondary.Sound[ math.random( 1, 2 ) ], math.Clamp( 40, 150, ( 150 * charge ) ), math.Clamp( 65, 135, ( 150 * charge ) ) )

	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * ( 3 * charge ), math.Rand( -0.1, 0.1 ) * ( 3 * charge ), 0 ) )

	if CLIENT then return end

	local entList = ents.FindInSphere( self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 30 ), 160 )
	//PrintTable( entList )

	for _, v in ipairs( entList ) do
		for _, propType in ipairs( PushableProps ) do
			if ( v:GetClass() == propType ) || v:IsPlayer() then
				self:PushEnt( v, force, charge )
			end
		end

	end

end

function SWEP:PushEnt( ent, force, charge )

	//Msg( "pushing ent: " , ent, " force: ", force, " charge: " , charge, "\n" )

	if !IsValid( ent ) then return end
	if ( ent == self.Owner ) then return end

	if (ent:IsPlayer()) then

		local newvelocity = self.Owner:GetAimVector() * force
		newvelocity.z = math.Clamp( newvelocity.z, 0, 400 )

		ent:SetVelocity( newvelocity )

	else

		local phys = ent:GetPhysicsObject()
		if IsValid( phys ) then

			//self.Owner:ChatPrint( "Phys! Force: " .. tostring( force ) )

			phys:Wake()
			//phys:EnableMotion( true )
			phys:SetVelocity( phys:GetVelocity() + ( self.Owner:GetAimVector() * ( force * 0.5 ) ) ) //we want to do half the force

		end

	end

end

/*function SWEP:SpecialReload()

	return self:Clip1() > 0

end*/

function SWEP:UpdateColor()

	local ViewModel = self.Owner:GetViewModel()
	if IsValid( ViewModel ) then

		if self.Charging then
			ViewModel:SetColor( Color( math.floor( self.ChargeLvl * -255 ), math.floor( self.ChargeLvl * -255 ), 255, 255 ) )
		else
			ViewModel:SetColor( Color( 255, 255, 255, 255 ) )
		end
	end

end

local function NegRandom( value )
	if ( math.random( 0, 1 ) == 0 ) then
		return value
	else
		return -value
	end
end

function SWEP:GetViewModelPosition( pos, ang )

	local newPos = pos - (self.Owner:GetAimVector() * ( self.ChargeLvl * 4 ))

	local randShake = math.Rand( ( self.ChargeLvl * 0.25 ), ( self.ChargeLvl * 0.5 ) )

	ang.p = ang.p + NegRandom( randShake )
	ang.y = ang.y + NegRandom( randShake )
	ang.r = ang.r + NegRandom( randShake )

	return newPos, ang

end

SWEP.SpriteMat = Material( "sprites/powerup_effects" )
SWEP.RefractMat = Material( "refract_ring" )

function SWEP:AirBlastEffect( charge )

	self.SpriteMat = Material( "sprites/flamelet" .. tostring( math.random( 1, 5 ) ) )

	self.Refract = 0
	self.SpriteSize = 0
	self.SpriteSizeFinal = charge * 20

end

function SWEP:PreDrawViewModel( vm, wep, ply )

	local pos = self:GetMuzzlePos( vm ) + ( vm:GetRight() * -2 )

	// Airblast effect
	if self.Refract then

		if self.Refract >= 1 then
			self.Refract = nil
			return
		end

		self.Refract = self.Refract + 2 * FrameTime()
		self.SpriteSize = ( self.SpriteSizeFinal or 0 ) * self.Refract^(0.2)
		self.RefractMat:SetFloat( "$refractamount", math.sin( self.Refract * math.pi ) * 0.1 )

		local forwardpos = ( vm:GetForward() * self.SpriteSize )
		local color = Color( 0, 128, 255, 200 )
		local size = self.SpriteSize / 2

		render.SetMaterial( self.RefractMat )
		render.UpdateRefractTexture()
		render.DrawSprite( forwardpos + pos + ( EyePos() - pos ):GetNormal() * EyePos():Distance( pos ) * ( self.Refract^( 0.3 ) ) * 0.8, self.SpriteSizeFinal, self.SpriteSizeFinal / 1.5 )

		render.SetMaterial( Material( "sprites/flamelet" .. tostring( math.random( 1, 5 ) ) ) )
		render.DrawSprite( pos, size, size, color )

	end

end

function SWEP:PostDrawViewModel( vm, wep, ply )

	local pos = self:GetMuzzlePos( vm ) + ( vm:GetRight() * -5 ) + ( vm:GetUp() * -2 )
	if !pos then return end
	local ang = LocalPlayer():EyeAngles()

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )

	local perc = self.ChargeLvl
	if perc == 0 then return end

	cam.Start3D2D( pos, Angle( ang.p, ang.y, ang.r ), 0.05 )

		local w, h = 100, 10
		local padding = 1
		local x = ( w / 2 + ( padding / 2 ) ) * - 1
		local y = ( h / 2 + ( padding / 2 ) ) * - 1

		local color = colorutil.TweenColor( Color( 50, 50, 255, 150 ), Color( 255, 100, 255, 150 ), perc )
		draw.RectFillBorder( x, y, w, h, padding, perc, Color( 100, 100, 255, 150 ), color )

	cam.End3D2D()

end
