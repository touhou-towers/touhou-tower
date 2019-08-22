
AddCSLuaFile("shared.lua")

local LimbTree = {}
LimbTree[0] = {}
LimbTree[1] = {"ValveBiped.Bip01_Head1"}
LimbTree[2] = {}
LimbTree[3] = {}
LimbTree[4] = {"ValveBiped.Bip01_L_UpperArm", "ValveBiped.Bip01_L_Forearm", "ValveBiped.Bip01_L_Hand"}
LimbTree[5] = {"ValveBiped.Bip01_R_UpperArm", "ValveBiped.Bip01_R_Forearm", "ValveBiped.Bip01_R_Hand"}
LimbTree[6] = {"ValveBiped.Bip01_L_Thigh", "ValveBiped.Bip01_L_Calf", "ValveBiped.Bip01_L_Foot"}
LimbTree[7] = {"ValveBiped.Bip01_R_Thigh", "ValveBiped.Bip01_R_Calf", "ValveBiped.Bip01_R_Foot"}
LimbTree[10] = {}

LimbTree[100] = {"ValveBiped.Bip01_pelvis",
				"ValveBiped.Bip01_L_Thigh",
				"ValveBiped.Bip01_L_Calf",
				"ValveBiped.Bip01_L_Foot",
				"ValveBiped.Bip01_R_Thigh",
				"ValveBiped.Bip01_R_Calf",
				"ValveBiped.Bip01_R_Foot"}

LimbTree[101] = {
			    "ValveBiped.Bip01_Spine2",
			    "ValveBiped.Bip01_Spine",
				"ValveBiped.Bip01_Head1",
				"ValveBiped.Bip01_L_Forearm",
				"ValveBiped.Bip01_L_UpperArm",
				"ValveBiped.Bip01_L_Hand",
				"ValveBiped.Bip01_R_Forearm",
				"ValveBiped.Bip01_R_UpperArm",
				"ValveBiped.Bip01_R_Hand"}

local charedModel = Model("models/Humans/Group01/Male_04.mdl")

local charedMat = "models/charple/charple2_sheet"

if SERVER then
	function PlayerTraceAttack( ply, dmginfo, dir, tr )
	local effectdata = EffectData()
		effectdata:SetOrigin( tr.HitPos )
		effectdata:SetNormal( tr.HitNormal )
		effectdata:SetScale( 1.2 )
		util.Effect( "bloodcloud", effectdata, true, true )
	end
	hook.Add("PlayerTraceAttack","hitMod",PlayerTraceAttack)

	local function HitGroup( pl, hitgroup, dmginfo )
		if(dmginfo:IsExplosionDamage()) then
		elseif(dmginfo:IsFallDamage()) then
		else
			pl:SetNWInt("lastHit",hitgroup)
		end
	end
	hook.Add("ScalePlayerDamage", "HitGroupCheck", HitGroup)

	local function ResetHitGroup(pl)
		pl:SetNWInt("lastHit",HITGROUP_GENERIC)
		pl:SetMaterial("")
	end
	hook.Add("PlayerSpawn", "ResetHitGroup", ResetHitGroup)

	function CheckPlayerDeath( pl, attacker, dmginfo )
		local z = (dmginfo:GetDamagePosition().z - pl:GetPos().z)
		if(dmginfo:IsExplosionDamage()) then
			pl:SetMaterial(charedMat)
			--pl:SetModel(charedModel)
			if(z < 50) then
				pl:SetNWInt("lastHit",100)
			else
				pl:SetNWInt("lastHit",101)
			end
		elseif(dmginfo:IsFallDamage()) then
			pl:SetNWInt("lastHit",100)
		end
	end
	hook.Add("DoPlayerDeath", "CheckPlayerDeath", CheckPlayerDeath)
else
	local MatChar = Material("models/charple/charple2_sheet")

	local btime = CurTime()
	local function ScaleBone(ent,boneid,amount)
		local matBone = ent:GetBoneMatrix( boneid )
		if matBone != nil then
			matBone:Scale( Vector( amount, amount, amount ) )
			ent:SetBoneMatrix( boneid, matBone )
		end
	end

	local function LimbMod(pl)
		local lastHit = pl:GetNWInt("lastHit")
		local baseLimb = -1
		local function DoBoneManipulation(self)
			for k,v in pairs(LimbTree[lastHit]) do
				local limb = self:LookupBone( v );
				if(lastHit != 100 or k > 2) then
					ScaleBone(self,limb,0);
				end
			end
			--ScaleBone(self,body,.7);
		end
		if(lastHit != nil) then
			--pl.BuildBonePositions = DoBoneManipulation
			local rag = pl:GetRagdollEntity()
			if(rag != nil and rag:IsValid()) then
				rag["bleedTime"] = rag["bleedTime"] or CurTime() + 6
				if(lastHit == 100 or lastHit == 101) then
					rag:SetMaterial(charedMat)
				end
				rag.BuildBonePositions = DoBoneManipulation;
				if(LimbTree[lastHit][1] != nil) then
					baseLimb = rag:LookupBone(LimbTree[lastHit][1]);
				end
				if(baseLimb != -1) then
				local matBone = rag:GetBoneMatrix( baseLimb )
					if(matBone != nil and rag["bleedTime"] > CurTime()) then
						local amt = (rag["bleedTime"] - CurTime())/6
						local bPos = matBone:GetTranslation()
						local norm = (rag:GetPos() - bPos)*-1
						local effectdata = EffectData()
						effectdata:SetOrigin( bPos + Vector(math.random(-4,4),math.random(-4,4),math.random(-4,4)) )
						effectdata:SetNormal( norm )
						effectdata:SetScale( 1.3*(amt+.5) )
						util.Effect( "bloodcloud", effectdata, true, true )
						btime = CurTime() + math.Rand(.01,.1)
					end
				end
			end
		end
	end

	function checkForModables()
		for k,v in ipairs(player.GetAll()) do
			if(v != nil and v:IsValid()) then
				LimbMod(v)
			end
		end
	end
	hook.Add("Think", "CheckMods", checkForModables)
end
