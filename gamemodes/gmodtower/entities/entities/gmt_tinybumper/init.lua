
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/gmod_tower/bumper.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetTrigger(true)

	self:DrawShadow(false)

	self:SetModelScale(0.25,0.75)


end

function ENT:Use(eOtherEnt)
	  if(self.Wait) then return end
		self.Wait = true
		timer.Simple(2.5, function() self.Wait = false
		end)
		self:SetUseType( SIMPLE_USE )
		self:Bump()
		local edata = EffectData()
		edata:SetOrigin( self:GetPos() )
		util.Effect( "ball_hit", edata )
end
