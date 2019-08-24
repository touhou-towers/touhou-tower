GM.Name = "GMod Tower"
GM.Author = "GMod Tower Team"
GM.Website = "http://www.gmtower.org/"
GM.AllowSpecialModels = true
GM.AllowEquippables = true
GM.AllowJetpack = true

DeriveGamemode("gmodtower")

TowerModules.LoadModules(
	{
		"achivement",
		"auction",
		"ambiance",
		"bonemod",
		"cards",
		"friends",
		"streams",
		"group",
		"hacker",
		"datareset",
		"racing",
		"devhq",
		"inventory",
		"duel",
		"npc_chat",
		"errortrace",
		"room",
		"ping",
		--"emote",
		"holidays",
		"scoreboard3",
		--"scoreboard3",
		"store",
		"multiserver",
		"location",
		"seats",
		"gibsystem",
		"weaponfix",
		--"theater",
		"commands",
		"afk2",
		"tour",
		"soundbrowser",
		"bassemitstream",
		"ragdollcontroller",
		"thirdperson",
		"infoboard",
		"advertisement",
		"jetpack",
		"animation",
		"pet", -- awwww... what cute pets!
		"emote",
		"vipglow",
		"legs"
		--"steamgroups", // The Final Solution
	}
)

local function PlayerPickup(ply, ent)
	if (ply:IsAdmin() and ent:GetClass():lower() == "player") then
		return true
	end
end
hook.Add("PhysgunPickup", "Allow Player Pickup", PlayerPickup)

hook.Add(
	"GTowerPhysgunPickup",
	"NoFuncForFun",
	function(ply, ent)
		local Class = ent:GetClass()
		return string.sub(Class, 1, 5) ~= "func_" and string.sub(Class, 1, 10) ~= "prop_door_"
	end
)

function GM:ShouldCollide(ent1, ent2)
	if ent1:GetClass() == "gmt_golfball" and ent2:IsPlayer() then
		return false
	end

	if ent1:IsPlayer() and ent2:GetClass() == "gmt_golfball" then
		return false
	end

	if ent1.ActiveDuel and ent2.ActiveDuel then
		return true
	end
	return not (ent1:IsPlayer() and ent2:IsPlayer())
end

function GM:OnPlayerHitGround(ply, inWater, onFloater, speed)
	return true
end

hook.Add(
	"KeyPress",
	"SuiteDoorE",
	function(ply, key)
		if CLIENT then
			return
		end
		if (key == IN_USE) then
			local ent = ply:GetEyeTrace().Entity
			if (ent and ent:GetClass() == "func_door_rotating") then
				if (ent:GetPos():Distance(ply:GetPos()) < 100) then
					for k, v in pairs(ents.FindInSphere(ent:GetPos(), 50)) do
						if v:GetClass() == "func_suitepanel" then
							for _, ply in pairs(player.GetAll()) do
								if ply.GRoom then
									if (ply.GRoom.Id == v.RoomId) then
										ent:Fire("Open", "")
									end
								end
							end
						end
					end
				end
			elseif (ent and ent:GetClass() == "prop_physics_multiplayer") then
				for k, v in pairs(GTowerItems.Items) do
					if (ent:GetModel() == v.Model and v.UseSound) then
						if ent.SoundDelay then
							return
						end
						ent:EmitSoundInLocation("GModTower/inventory/" .. v.UseSound, 60)
						ent.SoundDelay = true
						timer.Simple(
							2,
							function()
								ent.SoundDelay = false
							end
						)
					end
				end
			end
		end
	end
)
