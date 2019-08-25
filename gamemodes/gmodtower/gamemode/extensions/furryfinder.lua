-- All the beautifully wonderful functions for our patent pending Furry Finder

RegisterNWTablePlayer({{"IsFur", false, NWTYPE_BOOL, REPL_EVERYONE}})

local meta = FindMetaTable("Player")
if not meta then
	Msg("ALERT! Could not hook Player Meta Table\n")
	return
end

function meta:IsFurry()
	if (self.IsFur or self:IsDigi()) then
		return true
	end

	local rab = self:GetRabbit()
	local skin = self:GetSkin()

	if rab == 2 or rab == 3 then
		if rab == 2 then
			return (skin == 15 or skin == 24) -- lucario || pikachu
		end

		if rab == 3 then
			return (skin == 15 or skin == 16 or skin == 20) -- digi || renamon
		end
	end

	return false
end

function meta:GetRabbit()
	local model = self:GetModel()

	if model == "models/player/redrabbit2.mdl" then
		return 2
	elseif model == "models/player/redrabbit3.mdl" then
		return 3
	end

	return 0
end

function meta:IsDigi()
	return self:GetModel() == "models/player/digi.mdl"
end

function meta:IsFoohy()
	return false
	-- return self:SteamID() == "SEAM_0:1:18712009"
end

if CLIENT then
	return
end

-- purge the furries
FurryGroups = {
	"103582791430242178", -- furry antics
	"103582791429527670", -- furry pride
	"103582791429947798", -- nuzzlefuzzle
	"103582791429522274", -- furries united
	"103582791429606241", -- furaffinity gamers
	"103582791429956274", -- the furry pound
	"103582791429644144", -- gamer furs
	"103582791430397056", -- furry ravers
	"103582791429530109", -- [furry]
	"103582791429640685", -- happy to be a furry
	"103582791431072182", -- ultimate furry squad
	"103582791431250075", -- world wide furries
	"103582791430192181", -- fursomnia
	"103582791431309923", -- fur code zero
	"103582791429523337", -- uk furries
	"103582791429567549", -- tf2 - furs
	"103582791429738950", -- second life furrys
	"103582791429927213", -- the pit furry community
	"103582791430184966", -- overgrowth (yeah, thats right)
	"103582791431013620", -- alone wolf
	"103582791429535282", -- the furry fandom
	"103582791431145679", -- fennec fox
	"103582791430960988" -- furry tranquility
}

hook.Add(
	"PlayerAuthed",
	"FurryFinderAuthed",
	function(ply, steamid, uniqueid)
		ply:RequestGroupStatus(FurryGroups)
	end
)

local function FindPlayerBySteamID(steamid)
	for _, v in ipairs(player.GetAll()) do
		if (IsValid(v) and v:SteamID() == steamid) then
			return v
		end
	end
end

hook.Add(
	"GSGroupStatus",
	"FurryGroupStatus",
	function(steamUser, steamGroup, isMember, isOfficer)
		local ply = FindPlayerBySteamID(steamUser)

		if not IsValid(ply) then
			return
		end
		if not table.HasValue(FurryGroups, steamGroup) then
			return
		end

		if (isMember or isOfficer) then
			ply.IsFur = true
		end
	end
)
