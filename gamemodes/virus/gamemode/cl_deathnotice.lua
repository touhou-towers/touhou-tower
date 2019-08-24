local Deaths = {}

local function RecvPlayerKilledByPlayer()
	local victim = net.ReadEntity()
	local inflictor = net.ReadString()
	local attacker = net.ReadEntity()

	if (not IsValid(attacker)) then
		return
	end
	if (not IsValid(victim)) then
		return
	end

	GAMEMODE:AddDeathNotice(attacker:Name(), attacker:Team(), inflictor, victim:Name(), victim:Team())
end
net.Receive("PlayerKilledByPlayer", RecvPlayerKilledByPlayer)

local function RecvPlayerKilledSelf()
	local victim = net.ReadEntity()
	if (not IsValid(victim)) then
		return
	end
	GAMEMODE:AddDeathNotice(nil, 0, "suicide", victim:Name(), victim:Team())
end
net.Receive("PlayerKilledSelf", RecvPlayerKilledSelf)

local function RecvPlayerKilled()
	local victim = net.ReadEntity()
	if (not IsValid(victim)) then
		return
	end
	local inflictor = net.ReadString()
	local attacker = "#" .. net.ReadString()

	GAMEMODE:AddDeathNotice(attacker, -1, inflictor, victim:Name(), victim:Team())
end
net.Receive("PlayerKilled", RecvPlayerKilled)

local messagetable = {
	-- pistol
	weapon_9mm = "%attacker killed %victim with a 9mm",
	weapon_silencers = "%attacker permanently silenced %victim",
	weapon_flakhandgun = "%attacker filled %victim's body with flak",
	weapon_scifihandgun = "%attacker ended %victim's life with a well placed laser shot",
	-- rifles
	weapon_plasmaautorifle = "%attacker melted %victim with plasma",
	weapon_rcp120 = "%attacker gunned down %victim",
	weapon_tommygun = "%attacker killed %victim in a true gangster fashion",
	-- shotguns
	weapon_doublebarrel = "%attacker pumped %victim full of lead",
	weapon_sonicshotgun = "%attacker blew %victim away",
	-- special
	tnt = "%attacker blew %victim up",
	weapon_sniperrifle = "%attacker sniped %victim",
	-- unknown
	suicide = "%victim couldn't take life any longer"
}

function GM:AddDeathNotice(Attacker, team1, Inflictor, Victim, team2)
	local death = {}

	death.victim = Victim
	death.attacker = Attacker
	death.weapon = Inflictor

	if death.attacker == nil then
		death.weapon = "suicide"
	end

	local message = messagetable[death.weapon] or "%victim mysteriously died"

	message = string.gsub(message, "%%(%w+)", death)

	table.insert(Deaths, death)

	self:PrintChat(message, Color(155, 200, 255))
end

function GM:PrintChat(message, color)
	if not GTowerChat.Chat then
		CreateGChat(true)
	end

	GTowerChat.Chat:AddText(message, color)
end

function GM:DrawDeathNotice(x, y)
end
