local LocationBattle = 3

concommand.Add("gmtpvp_model", function( ply, cmd, args )
	if tonumber( args[1] ) == 0 then
		ply._ChosenPVPModel = 0
	else
		ply._ChosenPVPModel = 1
	end	
end )

concommand.Add("gmt_stopgame", function( ply, cmd, args )
	hook.Remove("Location","RemoveWeapons")
	hook.Remove("ShouldCollide", "LobbyColide")
	for _, v in pairs( player.GetAll() ) do
		v:StripWeapons()
		v:SendLua('hook.GetTable().ShouldCollide.a=nil')
	end
end )

local function SetRabbit( ply )
	ply:SetModel("models/player/redrabbit.mdl") 
	ply:SetSkin((ply:SQLId()%4)+1)
	GTowerModels:SetTemp(ply,0.55)
end

local function GiveSword( ply )
	if ply:IsAdmin() then return end

	local wep = ply:FindInInv( ITEMS.weapon_sword )
	if wep then ply:ForceItem( wep, nil ) end
	ply:Give("weapon_sword")
	ply:SelectWeapon("weapon_sword")
	
	/*if ply._ChosenPVPModel then
		if ply._ChosenPVPModel == 0 then
			ply:SetModel("models/player/Group01/cookies114.mdl")
		else
			SetRabbit( ply )
		end
	else
		if math.random(0,1) > 0.5 then
			ply:SetModel("models/player/Group01/cookies114.mdl")
		else
			SetRabbit( ply )
		end
	end*/
	SetRabbit( ply )
	
	ply:SendLua('hook.Add("ShouldCollide", "a", function(a,b) if a.GLocation == '..LocationBattle..' || b.GLocation == '..LocationBattle..' then return true end end )')
end

hook.Add("Location","RemoveWeapons", function( ply, loc )
	if loc != LocationBattle then
		ply:StripWeapons()
	else
		GiveSword( ply )
	end
end )

hook.Add("ShouldCollide", "LobbyColide", function( a, b )
	if a.GLocation == LocationBattle || b.GLocation == LocationBattle then
		return true
	end
end )

for _, v in pairs( player.GetAll() ) do
	if v.GLocation == LocationBattle then
		GiveSword( v )
	else
		v:StripWeapons()
	end
end