AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/gmod_tower/headheart.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)

	self:DrawShadow(false)

	self:SetTrigger(true)

	self:DrawShadow(false)
	--self:SetPos(self:GetPos() + Vector(0,0,10))

end

function ENT:Use(eOtherEnt)
	if eOtherEnt:IsPlayer() then
	  if(self.Wait) then return end
		self.Wait = true
		timer.Simple(30, function() self.Wait = false
		end)
		self:SetUseType( SIMPLE_USE )
		self:EmitSoundInLocation("GModTower/pvpbattle/headphoneson.mp3" , 65 )
		timer.Create("MusicNotes",0.25,120,function()
			if IsValid(self) then
			local edata = EffectData()
			edata:SetOrigin(self:GetPos())
			edata:SetScale(3)
			util.Effect( "musicnotes", edata, true, true )
			end
		end)
	end
end
