
AddCSLuaFile("shared.lua")

// this will re-position CS:S weapons to a bearable position

hook.Add("PostPlayerDraw", "CSSWeaponFix", function(v)
	local wep = v:GetActiveWeapon()
	if !IsValid(wep) then return end

	local hbone = wep:LookupBone("ValveBiped.Bip01_R_Hand")
	if !hbone then
		local hand = v:LookupBone("ValveBiped.Bip01_R_Hand")
		local pos, ang = v:GetBonePosition(hand)

		ang:RotateAroundAxis(ang:Forward(), 180)

		if wep:GetModel() == "models/weapons/w_pvp_neslg.mdl" then
			ang:RotateAroundAxis(ang:Up(), -90)
		end

		wep:SetRenderOrigin(pos)
		wep:SetRenderAngles(ang)
	end
end)