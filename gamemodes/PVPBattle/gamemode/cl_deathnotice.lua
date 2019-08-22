local function PlayerKillByPly()
	local victim	= net.ReadEntity()
	local inflictor	= net.ReadString()
	local attacker	= net.ReadEntity()

	if !IsValid( victim ) || !IsValid( attacker ) then return end

	GAMEMODE:AddDeathNotice( attacker:Name(),nil, inflictor, victim:Name(), nil )

end

net.Receive( "PlayerKilledByPlayer", PlayerKillByPly )

local function RecvPlayerKill()
	local victim	= net.ReadEntity()
	local inflictor	= net.ReadString()
	local attacker	= net.ReadString()

	GAMEMODE:AddDeathNotice( victim:Name(), nil, inflictor, attacker, nil )
end

net.Receive( "PlayerKilled", RecvPlayerKill )

local function PlayerKillSelf()
	local victim	= net.ReadEntity()

	if ( !IsValid( victim ) ) then return end

	--GAMEMODE:AddDeathNotice( victim:Name(), nil, nil, nil, nil )
	GAMEMODE:AddDeathNotice( nil, 0, nil, victim:Name(), nil )
end

net.Receive( "PlayerKilledSelf", PlayerKillSelf )

local messagetable = {
	// melee
	weapon_toyhammer	= "%attacker squeaked %victim to death",
	weapon_sword		= "%attacker out skilled %victim in a furious sword duel",
	weapon_pulsesmartpen = "%attacker recorded %victim's death",
	weapon_chainsaw		= "%attacker raped %victim with a chainsaw",

	// pistol
	weapon_neszapper	= "%attacker old skool'd %victim",
	weapon_ragingbull	= "%attacker richocheted %victim",
	weapon_stealthpistol = "%attacker silently assassinated %victim",
	weapon_semiauto		= "%attacker pistol whipped %victim",
	weapon_akimbo		= "%attacker used the mighty akimbo on %victim",

	// smg
	weapon_xm8			= "%attacker tore %victim to shreds using a futuristic gun",
	weapon_thompson		= "%attacker killed %victim in a true gangster fashion",
	weapon_patriot		= "%attacker turned %victim into swiss cheese",

	// shotguns
	weapon_supershotty	= "%attacker blew %victim in half",
	weapon_spas12		= "%attacker pumped %victim full of lead",

	// snipers
	weapon_m1grand		= "%attacker taught %victim how to play COD",
	weapon_sniper		= "%attacker cleverly sniped %victim",

	// grenades
	pvp_glauncher_nade	= "%attacker luckily exploded %victim",
	pvp_glauncher_stickynade = "%attacker turned %victim into a human firework",

	// misc
	pvp_babynade		= "%attacker baby'd %victim into pieces",
	pvp_tripmine		= "%attacker made a mockery out of %victim",
	pvp_bouncynade		= "%attacker burned %victim's rubber",
	pvp_chainsaw		= "%attacker ripped %victim apart with flying chainsaw",

	// special
	weapon_rage			= "%attacker punched the $%&# out of %victim",
	pvp_candycorn		= "%attacker filled %victim with candy",
	suicide				= "%victim couldn't take life any longer",
	fall				= "%victim lost their footing",
}

function GM:AddDeathNotice( Attacker, team1, Inflictor, Victim, team2 )
	local death	= {
		["victim"]	 = Victim,
		["attacker"] = Attacker,
		["weapon"]	 = Inflictor,
	}

	if death.attacker == nil then
		if game.GetMap() == "gmt_pvp_shard01" then
			death.weapon = "fall"
		else
			death.weapon = "suicide"
		end
	end

	local message = messagetable[death.weapon] or "%victim mysteriously died"

	message = string.gsub(message, "%%(%w+)", death)

	if !GTowerChat.Chat then CreateGChat(true) end

	GTowerChat.Chat:AddText(message, Color( 155, 200, 255, 255 ))
end

local death_sound = {
	weapon_neszapper	= Sound("GModTower/pvpbattle/NESZapper/NESKill.wav"),
	weapon_patriot		= Sound("GModTower/pvpbattle/Patriot/PatriotKill.wav"),
	weapon_sword		= Sound("GModTower/pvpbattle/Sword/SwordVKill.wav"),
	weapon_pulsesmartpen	= {Sound("GModTower/pvpbattle/PulseSmartPen/YouGotThat1.wav"), Sound("GModTower/pvpbattle/PulseSmartPen/YouGotThat2.wav"), Sound("GModTower/pvpbattle/PulseSmartPen/YouGotThat3.wav")}
}

function GM:PlayDeathSound( victim, inflictor, attacker )
	local sound = death_sound[inflictor]

	if sound then
		if type(sound) == "table" then
			attacker:EmitSound(table.Random(sound))
		else
			victim:EmitSound(sound)
		end
	end
end

function GM:DrawDeathNotice( x, y )
end
