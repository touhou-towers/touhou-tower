surface.CreateFont("ScoreboardSub", {font = "coolvetica", size = 22, weight = 500, antialias = true, additive = false})
local sw, sh = ScrW(), ScrH()
local PANEL = {}

function PANEL:Init() end

local function GetNiceMapName( map )

	if !map || !GAMEMODE.NiceMapNames then return "Unknown Map" end

	return GAMEMODE.NiceMapNames[map] or map

end

function PANEL:PerformLayout()

	local txt = GetNiceMapName( game.GetMap() )

	surface.SetFont( "ScoreboardSub" )
	local w, h = surface.GetTextSize( txt )

	self:SetSize( w * 1.32, h )

end

function PANEL:Paint()
	
	local w, h = self:GetSize()
	draw.RoundedBox( 0, 0, 0, w, h, Color( 25, 25, 25, 100 ) )

	local txt = GetNiceMapName( game.GetMap() )
	GAMEMODE:DrawNiceText( txt, "ScoreboardSub", w * .5, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, 250 )

end

vgui.Register( "UCMapName", PANEL, "Panel" )