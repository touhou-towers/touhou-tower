
SWEP.Base = "weapon_pvpbase"
SWEP.PrintName 		 = "Stealth Box"
SWEP.Slot			 = 0
SWEP.SlotPos		 = 0

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.WorldModel		 = ""
	SWEP.DrawCrosshair	= false
end

SWEP.SoundDeploy		 = "physics/cardboard/cardboard_box_break1.wav"
SWEP.Box			 = nil
SWEP.HoldType			= "normal"

SWEP.Taunts			= {}
for i=1,6 do
	SWEP.Taunts[i] = "GModTower/pvpbattle/Taunts/TauntBox" .. tostring(i) .. ".wav"
end

SWEP.Description = "Hide yourself inside a box and dissapear completely from your enemies' view.  Taunt them over towards you, then pop out and end their lives.  Snake used it, so can you."
SWEP.StoreBuyable = false
SWEP.StorePrice = 0

function SWEP:Precache()
	GtowerPrecacheSound( self.SoundDeploy )
	GtowerPrecacheSoundTable( self.Taunts )
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire( CurTime() + 7 )
	if !self:CanPrimaryAttack() || CLIENT then 
		return
	end

	local soundnum = math.random( 1, 6 )
	self.Owner:EmitSound( self.Taunts[math.random(1, #self.Taunts)] )
end

function SWEP:Think()
	if CLIENT then return end

	if self.BoxTimer > 0 && CurTime() > self.BoxTimer then
		self.Owner.Box = ents.Create( "pvp_stealthbox" )
		
		if !IsValid( self.Owner.Box ) then
			return
		end

		self.Owner.Box:Spawn()
		self.Owner.Box:SetBoxHolder( self.Owner )

		self.BoxTimer = 0
	end
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:Reload()
	return false
end

function SWEP:RemoveBox()
	if IsValid( self.Owner.Box ) then
		self.Owner.Box:Remove()
	end
	
	return true
end

function SWEP:Deploy()
	if !self.Owner:Alive() then return end

	if CLIENT && IsFirstTimePredicted() then
		self:EmitSound( self.SoundDeploy )
	end

	if SERVER then
		self.BoxTimer = CurTime() + 0.1
		self:RemoveBox()
	end

	return true
end

if SERVER then
	SWEP.Holster = SWEP.RemoveBox
	SWEP.OnRemove = SWEP.RemoveBox
	hook.Add("PlayerDeath", "RemoveBox", function(ply) if IsValid(ply.Box) then ply.Box:Remove() end end)
	hook.Add("PlayerDisconnected", "RemoveBox", function(ply) if IsValid(ply.Box) then ply.Box:Remove() end end)
end