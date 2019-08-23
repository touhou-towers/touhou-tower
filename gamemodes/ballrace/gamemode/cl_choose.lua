--[[
	this file is the ball picker for ball race
]]
surface.CreateFont( "GTowerHUDMainSmall", { font = Oswald, size = 14, weight = 400 } )

pick_ball = CreateClientConVar( "selected_ball", "1", true, false )

BallRacerChooser = {}
BallRacerChooser.GUI = nil

-- none of these models actually exist since the files were taken down
local EachHeight = 80
local AllowCube = false
local AllowIcosahedron = false
local AllowCatBall = false
local AllowSoccerBall = false
local AllowGeo = false
local AllowBomb = false
local AllowSpiked = false
local AllowBallion = false

local ChosenId = cookie.GetNumber( "GMTChosenBall", 1 )

function BallRacerChooser:Open()
	self:Close()

	self.GUI = vgui.Create("DPanel")
	self.GUI.Paint = function( panel, w, h )
		surface.SetDrawColor( 0,0,0, 230 )
		surface.DrawRect( 0, 0, w, h )
	end

	local ModelPanels = {}

	local Panel = self:GetPanel( "models/gmod_tower/BALL.mdl", 1, "Normal" )
	table.insert( ModelPanels, Panel )

	if AllowCube then
		local Panel = self:GetPanel( "models/gmod_tower/cubeball.mdl", 2, "Cube", Vector( 80, 80, 80 ) )
		table.insert( ModelPanels, Panel )
	end

	if AllowIcosahedron then
		local Panel = self:GetPanel( "models/gmod_tower/icosahedron.mdl", 3, "Icosahedron" )
		table.insert( ModelPanels, Panel )
	end

	if AllowCatBall then
		local Panel = self:GetPanel( "models/gmod_tower/catball.mdl", 4, "Cat Orb" )
		table.insert( ModelPanels, Panel )
	end

	if AllowSoccerBall then
		local Panel = self:GetPanel( "models/gmod_tower/ball_soccer.mdl", 8, "Soccer Ball" )
		table.insert( ModelPanels, Panel )
	end

	if AllowGeo then
		local Panel = self:GetPanel( "models/gmod_tower/ball_geo.mdl", 7, "Geo" )
		table.insert( ModelPanels, Panel )
	end

	if AllowBomb then
		local Panel = self:GetPanel( "models/gmod_tower/ball_bomb.mdl", 6, "Bomb" )
		table.insert( ModelPanels, Panel )
	end

	if AllowSpiked then
		local Panel = self:GetPanel( "models/gmod_tower/ball_spiked.mdl", 9, "Spiked Orb" )
		table.insert( ModelPanels, Panel )
	end

	if ( LocalPlayer().IsVip or LocalPlayer():IsAdmin() ) then
		local Panel = self:GetPanel( "models/gmod_tower/ballion.mdl", 5, "Ballion" )
		table.insert( ModelPanels, Panel )
	end

	local CurX, CurY = 8, 4

	for _, v in pairs( ModelPanels ) do
		v:SetPos( CurX, CurY )

		CurX = CurX + v:GetWide() + 5
	end

	self.GUI:SetSize( CurX + 3, EachHeight + 8 )
	self.GUI:SetPos(
		ScrW() / 2 - self.GUI:GetWide() / 2,
		ScrH() - self.GUI:GetTall()
	)
end

function BallRacerChooser:Close()
	if ValidPanel( self.GUI ) then
		self.GUI:Remove()
		self.GUI = nil
	end
end

function BallRacerChooser:ChooseBall( name )
	RunConsoleCommand( "selected_ball", name )
	RunConsoleCommand( "gmt_setball", name )
	ChosenId = name
end

net.Receive( "pick_ball", function( len, pl )
	BallRacerChooser:ChooseBall( pick_ball:GetInt() )
end )


local function DoClickSetBall( panel )
	BallRacerChooser:ChooseBall( panel.NameId )
end

local function DrawLayout( panel, entity )
	if panel.Hovered then
		draw.RoundedBox( 8, 0, 0, panel:GetWide(), panel:GetTall(), Color(10, 10, 10, 240 ) )
		panel.Title:SetColor( Color( 100, 100, 255 ) )
	else
		panel.Title:SetColor( Color( 255, 255, 255 ) )
	end

	if panel.NameId == ChosenId then
		draw.RoundedBox( 8, 0, 0, panel:GetWide(), panel:GetTall(), Color(10, 10, 60, 245 ) )
	else
		draw.RoundedBox( 8, 0, 0, panel:GetWide(), panel:GetTall(), Color(10, 10, 10, 210 ) )
	end

	entity:SetAngles( Angle( 0, RealTime()*60,  0) )
end

function BallRacerChooser:GetPanel( model, name, friendlyname, camera )
	local Panel = vgui.Create( "DModelPanel", self.GUI )

	Panel:SetModel( model )
	Panel:SetCamPos( camera or Vector( 60, 60, 60 ) )
	Panel:SetLookAt( Vector(0,0,0) )
	-- this was commented out but im not sure why
	-- to disable the mouse? well whatever
	-- Panel:SetMouseInputEnabled( false )
	Panel:SetSize( EachHeight, EachHeight )

	Panel.NameId = name
	Panel.DoClick = DoClickSetBall
	Panel.LayoutEntity = DrawLayout

	Panel.Title = vgui.Create( "DLabel", Panel )
	Panel.Title:SetSize( 100, 30 )
	Panel.Title:SetText( string.upper(friendlyname) )
	Panel.Title:SetFont( "GTowerHUDMainSmall" )
	Panel.Title:SizeToContents()
	Panel.Title:CenterHorizontal()
	Panel.Title.y = Panel:GetTall() - 20

	return Panel
end

-- when the menu is opened...
hook.Add("GtowerShowMenus", "bcontextmenuopen", function()
	IsButtonDown = true
	RunConsoleCommand("gmt_requestballupdate")
	BallRacerChooser:Open()
	gui.EnableScreenClicker(true)
end)

-- when the menu is closed...
-- this makes me question if IsButtonDown is even needed
-- eh ill change and see, not like there are any balls to pick
-- from
hook.Add("GtowerHideMenus", "bcontextmenuclose", function()
	IsButtonDown = false
	BallRacerChooser:Close()
	gui.EnableScreenClicker(false)
end)

net.Receive( "GtBall", function(len)
	local Id = net.ReadInt( 2 )
	if Id == 0 then
		AllowCube = net.ReadBool()
		AllowIcosahedron = net.ReadBool()
		AllowCatBall = net.ReadBool()
		AllowBomb = net.ReadBool()
		AllowGeo = net.ReadBool()
		AllowSoccerBall = net.ReadBool()
		AllowSpiked = net.ReadBool()
	elseif Id == 1 then
		ChosenId = net.ReadChar()
		cookie.Set("GMTChosenBall", ChosenId )
	end
end)