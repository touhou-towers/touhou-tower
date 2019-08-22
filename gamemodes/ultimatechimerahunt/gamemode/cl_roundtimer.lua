local sw, sh = ScrW(), ScrH()
local timerticks = {}
	
local function UpdateRoundTimer( um )

	local num = um:ReadLong()
	table.insert( timerticks, { CurTime(), num } )

	GAMEMODE.LastTimerAdd = GAMEMODE.LastTimerAdd || 0

	if CurTime() >= GAMEMODE.LastTimerAdd then
		GAMEMODE.LastTimerAdd = CurTime() + .4
		surface.PlaySound( "UCH/music/roundtimer_add.wav" )
	end

end
usermessage.Hook( "UpdateRoundTimer", UpdateRoundTimer )

function GM:DrawTimerTicks()

	for k, v in ipairs( timerticks ) do

		local t, num = v[1] + 1, v[2]
		local fade = t - CurTime()
		
		local alpha = math.Clamp( fade, 0, 255 )
		self:DrawNiceText( "+" .. tostring( num ), "UCH_TargetIDName", ( ( sw * .58 ) - ( fade * ( sw * .1 ) ) ), 0, Color( 255, 255, 255, alpha * 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, alpha * 150 )

		if CurTime() >= t then
			table.remove( timerticks, k )
		end

	end

end

local pmat = surface.GetTextureID( "UCH/hud/pighud_time" )
local pemat = surface.GetTextureID( "UCH/hud/pighude_time" )
local pCmat = surface.GetTextureID( "UCH/hud/pighudc_time" )
local ucmat = surface.GetTextureID( "UCH/hud/chimerahud_time" )
	
function GM:DrawRoundTime()

	local tm = self:GetTimeLeft()
	
	if tm >= 60 then
		tm = string.FormattedTime( tm, "%2i:%02i" )
	else
		tm = math.Round( tm )
	end

	if self:GetTimeLeft() < 0 then
		tm = "-:-"
	end

	tm = string.Trim( tm )

	surface.SetFont( "UCH_KillFont3" )
	local txtw, txth = surface.GetTextSize( "Waiting" )

	local x, y = sw * .5, -( sh * .05 )
	local h = ( txth * 4.5 ) + -y
	local w = h * 2

	local mat = pmat
	local color = LocalPlayer():GetRankColorSat()
	local r, g, b = color.r, color.g, color.b

	if LocalPlayer().Rank == RANK_COLONEL && !LocalPlayer().IsGhost then
		mat = pCmat
	end

	if LocalPlayer().Rank == RANK_ENSIGN then
		mat = pemat
		r, g, b = 255, 255, 255
	end

	if LocalPlayer().IsChimera then
		mat = ucmat
		r, g, b = 255, 255, 255
	end

	if LocalPlayer().IsGhost then
		mat = pmat
		r, g, b = 255, 255, 255
	end

	surface.SetTexture( mat )
	surface.SetDrawColor( Color( r, g, b, 255 ) )
	surface.DrawTexturedRect( x - ( w * .5 ), 0, w, h )
	
	local round = "-/" .. self.NumRounds
	if self:IsPlaying() || self:GetGameState() == STATUS_INTERMISSION then
		round = GetGlobalInt("Round") .. "/" .. self.NumRounds
	end

	self:DrawNiceText( tm, "UCH_KillFont3", sw * .425, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, 250 )
	self:DrawNiceText( round, "UCH_KillFont3", sw * .565, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, 250 )

	if #timerticks > 0 then
		self:DrawTimerTicks()
	end

end