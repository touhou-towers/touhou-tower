NiceMapNames={}

NiceMapNames["gmt_ballracer_grassworld01"] = "Grass World";
NiceMapNames["gmt_ballracer_iceworld03"] = "Ice World";
NiceMapNames["gmt_ballracer_khromidro02"] = "Khromidro";
NiceMapNames["gmt_ballracer_memories04"] = "Memories";
NiceMapNames["gmt_ballracer_metalworld"] = "Metal World";
NiceMapNames["gmt_ballracer_midori"] = "Midori";
NiceMapNames["gmt_ballracer_neonlights"] = "Neon Lights";
NiceMapNames["gmt_ballracer_nightball"] = "Night World";
NiceMapNames["gmt_ballracer_paradise03"] = "Paradise";
NiceMapNames["gmt_ballracer_prism03"] = "Prism";
NiceMapNames["gmt_ballracer_rainbowworld"] = "Rainbow World";
NiceMapNames["gmt_ballracer_sandworld02"] = "Sand World";
NiceMapNames["gmt_ballracer_skyworld01"] = "Sky World";
NiceMapNames["gmt_ballracer_spaceworld"] = "Space World";
NiceMapNames["gmt_ballracer_summit"] = "Summit";
NiceMapNames["gmt_ballracer_waterworld"] = "Water World";
NiceMapNames["gmt_ballracer_waterworld02"] = "Water World";

function GetNiceMapName(map)
	local map = map or game.GetMap();
	if NiceMapNames[map] then
		return NiceMapNames[map]
	else
		return map
	end
end