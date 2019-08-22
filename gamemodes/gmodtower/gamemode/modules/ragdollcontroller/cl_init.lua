
include("shared.lua")

hook.Add("CalcView", "GMTRagdollEyes", function(ply, pos, ang, fov)

		if IsValid(LocalPlayer().Ragdoll) then
			local att = LocalPlayer().Ragdoll:GetAttachment(LocalPlayer().Ragdoll:LookupAttachment("eyes"))
			
			return {["origin"] = att.Pos, ["angles"] = att.Ang}
		end
		
		--return GAMEMODE:CalcView(ply, pos, ang, fov)
	end)

usermessage.Hook("FunRagdoll", function(um)
		
		LocalPlayer().Ragdoll = um:ReadEntity()
	end)
