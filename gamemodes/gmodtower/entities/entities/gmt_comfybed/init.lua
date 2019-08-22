
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel( "models/gmod_tower/comfybed.mdl" )

	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow(true)

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion( false )
	end

	self.HealingPlayers = {}
end

function ENT:HealingThink()
	for ply, time in pairs( self.HealingPlayers ) do
		if !IsValid( ply ) then
			self.HealingPlayers[ ply ] = nil
		elseif !ply:Alive() then
			self:WakePlayer( ply )
		elseif CurTime() > time then
			local Health = math.min( ply:Health() + 1, 100 )

			ply:Extinguish()
			ply:SetHealth( Health )
			ply:EmitSound( self.HealSound )

			if Health >= 100 then
				self:WakePlayer( ply )
			else
				self.HealingPlayers[ ply ] = CurTime() + 0.08
			end
		end
	end

	if table.Count( self.HealingPlayers ) == 0 then
		self.Think = EmptyFunction
	end
end

function ENT:WakePlayer( ply )
	PostEvent( ply, "sleepoff" )
	ply:Freeze( false )
	ply:DrawWorldModel( true )

	self.HealingPlayers[ ply ] = nil
end

function ENT:Use( ply )
	if !ply:IsPlayer() then return end

	PostEvent( ply, "sleepon" )
	ply:Freeze( true )
	ply:EmitSound( self.SleepSound )

	ply:UnDrunk()
	self.HealingPlayers[ ply ] = CurTime() + 4.0
	self.Think = self.HealingThink
end

function ENT:OnRemove()
	for ply, time in pairs( self.HealingPlayers ) do
		self:WakePlayer( ply )
	end
end
