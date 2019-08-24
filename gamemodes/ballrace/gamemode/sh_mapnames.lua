NiceMapNames = {
	["gmt_ballracer_grassworld01"] = "Grass World",
	["gmt_ballracer_iceworld03"] = "Ice World",
	["gmt_ballracer_khromidro02"] = "Khromidro",
	["gmt_ballracer_memories04"] = "Memories",
	["gmt_ballracer_metalworld"] = "Metal World",
	["gmt_ballracer_midori"] = "Midori",
	["gmt_ballracer_neonlights"] = "Neon Lights",
	["gmt_ballracer_nightball"] = "Night World",
	["gmt_ballracer_paradise03"] = "Paradise",
	["gmt_ballracer_prism03"] = "Prism",
	["gmt_ballracer_rainbowworld"] = "Rainbow World",
	["gmt_ballracer_sandworld02"] = "Sand World",
	["gmt_ballracer_skyworld01"] = "Sky World",
	["gmt_ballracer_spaceworld"] = "Space World",
	["gmt_ballracer_summit"] = "Summit",
	["gmt_ballracer_waterworld"] = "Water World",
	["gmt_ballracer_waterworld02"] = "Water World"
}

function GetNiceMapName(map)
	local map = map or game.GetMap()
	return NiceMapNames[map] or map
end
