SWEP.Base 					= "weapon_virusbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
else
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFlip		= false
end

//Basic Setup
SWEP.PrintName				= "TNT"
SWEP.Slot					= 5

//Types
SWEP.HoldType				= "grenade"
SWEP.HoldTypeThrown			= "normal"

//Models
SWEP.ViewModel		 		= "models/weapons/v_vir_tnt.mdl"
SWEP.WorldModel		 		= "models/weapons/w_vir_tnt.mdl"

//Sounds
SWEP.Primary.Sound			= "GModTower/virus/weapons/TNT/throw.wav"
SWEP.Secondary.Sound		= "GModTower/virus/weapons/TNT/detonate.wav"
SWEP.ExtraSounds			= "GModTower/virus/weapons/TNT/pre_throw.wav"

function SWEP:SetupDataTables()
	self:DTVar("Bool", 0, "Thrown")
end

function SWEP:Thrown()
	return self.dt.Thrown
end

function SWEP:Think()

	if IsValid(self.Owner) && self.dt.Thrown then
		
		-- Change holdtype to default after throwing the tnt
		if !self.bHoldTypeChanged then
			--Msg(self.Owner:Nick() .. " threw their tnt!\n")
		
			self:SetWeaponHoldType( self.HoldTypeThrown )
			self.bHoldTypeChanged = true -- apparently GetHoldType doesn't update...
		
			if SERVER then
				self:SetNoDraw(true)
				self:DrawShadow(false)
			end
		end
	
		if SERVER && !IsValid( self.Owner.TNT ) then
			self.Owner:StripWeapon( "weapon_tnt" )
		end
		
	end

end

function SWEP:PrimaryAttack()

	if !IsFirstTimePredicted() || CLIENT then return end

	if self:Thrown() || IsValid( self.Owner.TNT ) then

		self.Owner:EmitSound( self.Secondary.Sound )
		
		self:DetonateTNT()

	else

		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		
		local vm = self.Owner:GetViewModel()
		if IsValid( vm ) then

			local sequence = vm:LookupSequence( "tnt_throw" )
			vm:SetSequence( sequence )

		end
		
		self.Owner:EmitSound( self.ExtraSounds )

		--timer.Destroy( "ThrowTNT" .. self.Owner:UserID() )
		--timer.Create( "ThrowTNT" .. self.Owner:UserID(), 0.5, 1, self.ThrowTNT, self )
		timer.Simple( 0.5, function() self:ThrowTNT() end )

	end
	
end

function SWEP:ThrowTNT()

	if !IsValid( self ) then return end

	self.Owner:DrawViewModel( false )
	self.Owner:EmitSound( self.Primary.Sound )

	local ent = ents.Create( "tnt" )

	if IsValid(ent) && self.dt.Thrown != true then
	
		self.dt.Thrown = true

		ent:SetPos( self.Owner:GetShootPos() - Vector( 10, 0, 0 ) )
		ent:SetOwner( self.Owner )
		ent:SetTNTOwner( self.Owner )
		ent:SetPhysicsAttacker( self.Owner ) 
		ent:Spawn()
		ent:Activate()

		self.Owner.TNT = ent

		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity( self.Owner:GetVelocity() + ( self.Owner:GetAimVector() * 500 ) )
		end
		
	end

end

function SWEP:DetonateTNT()

	if IsValid( self.Owner.TNT ) then

		self.Owner.TNT:Detonate()
		self.Owner.TNT = nil
		self.dt.Thrown = false

		self:SetWeaponHoldType( self.HoldType )
		self.Owner:StripWeapon( "weapon_tnt" )

	end

	self:Remove()

end

function SWEP:Deploy()

	if CLIENT then return end

	if self:Thrown() then

		if IsValid( self.Owner.TNT ) then

			self.Owner:DrawViewModel( false )

		else

			self.Owner:StripWeapon( "weapon_tnt" )

		end

	else
	
		self.BaseClass.Deploy( self )

		return true
	
	end

end

function SWEP:CanSecondaryAttack() return false end

hook.Add( "PlayerDeath", "RemoveTNT", function( ply ) if IsValid( ply.TNT ) then ply.TNT:Detonate() end end )
hook.Add( "PlayerSilentDeath", "RemoveTNT", function( ply ) if IsValid( ply.TNT ) then ply.TNT:Detonate() end end )
hook.Add( "PlayerDisconnected", "RemoveTNT", function( ply ) if IsValid( ply.TNT ) then ply.TNT:Detonate() end end )