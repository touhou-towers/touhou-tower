
local meta = FindMetaTable( "Player" )
if !meta then
	return
end

function meta:IsPrivAdmin()
	return self:IsUserGroup("privadmin") or self:IsAdmin()
end

function meta:IsSecretAdmin()
	return self:IsUserGroup("secretadmin")
end

function meta:IsDeveloper()

	return self:IsUserGroup( "developer" ) || self:IsUserGroup( "superadmin" )

end

local Tester =
{
}


// Funny Poop
local PixelTail =
{
	"STEAM_0:1:19359297", -- Wergulz, GMT Artist.
	"STEAM_0:1:11414156", -- Lifeless, GMT Mapper.
	"STEAM_0:0:25019928", -- Matt, GMT Mapper.
	"STEAM_0:1:18712009", -- Foohy, GMT Programmer and cool dude.
	"STEAM_0:1:5893683", -- Zak, GMT Programmer.
	"STEAM_0:1:15862026", -- Sam, GMT/Mediaplayer Programmer.
	"STEAM_0:1:6044247",	-- MacDGuy, Owner of PixelTail and Sociopath
	"STEAM_0:0:6807675", -- Johanna
	"STEAM_0:0:18456733", -- Noodleneck
	"STEAM_0:1:8932293", -- Massaki
	"STEAM_0:0:4872668", -- Plasma
}

local Owner = {
}	

local Developer = {
}

local Admin = {
}
local Admin2 = {
}
local Mod =
{
}

function meta:GetTitle()
	local Titles = {}

	for k,v in pairs(PixelTail) do Titles[v] = "Original GMT Staff" end
	for k,v in pairs(Admin) do Titles[v] = "Admin" end
	for k,v in pairs(Admin2) do Titles[v] = "Admin" end
	for k,v in pairs(Owner) do Titles[v] = "Host" end
	for k,v in pairs(Developer) do Titles[v] = "Developer" end
	for k,v in pairs(Mod) do Titles[v] = "Moderator" end

	if Titles[self:SteamID()] then return Titles[self:SteamID()] end

	if self:GetNWBool('VIP') then return "Tower Unite Owner" end

end

local color_admin = Color(255, 100, 100, 255)
local color_admin2 = Color(255, 110, 238, 255)
local color_lead = Color(248, 18, 128, 255)
local color_mod = Color(255, 128, 0, 255)
local color_developer = Color(125, 177, 30, 255)
local color_vip = Color(185, 100, 255, 255)
local color_pink = Color(255, 166, 241, 255)
local color_tester = Color(122, 178, 342, 255 )
local color_pixeltail = Color( 216, 31, 42, 255 )


function meta:GetDisplayTextColor()

	if table.HasValue(Mod,self:SteamID()) then
		return color_mod
	elseif table.HasValue(Admin,self:SteamID()) then
		return color_admin
	elseif table.HasValue(Admin2,self:SteamID()) then
		return color_admin2
	elseif table.HasValue(Owner,self:SteamID()) then
		return color_lead
	elseif table.HasValue(Developer,self:SteamID()) then
		return color_developer
	elseif table.HasValue(Tester,self:SteamID()) then
		return color_tester
	elseif table.HasValue(PixelTail,self:SteamID()) then
		return color_pixeltail
	elseif self:GetNWBool('VIP') then 
		return color_vip 
	end

	return team.GetColor( self:Team() )

end

function meta:IsCameraOut()
	return IsValid( self:GetActiveWeapon() ) && self:GetActiveWeapon():GetClass() == "gmt_camera"
end
