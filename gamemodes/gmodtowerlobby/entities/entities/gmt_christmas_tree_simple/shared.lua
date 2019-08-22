
-----------------------------------------------------
AddCSLuaFile("shared.lua")

ENT.Base		= "gmt_christmas_tree"
ENT.Type		= "anim"
ENT.PrintName	= "Christmas Tree Simple"

ENT.Model		= Model( "models/wilderness/hanukkahtree.mdl" )

if SERVER then
	function ENT:Initialize()

		self:SetModel( self.Model )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		local phys = self:GetPhysicsObject()
		if IsValid( phys ) then
			phys:EnableMotion(false)
		end

	end

	function ENT:OnRemove()
	end

else // CLIENT

	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:Think()
	end

end