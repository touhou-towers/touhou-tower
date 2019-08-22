if SERVER then

	local DEBUG = false

	local BallRacerBalls = {}
	BallRacerBalls[1] = "models/gmod_tower/ball.mdl"
	BallRacerBalls[2] = "models/gmod_tower/cubeball.mdl"
	BallRacerBalls[3] = "models/gmod_tower/icosahedron.mdl"
	BallRacerBalls[4] = "models/gmod_tower/catball.mdl"
	BallRacerBalls[8] = "models/gmod_tower/ball_soccer.mdl"
	BallRacerBalls[7] = "models/gmod_tower/ball_geo.mdl"
	BallRacerBalls[6] = "models/gmod_tower/ball_bomb.mdl"
	BallRacerBalls[9] = "models/gmod_tower/ball_spiked.mdl"
	BallRacerBalls[5] = "models/gmod_tower/ballion.mdl"

	local function SendBallId( ply )
		umsg.Start("GtBall", ply )
			umsg.Char( 1 )
			umsg.Char( ply._PlyChoosenBall )
		umsg.End()

		if IsValid(ply.BallRaceBall) then
			ply.BallRaceBall:SetModel(BallRacerBalls[ply._PlyChoosenBall])
		end

	end

	local function SetBallId( ply, BallId )
		BallId = tonumber(BallId)

		if BallId == 2 && GTowerStore:GetPlyLevel(ply,"BallRacerCube") == 1 then
			ply._PlyChoosenBall = 2
		elseif BallId == 3 && GTowerStore:GetPlyLevel(ply,"BallRacerIcosahedron") == 1 then
			ply._PlyChoosenBall = 3
		elseif BallId == 4 && GTowerStore:GetPlyLevel(ply,"BallRacerCatBall") == 1 then
			ply._PlyChoosenBall = 4
		elseif BallId == 5 && ( ply.IsVIP || ply:IsAdmin() ) then
			ply._PlyChoosenBall = 5
		elseif BallId == 6 && GTowerStore:GetPlyLevel(ply,"BallRacerBomb") == 1 then
			ply._PlyChoosenBall = 6
		elseif BallId == 7 && GTowerStore:GetPlyLevel(ply,"BallRacerGeo") == 1 then
			ply._PlyChoosenBall = 7
		elseif BallId == 8 && GTowerStore:GetPlyLevel(ply,"BallRacerSoccerBall") == 1 then
			ply._PlyChoosenBall = 8
		elseif BallId == 9 && GTowerStore:GetPlyLevel(ply,"BallRacerSpikedd") == 1 then
			ply._PlyChoosenBall = 9
		else
			ply._PlyChoosenBall = 1
		end

		SendBallId( ply )

	end

	hook.Add("SQLStartColumns", "SQLGetBall", function()
		SQLColumn.Init( {
			["column"] = "ball",
			["update"] = function( ply )
				return tonumber( ply._PlyChoosenBall ) or 1
			end,
			["defaultvalue"] = function( ply, onstart )
				SetBallId( ply, 1 )
			end,
			["onupdate"] = function( ply, val )
				// can't call SetBallId yet, so let it be corrected later
				ply._PlyChoosenBall = val
			end
		} )
	end )

	local function PlayerSendLevels( ply )

		if !ply.SQL then
			return
		end

		SetBallId(ply, ply._PlyChoosenBall or 1)

		local CanCube = GTowerStore:GetPlyLevel(ply,"BallRacerCube") == 1
		local CanIcosahedron = GTowerStore:GetPlyLevel(ply,"BallRacerIcosahedron") == 1
		local CanCatBall = GTowerStore:GetPlyLevel(ply,"BallRacerCatBall") == 1
		local CanBomb = GTowerStore:GetPlyLevel(ply,"BallRacerBomb") == 1
		local CanGeo = GTowerStore:GetPlyLevel(ply,"BallRacerGeo") == 1
		local CanSoccer = GTowerStore:GetPlyLevel(ply,"BallRacerSoccerBall") == 1
		local CanSpiked = GTowerStore:GetPlyLevel(ply,"BallRacerSpikedd") == 1

		if DEBUG then
			Msg( ply, " sql connect: ", CanCube, " ", CanIcosahedron )
		end

		umsg.Start("GtBall", ply )
			umsg.Char( 0 )
			umsg.Bool( CanCube )
			umsg.Bool( CanIcosahedron )
			umsg.Bool( CanCatBall )
			umsg.Bool( CanBomb )
			umsg.Bool( CanGeo )
			umsg.Bool( CanSoccer )
			umsg.Bool( CanSpiked )
		umsg.End()

	end

	hook.Add("SQLConnect", "SendPlayerBallLevels", PlayerSendLevels )
	hook.Add("PlayerInitialSpawn", "SendPlayerBallLevels", PlayerSendLevels )

	concommand.Add("gmt_setball", function( ply, cmd, args )

    PlayerSendLevels( ply )

		local BallId = tonumber( args[1] )

		if BallId then
			SetBallId( ply, BallId )
		end

	end )


else // CLIENT

	local BallRacerChooser = {}
	BallRacerChooser.GUI = nil

	local EachHeight = 80

	local ChosenId = cookie.GetNumber("GMTChosenBall", 1 )

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


		if ( LocalPlayer().IsVIP || LocalPlayer():IsAdmin() ) then
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
		RunConsoleCommand("gmt_setball", name )
		ChosenId = name

		--Msg2( "Your ball will change on next spawn." )
	end

	local function DoClickSetBall( panel )
		BallRacerChooser:ChooseBall( panel.NameId )
	end

	local function DrawLayout( panel, entity )

		if panel.Hovered then
			draw.RoundedBox( 8, 0, 0, panel:GetWide(), panel:GetTall(), Color(20, 20, 20, 250 ) )
			panel.Title:SetColor( Color( 100, 100, 255 ) )
		else
			panel.Title:SetColor( Color( 255, 255, 255 ) )
		end

		if panel.NameId == ChosenId then
			draw.RoundedBox( 8, 0, 0, panel:GetWide(), panel:GetTall(), Color(10, 10, 60, 245 ) )
			panel.Title:SetColor( Color( 100, 100, 255 ) )
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
		//Panel:SetMouseInputEnabled( false )
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


	hook.Add("GtowerShowMenus","OpenBallracer", function()
    if IsValid(LocalPlayer().BallRaceBall) then
		    BallRacerChooser:Open()
    end
	end )

	hook.Add("GtowerHideMenus","CloseBallracer", function()
		BallRacerChooser:Close()
	end )

	usermessage.Hook("GtBall", function(um)

		local Id = um:ReadChar()

		if Id == 0 then

			AllowCube = um:ReadBool()
			AllowIcosahedron = um:ReadBool()
			AllowCatBall = um:ReadBool()
			AllowBomb = um:ReadBool()
			AllowGeo = um:ReadBool()
			AllowSoccerBall = um:ReadBool()
			AllowSpiked = um:ReadBool()
		elseif Id == 1 then

			ChosenId = um:ReadChar()
			cookie.Set("GMTChosenBall", ChosenId )

		end

	end )

end
