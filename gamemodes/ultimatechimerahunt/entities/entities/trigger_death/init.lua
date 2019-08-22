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
    
    if ply == GetGlobalEntity("UC") then
        local spawns = ents.FindByClass("chimera_spawn")
        local respawn = spawns[math.random(#spawns)]
        ply:SetPos(respawn:GetPos() + Vector(0,0,100))
        ply:SetEyeAngles(respawn:GetAngles())
        ply:SetVelocity(ply:GetVelocity() * -1)
        ply:Stun()
    elseif ply:Alive() && ply:Team() == TEAM_PIGS && GAMEMODE:GetGameState() == STATUS_PLAYING then
        ply:Kill()
    end
end