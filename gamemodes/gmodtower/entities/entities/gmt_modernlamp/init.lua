
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()
	self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	self:DrawShadow( false )

	local phys = self.Entity:GetPhysicsObject()
	if phys then
		phys:Wake()
	end
end


function ENT:Use( ply, caller )
	self.IsOn = !self.IsOn
	self:ToggleLamp(RecipientFilter():AddAllPlayers())
end

function ENT:ToggleLamp(rp) --Updates the player(s) with the new status
	umsg.Start("ToggleLamp", rp)
		umsg.Entity(self.Entity)
		umsg.Bool(self.IsOn)
	umsg.End()
end

hook.Add("PlayerInitialSpawn", "GMTLanternToggle", function(ply)
		local lamps = ents.FindByClass("gmt_modernlamp")
		if #lamps > 0 then
			for _, ent in ipairs(lamps) do
				if IsValid(ent) then ent:ToggleLamp(ply) end
			end
		end
	end)
