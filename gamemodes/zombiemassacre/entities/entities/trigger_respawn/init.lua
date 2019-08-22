AddCSLuaFile()

ENT.Base = "base_entity"
ENT.Type = "brush"

/*---------------------------------------------------------
   Name: Initialize
   Desc: First func called. Use to set up your entity
---------------------------------------------------------*/
function ENT:SetBounds(min, max)
    self:SetSolid(SOLID_BBOX)
    self:SetCollisionBounds(min, max)
    self:SetTrigger(true)
end


function ENT:Touch(ply)
    if (!ply:IsPlayer()) then
        return
    end
    
	if ply:Alive() then
        ply:Spawn()
    end
end