
-----------------------------------------------------
surface.CreateFont( "ZomTiny", { font = "impact", size = 14, weight = 400 } )
surface.CreateFont( "ZomSmaller", { font = "impact", size = 18, weight = 400 } )
surface.CreateFont( "ZomSmall", { font = "impact", size = 30, weight = 400 } )
surface.CreateFont( "ZomNorm", { font = "impact", size = 40, weight = 400 } )

surface.CreateFont( "HudSmall", { font = "Oswald", size = 30, weight = 100 } )
surface.CreateFont( "HudTime", { font = "Oswald", size = 78, weight = 700 } )
surface.CreateFont( "HudDays", { font = "Oswald", size = 85, weight = 400 } )
surface.CreateFont( "HudPoints", { font = "Oswald", size = 70, weight = 400 } )
surface.CreateFont( "HudPointsLabel", { font = "Oswald", size = 26, weight = 400 } )
surface.CreateFont( "HudClass", { font = "Oswald", size = 52, weight = 400 } )
surface.CreateFont( "HudAmmo", { font = "Oswald", size = 34, weight = 400 } )

surface.CreateFont( "ZomPrimary", { font = "Agency FB", size = 65, weight = 200 } )
surface.CreateFont( "ZomStatusAlt", { font = "Zfonts", size = 70, weight = 400 } )
surface.CreateFont( "ZomStatus", { font = "Kerberos Fang", size = 64, weight = 100 } )

local HudScores =
{
	Texture = surface.GetTextureID( "gmod_tower/zom/hud_score" ),
	TextureSmall = surface.GetTextureID( "gmod_tower/zom/hud_score_small" ),
	Width = 512,
	Height = 256,
}

local HudTime =
{
	Texture = surface.GetTextureID( "gmod_tower/zom/hud_time" ),
	Width = 512,
	Height = 128,
}

local HudHealth =
{
	Texture = surface.GetTextureID( "gmod_tower/zom/hud_health" ),
	Width = 512,
	Height = 256,
}

local HudWeapon =
{
	Texture = surface.GetTextureID( "gmod_tower/zom/hud_weapon" ),
	Texture2 = surface.GetTextureID( "gmod_tower/zom/hud_weapon_noback" ),
	Width = 512,
	Height = 256,
}

local HudLife = surface.GetTextureID( "gmod_tower/zom/hud_lives" )
local HudInfinity = surface.GetTextureID( "gmod_tower/zom/hud_infinity" )
local HudCrosshair = surface.GetTextureID( "gmod_tower/zom/hud_crosshair" )
local HudCrosshairIdle = surface.GetTextureID( "gmod_tower/zom/hud_crosshair_idle" )
local HudCrosshairRed = surface.GetTextureID( "gmod_tower/zom/hud_crosshair_red" )
local HudLocked = surface.GetTextureID( "gmod_tower/zom/hud_lock" )

local function GetWeaponIcon( wep )
	local texture = string.gsub( wep, "weapon_zm_", "gmod_tower/zom/weapons/" )

	return surface.GetTextureID( texture )
end

function GM:HUDPaint()

	vgui.GetWorldPanel():SetCursor( "blank" )

	surface.SetDrawColor( 255, 255, 255, 255 )

	self:DrawBlur()

	if ConVarDisplayHUD:GetInt() == 0 then
		if LocalPlayer():Alive() && GAMEMODE:GetState() != STATE_UPGRADING then
			self:DrawHUDCrosshair()
		end

		return
	end

	if GAMEMODE:GetState() != STATE_INTERMISSION then
		self:DrawHUDNameTags()
	end

	self:DrawHUDTime()
	self:DrawHUDStatus()

	if GAMEMODE:IsPlaying() || GAMEMODE:GetState() == STATE_UPGRADING then
		self:DrawHUDScores()
		self:DrawHUDHealth()
		self:DrawHUDClass()
		self:DrawHUDBossHealth()
	end

	if LocalPlayer():Alive() then
		//self:DrawHUDDebug()

		if ConVarDrawNotes:GetInt() == 1 then
			self:DrawHUDNotes()
		end

		if GAMEMODE:IsPlaying() then
			self:DrawHUDWeapons()
			self:DrawHUDPickups()
		end

		if GAMEMODE:GetState() != STATE_UPGRADING && GAMEMODE:GetState() != STATE_INTERMISSION then
			self:DrawHUDCrosshair()
			self:DrawHUDCombo()
		end
	else
		self:DrawHUDDeath()
	end

	self:DrawCursors()
	self:DrawRadar()
