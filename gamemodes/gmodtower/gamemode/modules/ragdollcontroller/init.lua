
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local rag, metaPlayer = {}, FindMetaTable("Player")

hook.Add("PlayerDisconnected", "GMTRagdollDisconnect", function(ply) if ply:IsRagdoll() then rag:removeRagdoll(ply) end end)
hook.Add("PlayerDeath", "GMTRagdollDeath", function(vic, inf, killer) if vic:IsRagdoll() then rag:removeRagdoll(vic) end end)
hook.Add("PlayerSilentDeath", "GMTRagdollDeath", function(vic, inf, killer) if vic:IsRagdoll() then rag:removeRagdoll(vic) end end)
hook.Add("PlayerDeathThink", "GMTRagdollDeath", function(vic, inf, killer) if vic:IsRagdoll() then return false end end)

function metaPlayer:GetRagdollEnt()
	return self.Ragdoll
end

function rag:removeRagdoll(ply)
	if !IsValid(ply) || !IsValid(ply.Ragdoll) then return end

	ply:UnSpectate()
	ply:Spawn()
	ply:SetPos(ply.Ragdoll:GetPos())
	ply:SetAFKExcluded(false)
	ply.Ragdoll:Remove()
	ply.Ragdoll = nil

	/*umsg.Start("FunRagdoll", ply)
		umsg.Entity(nil)
	umsg.End()*/
end

function rag:ragdollPlayer(ply, isRagdoll, admin)
	if !IsValid(ply) then return end
	if ply:IsAdmin() && ply != admin then return end
	if ply:GetModel() == "models/gmod_tower/obamacutout.mdl" then return end  //Saving Private Foohy

	if isRagdoll then
		if ply.Ragdoll then return end
		/*ply:MsgT( "AdminRagdoll", admin:GetName() )
		admin:MsgT( "AdminRagdollA", ply:GetName() )*/

		ply:KillSilent() -- Must be done first.
		ply.Ragdoll = ents.Create("prop_ragdoll")
		ply.Ragdoll:SetModel(ply:GetModel())
		ply.Ragdoll:SetPos(ply:GetPos())
		ply.Ragdoll:SetSkin(ply:GetSkin())
		ply.Ragdoll:SetOwner(ply)
		ply.Ragdoll:Spawn()
		ply.Ragdoll:Activate()

		local phys = ply.Ragdoll:GetPhysicsObject()
		if IsValid( phys ) then
			phys:Wake()
		end

		/*timer.Simple(.1, function()
			umsg.Start("FunRagdoll", ply)
				print(ply.Ragdoll)
				umsg.Entity(ply.Ragdoll)
			umsg.End()
		end)*/
		
		ply.Ragdolled = true

		ply:Spectate(OBS_MODE_CHASE)
		ply:SpectateEntity(ply.Ragdoll)
		ply:SetAFKExcluded(false)
	else
		if !ply.Ragdoll then return end
		ply.Ragdolled = false
		rag:removeRagdoll(ply)
	end
end


concommand.Add("gmt_ragdoll", function(ply, cmd, args)

	if !( ply:IsSuperAdmin() || ply:GetSetting( "GTAllowRagdoll" ) ) then return end

	rag:ragdollPlayer( ply, !ply.Ragdolled, ply )

	//ply:ConCommand("-attack")
	/*if args[1] then
		target = args[1]
			
		for _, v in ipairs(player.GetAll()) do
			if string.find(v:GetName(), target, 1, true) then target = v break end
		end

		if type(target) != "string" then
			rag:ragdollPlayer(target, !target.Ragdolled, ply)
			return
		end
	else
		local target = ply:GetEyeTrace().Entity
		if IsValid(target) then
				
			if target:IsPlayer() then
				rag:ragdollPlayer(target, !target.Ragdolled, ply)
				return
			elseif target:GetClass() == "prop_ragdoll" and target:GetOwner() then
				rag:ragdollPlayer(target:GetOwner(), false)
				return
			end
				
		end
	end

	ply:PrintMessage(HUD_PRINTCONSOLE, "Invalid player")*/

end)