include( "cl_targetid.lua" )

local sw, sh = ScrW(), ScrH()

local xhairtex = surface.GetTextureID( "UCH/hud_pig_crosshair" )
local ensignLogo = surface.GetTextureID( "UCH/ranks/ensign" )
local glass = surface.GetTextureID( "UCH/ghost_glass" )
local saturn = surface.GetTextureID( "UCH/hud_saturn" )

local function TextSize( font, txt )
	surface.SetFont( font )
	local w, h = surface.GetTextSize( txt )
	return { w, h }
end

function GM:DrawNiceText( txt, font, x, y, clr, alignx, aligny, dis, alpha )
	
	local tbl = {
		pos = {
			[1] = x,
			[2] = y
		},
		color = clr,
		text = txt,
		font = font,
		xalign = alignx,
		yalign = aligny
	}

	draw.TextShadow( tbl, dis, alpha )
	
end

local function DrawNiceBox( x, y, w, h, clr, dis )

	local clr2 = Color( clr.r, clr.g, clr.b, clr.a * .5 )
	
	draw.RoundedBox( 4, x - dis, y - dis, w + ( dis * 2 ), h + ( dis * 2 ), clr )
	draw.RoundedBox( 2, x, y, w, h, clr2 )
	
end

local function DrawInfoBox( txt, x, y )
	
	local dis = ( y * .05 )
	local bob = math.sin((CurTime() * 4))
	
	y = ( y + ( dis * bob))
	
	local tsize = TextSize( "TargetID", txt )
	local tw, th = tsize[1], tsize[2]
	DrawNiceBox( x - ( tw * .6 ), y - ( th * .6 ), tw * 1.2, th * 1.2, Color( 10, 10, 10, 125 ), 4 )
	
	GAMEMODE:DrawNiceText( txt, "TargetID", x, y, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, 200 )
	
end

local function DrawCrosshair()

	local ply = LocalPlayer()
	if ply.IsChimera then return end
	
	local xalpha = 100
	
	ply.XHairAlpha = ( ply.XHairAlpha || xalpha )
	local alpha = ply.XHairAlpha
	
	if alpha != xalpha then
		ply.XHairAlpha = math.Approach( ply.XHairAlpha, xalpha, FrameTime() * 150 )
	end
	
	local rankcolor = ply:GetRankColor()
	local color = Color( rankcolor.r, rankcolor.g, rankcolor.b, alpha )
	
	surface.SetTexture( xhairtex )
	surface.SetDrawColor( color )
	surface.DrawTexturedRectRotated( sw * .5, sh * .5, sh * .04, sh * .04, 0 )
	
	if ply.IsGhost && ply.IsFancy then

		surface.SetTexture( glass )
		surface.SetDrawColor( Color( 255, 255, 255, 160) )
		surface.DrawTexturedRectRotated( sw * .515, sh * .5, sh * .028, sh * .028, -12 )
		
	end

	if ply:IsPig() && ply.HasSaturn then

		surface.SetTexture( saturn )
		surface.SetDrawColor( Color( 255, 255, 255, 200 ) )
		surface.DrawTexturedRectRotated( sw * .520, sh * .5, sh * .028, sh * .028, -12 )
		
	end
	
end

local xx, yy, ww, hh = .28, .2725, .375, .12

local pigmat = surface.GetTextureID( "UCH/hud/pighud" )
local pigCmat = surface.GetTextureID( "UCH/hud/pighudc" )
local pigEmat = surface.GetTextureID( "UCH/hud/pighude" )
local ucmat = surface.GetTextureID( "UCH/hud/chimerahud" )

function GM:DrawHUD()
	
	local ply = LocalPlayer()
	local mat = pigmat

	// Current alive pigs
	if self:GetGameState() == STATUS_PLAYING then
		local pigs = #team.GetPlayers( TEAM_PIGS )
		surface.SetTexture( ensignLogo )
		surface.SetDrawColor( Color( 250, 255, 255 ) )
		surface.DrawTexturedRectRotated( ScrW() - 150, ScrH() - 100, 64, 64, 0 )
	
		self:DrawNiceText( pigs, "UCH_KillFont3", ScrW() - 150 + 40, ScrH() - 100, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, 200 )
	end
	
	if ply.IsChimera then
		
		mat = ucmat

		local h = ( sh * .285 )
		local w = ( h * 2 )
		
		local x, y = ( sw * -.0385), ( sh * .732 )
		
		local spx, spy = ( x + ( w * .285)), ( y + ( h * .58))
		local spw, sph = ( w * .505), ( h * .145 )
		self:DrawSprintBar( spx, spy, spw, sph )
		
		local rrx, rry = ( x + ( w * .2825)), ( y + ( h * .43))
		local rrw, rrh = ( w * .3775), ( h * .115 )
		self:DrawRoarMeter( rrx, rry, rrw, rrh )
		
		local tsx, tsy = ( x + ( w * .28)), ( y + ( h * .2725))
		local tsw, tsh = ( w * .375), ( h * .12 )
		self:DrawSwipeMeter( tsx, tsy, tsw, tsh )
		
		surface.SetTexture( ucmat )
		surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
		surface.DrawTexturedRect( x, y, w, h )

	else
	
		if ply.IsGhost then return end
		
		local h = ( sh * .14 )
		local w = ( h * 4 )
		
		local x, y = ( sw * -.035), ( sh * .85 )
		
		local spx, spy = ( x + ( w * .286)), ( y + ( h * .35))
		local spw, sph = ( w * .51), ( h * .275 )
		self:DrawSprintBar( spx, spy, spw, sph )

		if ply.Rank == RANK_COLONEL then
			mat = pigCmat
		end
		if ply.Rank == RANK_ENSIGN then
			mat = pigEmat
		end

		local color = ply:GetRankColorSat()
		surface.SetTexture( mat )
		surface.SetDrawColor( Color( color.r, color.g, color.b ) )
		surface.DrawTexturedRect( x, y, w, h )

	end
	
end

function GM:HUDPaint()
	
	local ply = LocalPlayer()

	local txt = nil
	
	if self:GetGameState() == STATUS_WAITING then
		
		txt = "Waiting for players..."
		
	elseif self:GetGameState() == STATUS_INTERMISSION then
		
		txt = "Starting new round..."
		
		if ( GetGlobalInt("Round") + 1 ) > self.NumRounds then

			txt = "Ending game!"

		end

	end

	if txt then
		DrawInfoBox( txt, sw * .5, sh * .185 )
	end

	if ( ( ply:Alive() && ply:Team() == TEAM_PIGS ) || ply.IsGhost ) && !ply.IsTaunting && !ply.IsScared then
		DrawCrosshair()
	end
	
	self:DrawHUD()
	self:DrawKillNotices()
	self:DrawTargetID()
	self:DrawRoundTime()
	self:DrawSaturn()
	
end

local HiddenHud = { "CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo", "CHudCrosshair", "CHudWeapon", "CHudChat" }
function GM:HUDShouldDraw(  name  )

	for _, v in ipairs(  HiddenHud  ) do
		if name == v then return false end
	end
	
	return true
end