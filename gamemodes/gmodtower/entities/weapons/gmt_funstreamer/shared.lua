
if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.Base				= "weapon_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.PrintName 			= "Streamer!"
SWEP.Slot				= 0
SWEP.SlotPos			= 0

SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel 		= "models/weapons/w_pistol.mdl"

SWEP.Primary.Delay		= 5

SWEP.AdminDelay			= 0.25
SWEP.PartySound			= "GModTower/misc/confetti.wav"
SWEP.HoldType			= "pistol"

function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )
	self.Color = self:GetRandomColor()

end

function SWEP:Deploy()

	self.Color = self:GetRandomColor()

	if SERVER && self.InventoryItem && self.InventoryItem.WeaponDeployed then
		self.InventoryItem:WeaponDeployed()
	end

	return true

end

function SWEP:Holster()
	if SERVER && self.InventoryItem && self.InventoryItem.WeaponHolstered then
		self.InventoryItem:WeaponHolstered()
	end

	return true
end

function SWEP:DrawWorldModel()

	self:DrawModel()

	local attach = self:LookupAttachment("muzzle")
	if attach > 0 then
		attach = self:GetAttachment(attach)
		attach = attach.Pos
	else
		attach = self.Owner:GetShootPos()
	end

	render.SetMaterial( Material( "sprites/powerup_effects" ) )
	render.DrawSprite( attach, 25, 25, Color( self.Color.r, self.Color.g, self.Color.b, 255 ) )

end

/*function SWEP:ViewModelDrawn()

	local attach = self:LookupAttachment("muzzle")
	if attach > 0 then
		attach = self:GetAttachment(attach)
		attach = attach.Pos
	else
		attach = self.Owner:GetShootPos()
	end

	render.SetMaterial( Material( "sprites/powerup_effects" ) )
	render.DrawSprite( attach, 10, 10, Color( self.Color.r, self.Color.g, self.Color.b, 255 ) )

end*/

function SWEP:Precache()
	//GtowerPrecacheSound(self.PartySound)
end

function SWEP:PrimaryAttack()

	if !self:CanPrimaryAttack() then return end

	if !self.Owner:IsAdmin() then
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	else
		self.Weapon:SetNextPrimaryFire( CurTime() + self.AdminDelay	)
	end

	self.Owner:ViewPunch( Angle( -20, 0, 0 ) )

	if !IsFirstTimePredicted() then return end

	local attach = self:LookupAttachment("muzzle")
	if attach > 0 then
		attach = self:GetAttachment(attach)
		attach = attach.Pos
	else
		attach = self.Owner:GetShootPos()
	end

	local sfx = EffectData()
		sfx:SetOrigin( attach )
		sfx:SetNormal( self.Owner:GetAngles():Forward() )
		--sfx:SetAttachment( "muzzle" )
		sfx:SetEntity( self )
		sfx:SetStart( Vector( self.Color.r, self.Color.g, self.Color.b ) ) //woo hacks
	util.Effect( "fun_streamer", sfx )

	//get a new random color
	self.Color = self:GetRandomColor()

	if SERVER then
		self.Owner:EmitSound( self.PartySound, 50, math.random( 200, 255 ) )

		if self.InventoryItem && self.InventoryItem.WeaponFired then
			self.InventoryItem:WeaponFired()
		end
	end

end

function SWEP:Reload()
	return false
end

function SWEP:CanPrimaryAttack()
	return !Location.IsTheater( GTowerLocation:FindPlacePos(self:GetOwner():GetPos()) )
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:GetRandomColor()

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
