AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	if (not tr.Hit) then
		return
	end

	local ent = ents.Create("gmt_npc_vip")
	ent:SetPos(tr.HitPos + Vector(0, 0, 1))
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:UpdateModel()
	self:SetModel(self.Model)
	--self:SetSubMaterial(1,self.Material)
end

function ENT:AcceptInput(name, activator, ply)
	if name == "Use" and ply:IsPlayer() and ply:KeyDownLast(IN_USE) == false then
		timer.Simple(
			0.0,
			function()
				if not ply:GetNWBool("VIP") then
					ply:SendLua([[Msg2("Please buy VIP to access this store!")]])
					return
				end
				GTowerStore:OpenStore(ply, 29)
			end
		)
	end
end
