
GtowerAchivements:Add( ACHIVEMENTS.HUMANBLUR, {
	Name = "Human Blur",
	Description = "Fall from the top of the lobby.",
	Value = 1,
	GiveItem = "trophy_humanblur"
})

--[[hook.Add("EntityTakeDamage", "CheckHumanBlur", function( ply, dmginfo )
	local attacker = dmginfo:GetAttacker()
	local inf = dmginfo:GetInflictor()
	local amount = dmginfo:GetDamage()

	if Location && ply:IsPlayer() && dmginfo:IsFallDamage() then
		if (ply:LastLocation() == 43 || GTowerLocation:GetPlyLocation( ply ) == 43) && ply:Location( true ) == 2 then
			ply:SetAchivement( ACHIVEMENTS.HUMANBLUR, 1 )
		end
	end

end )]]

hook.Add("OnPlayerHitGround", "CheckHumanBlur", function( ply, inWater, onFloater, speed )

	if (ply.GLocation == 2 && ply.GLastLocation == 43) then
		ply:SetAchivement( ACHIVEMENTS.HUMANBLUR, 1 )
	end

end )