end

function GM:DrawBlur()
	if ConVarDrawBlur:GetInt() == 0 then return end

	if !render.SupportsPixelShaders_2_0() then return end

	local NumPasses = 3
	local H = ScrH() * .3

	DrawToyTown( NumPasses, H )
end

function GM:DrawHUDDebug()
	// ZOMBIES
	local zombies = #ents.FindByClass( "zm_npc_*" )

	draw.SimpleText( zombies, "ZomDays", ScrW() / 2, 50, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1)
	draw.SimpleText( "ZOMBIES", "ZomSmall", ScrW() / 2, 15, Color(175, 175, 175), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1 )
end

function GM:DrawHUDTime()
	surface.SetTexture( HudTime.Texture )
	surface.DrawTexturedRect( 0, 0, HudTime.Width, HudTime.Height )

	local TimeLeft = self:GetTimeLeft()

	if TimeLeft < 0 then
		TimeLeft = 0
	end

	local ElapsedTime = string.FormattedTime( TimeLeft, "%02i:%02i")

	if self:GetState() == STATE_WAITING then
		draw.SimpleText( "TIME REMAINING", "HudSmall", 118, 28, Color( 200, 200, 200, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1 )
		draw.SimpleText( ElapsedTime, "HudTime", 159, 48, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1 )
	else
		draw.SimpleText( "DAY " .. GetGlobalInt( "Round", 0 ), "HudDays", 40, 50, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1 )
		draw.SimpleText( "TIME REMAINING", "HudSmall", 190, 28, Color( 200, 200, 200, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1 )
		draw.SimpleText( ElapsedTime, "HudTime", 230, 48, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1 )
	end
end

function GM:DrawHUDStatus()
	local status = nil

	if self:GetState() == STATE_WAITING then
		status = "WAITING FOR PLAYERS"
	end

	if self:GetState() == STATE_WARMUP then
		status = "GET READY FOR THE ZOMBIE HORDE"
	end

	if status then
		draw.SimpleTextOutlined( status, "ZomStatus", ScrW() / 2, ScrH() * .25, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 50, 0, 0, 255 ) )
	end
end

function GM:DrawHUDDeath()
	local text = "YOU ARE DEAD"
	local h = ScrH() * .25

	draw.SimpleTextOutlined( text, "ZomStatus", ScrW() / 2, h, Color( 255, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 50, 0, 0, 255 ) )

	if LocalPlayer():GetNWInt( "Lives" ) > 0 then
		local time = math.Round( ( LocalPlayer().RespawnTime or 0 ) - CurTime() )

		time = math.Clamp( time, 0, 10 )

		if time > 0 then
			time = "RESPAWNING IN " .. time
			draw.SimpleTextOutlined( time, "ZomStatusAlt", ScrW() / 2, h + 50, Color( 255, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 50, 0, 0, 255 ) )
		end
	end
end

usermessage.Hook( "ZMRespawnTimer", function( um )
	local delay = um:ReadChar()

	LocalPlayer().RespawnTime = CurTime() + delay
end )

function GM:DrawHUDScores()
	local curFrags = LocalPlayer():Frags()
	local curPoints = LocalPlayer():GetNWInt( "Points" )
	local texture = HudScores.TextureSmall

	if curFrags >= 10000 || curPoints >= 10000 then
		texture = HudScores.Texture
	end

	surface.SetTexture( texture )
	surface.DrawTexturedRect( ScrW() - HudScores.Width, 0, HudScores.Width, HudScores.Height )

	// KILLS
	draw.SimpleText( curFrags/8, "HudPoints", ScrW() - 90, 70, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1 )
	draw.SimpleText( "KILLS", "HudPointsLabel", ScrW() - 50, 82, Color( 200, 200, 200 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1 )

	// POINTS
	draw.SimpleText( curPoints, "HudPoints", ScrW() - 90, 130, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1 )
	draw.SimpleText( "POINTS", "HudPointsLabel", ScrW() - 36, 142, Color( 200, 200, 200 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1 )
end

function GM:DrawHUDCombo()
	if LocalPlayer():GetNWInt( "Combo" ) < 1 && !LocalPlayer():GetNWInt( "IsPowerCombo" ) then return end

	local mX, mY = gui.MousePos()
	local textX = 30
	local textY = 0
	local alpha = 50
	local color = Color( 255, 255, 255, alpha )
	local text = "COMBO x" .. LocalPlayer():GetNWInt( "Combo" )

	if LocalPlayer():GetNWInt( "IsPowerCombo" ) then
		alpha = 200
		color = Color( math.random( 200, 255 ), math.random( 50, 255 ), math.random( 50, 255 ), alpha )
		text = "PRESS SHIFT FOR POWER"
	end

	draw.SimpleText( text, "ZomSmall", mX + textX + 2, mY + textY + 2, Color( 0, 0, 0, alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1 )
	draw.SimpleText( text, "ZomSmall", mX + textX, mY + textY, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1 )
end

function GM:DrawHUDWeapons()
	if !LocalPlayer().GetActiveWeapon then return end

	local wep = LocalPlayer():GetActiveWeapon()

	if !IsValid( wep ) then return end

	local texture = HudWeapon.Texture2

	if LocalPlayer():GetNWString( "BackWeaponClass" ) != "" then
		texture = HudWeapon.Texture
	end

	surface.SetDrawColor( 255, 255, 255, 255 )

	// Fade when locked
	if LocalPlayer():GetNWBool( "LockedWeapons" ) then
		surface.SetDrawColor( 150, 150, 150, 150 )
	end

	surface.SetTexture( texture )
	surface.DrawTexturedRect( ScrW() - HudWeapon.Width, ScrH() - HudWeapon.Height, HudWeapon.Width, HudWeapon.Height )

	local curAmmo = wep:Clip1() or -1
	local curAmmoString = curAmmo

	if wep.IsMelee && !wep.IsQuickMelee && wep.Durability && wep.MaxDurability then
		local percent = math.Round( ( wep.Durability / wep.MaxDurability ) * 100 )

		curAmmo = percent
		curAmmoString = tostring( percent ) .. "%"
	end

	if curAmmo != -1 then
		draw.SimpleText( curAmmoString, "HudAmmo", ScrW() - 260, ScrH() - 40, Color( 255, 255, 255, 192 ), 1, 1 )
	else
		surface.SetTexture( HudInfinity )
		surface.DrawTexturedRect( ScrW() - 260 - 32, ScrH() - 40 - 32, 64, 64 )
	end

	if LocalPlayer():GetNWString( "BackWeaponClass" ) != "" then
		surface.SetTexture( GetWeaponIcon( LocalPlayer():GetNWString( "BackWeaponClass" ) ) )
		surface.DrawTexturedRect( ScrW() - 80, ScrH() - 70, 64, 64 )
	end

	surface.SetTexture( GetWeaponIcon( wep:GetClass() ) )
	surface.DrawTexturedRect( ScrW() - 110 - 128, ScrH() + 15 - 128, 128, 128 )

	local wepname = wep:GetPrintName()

	if wepname != "Glock" && !wep.IsMelee then
		draw.SimpleText( wepname, "HudPointsLabel", ScrW() - 175 + 2, ScrH() - 80 + 2, Color( 20, 20, 20, 255 ), 1, 1 )
		draw.SimpleText( wepname, "HudPointsLabel", ScrW() - 175, ScrH() - 80, Color( 120, 120, 120, 255 ), 1, 1 )
	end

	// Show lock icon
	if LocalPlayer():GetNWBool( "LockedWeapons" ) then
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetTexture( HudLocked )
		surface.DrawTexturedRect( ScrW() - 128, ScrH() + 15 - 128, 48, 48 )
	end

	/*local wep2 = LocalPlayer():GetBackWeapon()

	if wep2 then
		local wepname2 = wep:GetPrintName()
		draw.SimpleText( wepname2, "ZomNorm", ScrW() - 122, ScrH() - 20, Color( 200, 200, 200, 255 ), 1, 1 )
	end*/
end

function GM:DrawHUDHealth()
	surface.SetTexture( HudHealth.Texture )
	surface.DrawTexturedRect( 0, ScrH() - HudHealth.Height, HudHealth.Width, HudHealth.Height )

	draw.SimpleText( "LIVES", "HudSmall", 32, ScrH() - 70, Color( 200, 200, 200 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1 )

	local lives = 2
	local livesY = ScrH() - 55

	surface.SetTexture( HudLife )

	// Background lives
	local lifepos = 32

	for i=1, lives do
		surface.SetDrawColor( 80, 80, 80, 25 )
		surface.DrawTexturedRect( lifepos, livesY, 32, 32 )
		lifepos = lifepos + 20
	end

	local lives = LocalPlayer():GetNWInt( "Lives" )

	// Filled lives
	local lifepos = 32

	for i=1, lives do
		surface.SetDrawColor( 255, 180, 80, 255 )
		surface.SetTexture( HudLife )
		surface.DrawTexturedRect( lifepos, livesY, 32, 32 )
		lifepos = lifepos + 20
	end

	//draw.SimpleText( LocalPlayer().Lives, "ZomNorm", 60, ScrH() - 42, Color( 200, 200, 200, 255 ), 1, 1 )

	draw.SimpleText( "HEALTH", "HudSmall", 120, ScrH() - 70, Color( 200, 200, 200 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1 )

	// Background bars
	local bars = 10
	local barpos = 108

	for i = 1, bars do
		barpos = barpos + 13

		surface.SetDrawColor( 80, 80, 80, 25 )
		surface.DrawRect( barpos, ScrH() - 56, 11, 32 )
	end

	// Filled bars
	local curHealth = LocalPlayer():Health()

	bars = math.ceil( curHealth / 10 )
	barpos = 108

	for i = 1, bars do
		barpos = barpos + 13

		surface.SetDrawColor( 255, 180, 80, 255 )
		surface.DrawRect( barpos, ScrH() - 56, 11, 32 )
	end
end

function GM:DrawHUDClass()
	local class = LocalPlayer():GetNWString( "ClassName" )

	if !class then return end

	draw.SimpleText( string.upper( class ), "HudClass", 30, ScrH() - 100, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1 )

	local class = classmanager.Get( string.lower( LocalPlayer():GetNWString( "ClassName" ) ) )

	if !class then return end

	local x = 220

	// Special item
	surface.SetDrawColor( 100, 100, 100, 255 )
	//surface.SetDrawColor( 80, 80, 80, ( ( ( timeleft / class.SpecialItemDelay ) - 1 ) * -1 ) * 255 )

	if LocalPlayer():GetNWInt( "LastItem" ) < CurTime() then
		surface.SetDrawColor( 255, 255, 255, 255 )
	end

	surface.SetTexture( class.SpecialItemMat )
	surface.DrawTexturedRect( x, ScrH() - 100 - 24, 48, 48 )

	local timeleft = math.floor( LocalPlayer():GetNWInt( "LastItem" ) - CurTime() )

	if timeleft > 0 then
		self:DrawHUDCircle( timeleft, class.SpecialItemDelay, x + 24, ScrH() - 100, 20, 255, true )
	end

	// Combo power
	surface.SetDrawColor( 100, 100, 100, 255 )
	//surface.SetDrawColor( 80, 80, 80, ( LocalPlayer().Combo / 5 ) * 255 )

	if LocalPlayer():GetNWInt( "IsPowerCombo" ) then
		surface.SetDrawColor( 255, 255, 255, 255 )
	end

	if LocalPlayer():GetNWInt( "IsPoweredUp" ) then
		surface.SetDrawColor( 255, 255, 255, SinBetween( 50, 255, CurTime() * 8 ) )
	end

	surface.SetTexture( class.PowerMat )
	surface.DrawTexturedRect( x + 48 + 5, ScrH() - 100 - 24, 48, 48 )

	if LocalPlayer():GetNWInt( "Combo" ) > 0 && !LocalPlayer():GetNWInt( "IsPoweredUp" ) then
		self:DrawHUDCircle( LocalPlayer():GetNWInt( "Combo" ), 5, x + 48 + 29, ScrH() - 100, 20, 255 )
	end
end

local HUDPickups = {}
local HUDPickupTime = 2

function GM:DrawHUDPickups()

	for id, pickup in ipairs( HUDPickups ) do
		if ( pickup.Time + HUDPickupTime ) < CurTime() then
			table.remove( HUDPickups, id )
			continue
		end

		local timer = CurTime() - pickup.Time

		if timer > HUDPickupTime then timer = HUDPickupTime end

		if ( pickup.Time + HUDPickupTime ) > CurTime() then
			timer = ( pickup.Time + HUDPickupTime ) - CurTime()
		end

		// Get text size
		surface.SetFont( "ZomNorm" )

		local w, h = surface.GetTextSize( pickup.Text )

		// Get position
		local x = ( ScrW() / 2 ) - ( w / 2 ) + pickup.OffsetX
		local y = ( ScrH() / 2 ) - ( h ) + ( 20 * timer ) + ( id * -35 )

		pickup.Color.a = 150 * timer

		draw.SimpleTextOutlined( pickup.Text, "ZomNorm", x, y, pickup.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 0, 0, 0, 255 ) )
	end
end

local PickupStrings = {
	"REFILLED",
	"REPAIRED",
	"GOT",
}

usermessage.Hook( "PickupHUD", function( um )
	local text 	= um:ReadString()
	local id    = um:ReadChar()

	text = PickupStrings[id] .. " " .. text

	local pickup 		= {}

	pickup.Text 		= text
	pickup.Time 		= CurTime()
	pickup.Color 		= Color( 255, 255, 255, 150 )
	pickup.OffsetX 		= math.random( -200, 200 )
	//pickup.OffsetY 		= math.random( -20, 20 )

	table.insert( HUDPickups, pickup )
end )

function GM:DrawHUDNameTags()
	for k, ply in pairs( player.GetAll() ) do
		if LocalPlayer() == ply then continue end

		local toscr = ( ply:GetPos() + Vector( -30, 0, 0 ) ):ToScreen()
		local name = ply:Name()
		local class = string.upper( ply:GetNWString( "ClassName" ) )
		local classY = 20

		if !ply:Alive() then
			class = "NO LONGER A " .. class
			name = "RIP " .. name
		end

		local color = ply:GetPlayerColor() * 255
		color = Color( math.Clamp( color.r, 60, 255 ), math.Clamp( color.g, 60, 255 ), math.Clamp( color.b, 60, 255 ) )

		draw.SimpleText( name, "ZomSmall", toscr.x + 1, toscr.y + 1, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( name, "ZomSmall", toscr.x, toscr.y, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( class, "ZomSmaller", toscr.x + 1, toscr.y + classY + 1, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( class, "ZomSmaller", toscr.x, toscr.y + classY, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		// Draw lives
		if self:IsPlaying() then
			local lives = ply:GetNWInt( "Lives" )
			local livesY = 38
			local livestitle = " LIVES"

			if lives == 1 then
				livestitle = " LIFE"
			end

			lives = lives .. livestitle

			if ply:GetNWString( "Lives" ) == 0 && !ply:Alive() then
				lives = "TOUCH TO RESPAWN"
			end

			draw.SimpleText( lives, "ZomSmaller", toscr.x + 1, toscr.y + livesY + 1, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( lives, "ZomSmaller", toscr.x, toscr.y + livesY, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
end

local cursorSize = 10
local cursorAlpha = 30

function GM:DrawHUDCrosshair()
	local mX, mY = gui.MousePos()

	if input.IsMouseDown( MOUSE_LEFT ) then
		cursorSize = math.Approach( cursorSize, 50, 1 )

		surface.SetTexture( HudCrosshair )

		if cursorSize >= 50 then
			cursorAlpha = math.Approach( cursorAlpha, 10, .5 )

			surface.SetDrawColor( 255, 255, 255, cursorAlpha )
		else
			surface.SetDrawColor( 255, 255, 255, 100 )
		end
	else
		cursorSize = math.Approach( cursorSize, 30, 2 )

		surface.SetTexture( HudCrosshairIdle )

		cursorAlpha = math.Approach( cursorAlpha, 30, 1 )

		surface.SetDrawColor( 255, 255, 255, cursorAlpha )
	end

	local offset = cursorSize / 2

	surface.DrawTexturedRect( mX - offset, mY - offset, cursorSize, cursorSize )

	// Weapon cursor
	if !LocalPlayer().GetActiveWeapon then return end

	local wep = LocalPlayer():GetActiveWeapon()

	if !IsValid( wep ) then return end

	local wepammo = wep:Clip1() or -1
	local wepclip = -1

	if wep.Primary then
		wepclip = wep.Primary.ClipSize
	end

	if wep.IsMelee && !wep.IsQuickMelee then
		wepammo = wep.Durability
		wepclip = wep.MaxDurability
	end

	self:DrawHUDCircle( wepammo, wepclip, mX, mY, ( cursorSize / 2 ) + 2, cursorAlpha )
end

function GM:DrawHUDCircle( val, max, x, y, size, alpha, inverse )
	if !val || !max || val <= 0 || val <= 0 then return end

	local polys = 32
	local percent = val / max * polys

	if inverse then
		percent = ( ( ( val / max ) - 1 ) * -1 ) * polys
	end

	local colorPerc = math.Clamp( ( val / max ) * 255 + 150, 0, 255 )

	if inverse then
		colorPerc = math.Clamp( ( ( ( val / max ) - 1 ) * -1 ) * 255 + 150, 0, 255 )
	end

	surface.SetTexture( 0 )
	surface.SetDrawColor( colorPerc, colorPerc, colorPerc, alpha + 10 )

	for i=1, percent, 1 do
		surface.DrawPoly( GetCircleTable( i, 1.0, size, size + 4, polys, 0, x, y ) )
	end

	surface.DrawPoly(
		GetCircleTable(
			math.ceil( percent ),
			percent - math.floor( percent ),
			size,
			size + 4,
			polys,
			0,
			x,
			y
		)
	)
end

local HUDNotes = {}
local HUDNoteTime = 1.5

function GM:DrawHUDNotes()
	for id, note in ipairs( HUDNotes ) do
		if ( note.Time + HUDNoteTime ) < CurTime() then
			table.remove( HUDNotes, id )
			continue
		end

		local timer = CurTime() - note.Time

		if timer > HUDNoteTime then timer = HUDNoteTime end

		local scrpos = note.Pos:ToScreen()

		if ( note.Time + HUDNoteTime ) > CurTime() then
			timer = ( note.Time + HUDNoteTime ) - CurTime()
		end

		//local y = scrpos.y + 20 * timer

		note.Color.a = 150 * timer

		draw.SimpleTextOutlined( note.Text, "ZomSmall", scrpos.x, scrpos.y, note.Color, 1, 1, 2, Color( 0, 0, 0, 150 * timer ) )
		draw.SimpleTextOutlined( note.Text, "ZomSmall", scrpos.x, scrpos.y, note.Color, 1, 1, 4, Color( 0, 0, 0, 150 * timer ) )
	end
end

function GM:AddHUDNote( type, amount, pos )
	local note 		= {}

	note.Text 		= "-" .. amount
	note.Pos 		= pos + Vector( 0, 0, 20 )
	note.Time 		= CurTime()
	note.Color  	= Color( 250, 50, 50, 150 )
	note.Font		= "ZomTiny"

	if type == NOTE_POINTS then
		note.Text 	= "+" .. amount .. " PTS"
		note.Color 	= Color( 150, 150, 255, 150 )
		note.Pos 	= pos + Vector( math.random( -10, 10 ), math.random( -10, 10 ), 0 )
		note.Font	= "ZomSmall"
	end

	if type == NOTE_HEAL then
		note.Text 	= "+" .. amount .. " HP"
		note.Color 	= Color( 50, 250, 50, 150 )
		note.Font	= "ZomSmall"
	end

	if type == NOTE_KILLED then
		note.Text 	= "KILL"
		note.Pos 	= pos + VectorRand() * 10
		note.Font	= "ZomSmall"
	end

	if type == NOTE_POWERUP then
		note.Text 	= "POWERED UP!"
		note.Color 	= Color( 255, 255, 255, 150 )
		note.Pos 	= pos + Vector( math.random( -10, 10 ), math.random( -10, 10 ), 0 )
		note.Font	= "ZomSmall"
	end

	table.insert( HUDNotes, note )
end

usermessage.Hook( "HUDNotes", function( um )
	local type 		= um:ReadChar()
	local amount 	= um:ReadShort()
	local pos 		= LocalPlayer():GetPos()
	local entid 	= um:ReadShort()
	local ent 		= ents.GetByIndex( entid )

	if IsValid( ent ) then
		pos = ent:GetPos()
	end

	GAMEMODE:AddHUDNote( type, amount, pos )
end )

surface.CreateFont( "BossFont", { font = "Zfonts", size = 24, weight = 400 } )

local gradientUp = surface.GetTextureID( "VGUI/gradient_up" )
local maxBarHealth = 100
local deltaVelocity = 0.08 -- [0-1]
local bw = 12 -- bar segment width
local padding = 2
local colGreen = Color( 129, 215, 30, 255 )
local colDarkGreen = Color( 50, 83, 35, 255 )
local colRed = Color( 215, 43, 30, 255 )
local colDarkRed = Color( 132, 43, 24, 255 )
local curPercent = nil

function GM:DrawHUDBossHealth()
	if !self:HasBoss() then return end

	local boss = self:GetBoss()
	local health = GetGlobalInt( "BossHealth" )
	local name = GetGlobalString( "BossName", "BOSS" )
	local maxHealth = GetGlobalInt( "BossMaxHealth", 2000 )

	-- Let's do some calculations first
	maxBarHealth = 5000

	local totalHealthBars = math.ceil( maxHealth / maxBarHealth )
	print(totalHealthBars)
	local curHealthBar = math.floor( health / maxBarHealth )

	if health % maxBarHealth == 0 then
		curHealthBar = curHealthBar - 1
	end

	local percent = ( health - curHealthBar * maxBarHealth ) / maxBarHealth
	curPercent = !curPercent and 1 or math.Approach( curPercent, percent, math.abs( curPercent - percent ) * 0.08 )

	local x, y = ScrW() / 2, 80
	local w, h = ScrW() / 3, 20

	-- Boss name
	surface.SetFont( "BossFont" )

	local tw, th = surface.GetTextSize( name )
	local x3, y3 = x-(w/2), y + h - padding * 2
	local w3, h3 = tw + padding*4, th + padding

	draw.RoundedBox( 4, x3, y3, w3, h3, Color( 0, 0, 0, 200 ) )
	draw.SimpleText( name, "BossFont", x3 + padding*2, y3 + padding + 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

	-- Boss health bar segments
	local rw, rh = ( bw + padding ) * totalHealthBars + padding, th + padding
	local x4, y4 = x+(w/2)-rw, y + h - padding * 2

	draw.RoundedBox( 4, x4, y4, rw, rh, Color( 0, 0, 0, 200 ) )

	for i=0,totalHealthBars-1 do
		local col = ( i<curHealthBar ) and colRed or colDarkRed
		draw.RoundedBox( 4, x4 + ( bw + padding )*i + padding, y4 + padding*3, bw, bw + padding * 2, col )
	end

	-- Health bar background
	draw.RoundedBox( 4, x-(w/2), y, w, h, Color( 0, 0, 0, 200 ) )

	-- Boss health bar
	local x2, y2 = x-(w/2) + padding, y + padding
	local w2, h2 = w - padding * 2, h - padding * 2

	draw.RoundedBox( 4, x2, y2, w2, h2, colDarkRed ) -- dark green background
	draw.RoundedBox( 0, x2, y2, w * curPercent - padding * 2, h2, colRed )

	surface.SetDrawColor( 0, 0, 0, 100 )
	surface.SetTexture( gradientUp )
	surface.DrawTexturedRect( x2, y2, w2, h2 )
end

function GM:DrawCursors()
	if GAMEMODE:GetState() != STATE_UPGRADING then return end

	if !LocalPlayer()._LastUpdate then LocalPlayer()._LastUpdate = 0 end

	// Update position
	local mX, mY = gui.MousePos()

	// Relative to center of the screen
	mX = ScrW()/2 - mX
	mY = ScrH()/2 - mY

	if( LocalPlayer()._LastX != mX ||
		LocalPlayer()._LastY != mY ) &&
		LocalPlayer()._LastUpdate < RealTime() - 0.5 then
		LocalPlayer()._LastX = mX
		LocalPlayer()._LastY = mY
		LocalPlayer()._LastUpdate = RealTime()

		RunConsoleCommand( "zm_cursorupdate", mX, mY )
	end
end

function GM:PaintCursors()

	if GAMEMODE:GetState() != STATE_UPGRADING then return end

	// Draw other cursors
	local cursorSize = 32
	local offset = cursorSize / 2

	surface.SetTexture( Cursor2D )

	for _, ply in pairs( player.GetAll() ) do

		if LocalPlayer() == ply then continue end

		ply.CursorPos = ply:GetNWVector("CursorPos")

		if !ply._CurX || !ply._CurY then
			ply._CurX = ply:GetNWVector("CursorPos").x
			ply._CurY = ply:GetNWVector("CursorPos").y
		end

		ply._CurX = math.Approach( ply._CurX, ply.CursorPos.x, FrameTime() * 1000 )
		ply._CurY = math.Approach( ply._CurY, ply.CursorPos.y, FrameTime() * 1000 )

		local mX, mY = ScrW()/2 + ply._CurX, ScrH()/2 + ply._CurY
		local textX, textY = 15, 5

		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( mX - offset + 5, mY - offset + 8, cursorSize, cursorSize )

		local text = ply:GetName()
		local color = ply:GetDisplayTextColor()

		draw.SimpleText( text, "ZomSmall", mX + textX + 2, mY + textY + 2, Color( 0, 0, 0, alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1 )
		draw.SimpleText( text, "ZomSmall", mX + textX, mY + textY, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1 )
	end
end

/*hook.Add("InitPostEntity", "DrawWeapon", function()


	local panel = vgui.Create("DModelPanelZM")

	panel:SetSize( 500, 500 )
	panel:SetPos( ScrW() - 500, ScrH() - 500 )
	panel:SetVisible( false )

	GAMEMODE.WeaponPanel = panel
end )

hook.Add("Think", "UpdateWeaponModel", function()
	if !ValidPanel( GAMEMODE.WeaponPanel ) then
		return
	end

	GAMEMODE.WeaponPanel:MouseCapture( false )
	GAMEMODE.WeaponPanel:SetMouseInputEnabled( false )

	local Weapon = LocalPlayer():GetActiveWeapon()

	if IsValid( Weapon ) && LocalPlayer():Alive() then
		GAMEMODE.WeaponPanel:SetVisible( true )
		GAMEMODE.WeaponPanel:SetModel( Weapon:GetModel() )
	else
		GAMEMODE.WeaponPanel:SetVisible( false )
	end
end )*/
