
include("sh_init.lua")module( "payout", package.seeall )
net.Receive( "Payouts", function( length, ply )
	DisplayEarned( net.ReadTable() )
end )
--Settings
local PAYOUT_FRAME = {
	X = ScrW() - 400,
	Y = ScrH() - 140,
	WIDTH = 400,
	HEIGHT = 140,
	BG_COLOR = Color( 0, 0, 0, 150 ),
	TIME_BRACKETS = {
		{5, .15},
		{50, .25}, --Start of bracket ( values lower than this will apply ), seconds it takes to count
		{100, .55},
		{500, .75},
		{1000, 1},
		{5000, 2},
	},
}
--Sound Stuff
local gradient = surface.GetTextureID( "VGUI/gradient_down" )
local blipDuration = 2.08
local state = {}
local snd = {
	brackets = {},
	blip = Sound( "GModTower/misc/blip.wav" ),
	blips = Sound( "GModTower/misc/payout/blips.wav" ),
	start = Sound( "GModTower/misc/payout/payout_start.wav" ),
	open = Sound( "GModTower/misc/payout/start.wav" ),
	kick = Sound( "GModTower/misc/payout/kick.wav"),
}
for i=1, 8 do
	table.insert( snd.brackets, 
		Sound( "GModTower/misc/payout/bracket" .. i .. ".wav" ) 
	)
end
local blipSoundPatch = nil
-- Interpolators
sinInterpolate = function( t, power )
	t = math.Clamp( t, 0, 1 )
	t = t * (math.pi/2)
	local sin = math.sin( t )
	return math.pow( sin, power or 2 )
end
cosInterpolate = function( t, power )
	t = math.Clamp( t, 0, 1 )
	t = t * (math.pi/2)
	local cos = math.cos( t )
	return math.pow( cos, power or 2 )
end
cosSinInterpolate = function( t, power )
	local a = sinInterpolate( t, power )
	local b = cosInterpolate( 1 - t, power )

	return a + ( b - a ) * math.Clamp( t, 0, 1 )
end
--Drawing stuff
surface.CreateFont( "PayoutFinal", { font = "Bebas Neue", size = 70, weight = 500 } )
surface.CreateFont( "PayoutTitle", { font = "Bebas Neue", size = 40, weight = 100 } )
surface.CreateFont( "PayoutDescription", { font = "verdana", size = 18, weight = 100 } )
function GetTimeBracket( gmc )
	local max = 0
	for k, v in ipairs( PAYOUT_FRAME.TIME_BRACKETS ) do
		if gmc <= v[1] then
			return v[2]
		else
			max = v[2]
		end
	end
	return max
end
function DrawPayoutMain( x, y, width, height )
	if not state.payoutStart then return end
	blipSoundPatch = blipSoundPatch or CreateSound( LocalPlayer(), snd.blips )
	local dt = CurTime() - state.payoutStart
	local earn = state.earnTable[state.currentPayout]
	local payout, gmc
	if earn then
		payout = earn.payout
		gmc = earn.gmc
	else
		gmc = 0
	end
	local cx = x + width/2
	local cy = y + height/2
	if dt < .1 then
		--Initialize this payout
		state.blipstart = nil
		state.kick = 1
		state.timescale = 1 / GetTimeBracket( gmc )
	else
		--Play start noise
		if state.kick == 1 then
			if payout then
				surface.PlaySound( snd.start ) 
			end
			state.kick = state.kick + 1 
		end
	end
	local dtx = dt * 2
	dtx = math.Clamp(dtx, 0, 1)
	local alpha = 1
	if state.fadeout then
		--Fade payout ui
		alpha = 1 - (CurTime() - state.fadeout) / 3
		alpha = math.Clamp(alpha, 0, 1)
		dtx = dtx * alpha * alpha
	end
	local amount = 0
	local build_delay = .4
	local build_done = false
	local cv_total = false
	if not payout then dt = dt + 1 end
	if dt > build_delay then
		--Calculate payout amount based on bracket timescale
		local timeScale = state.timescale
		local build_dt = (dt - build_delay) * timeScale
		local post_dt = (dt - build_delay) - (1 / timeScale)
		if not payout then
			--Skip payout if table is nil ( end of payouts )
			build_dt = 1
			post_dt = post_dt - 1
		end
		build_dt = math.Clamp(build_dt, 0, 1)
		post_dt = math.Clamp(post_dt * 1.5, 0, 1)
		amount = gmc * build_dt
		if build_dt < 1 then
			--Run the blip track
			if not state.blipstart then
				blipSoundPatch:PlayEx( .2, 100 )
				state.blipstart = CurTime()
			else
				if CurTime() - state.blipstart > blipDuration then
					state.blipstart = CurTime()
					blipSoundPatch:Stop()
					blipSoundPatch:Play()
				end
			end
		else
			--Stop blipping
			build_done = true
			blipSoundPatch:Stop()
			if state.kick == 2 then
				--Play this sound at the end of each payout bracket
				local sndid = state.currentPayout
				
				if sndid > #snd.brackets then sndid = #snd.brackets end
				
				if payout && !(state.currentPayout == #state.earnTable) then
					surface.PlaySound( snd.brackets[ sndid ] ) 
				end
				state.kick = state.kick + 1
				--Advance over current payout to display total
				if state.currentPayout == #state.earnTable then
					state.done = true
					state.fadeout = CurTime() + 2
					state.currentPayout = state.currentPayout + 1
					state.total = state.total + amount
   					cv_total = true
					surface.PlaySound( snd.brackets[ 8 ] ) 
					local pitch = math.Clamp( math.Fit( state.total, 1, 500, 90, 160 ), 90, 160 )
					LocalPlayer():EmitSound( "GModTower/misc/gmc_earn.wav", 100, math.ceil( pitch ) )
				end
			end
		end
		surface.SetDrawColor(0,0,0,50*build_dt)
		local expand = build_dt
		--[[if build_dt == 1 then
			--Expand effect when build complete
			local dt = math.Clamp(post_dt*3,0,1)
			local color = Scoreboard.Customization.ColorTabHighlight
			surface.SetDrawColor(color.r,color.g,color.b,255*(1-dt))
			expand = expand + dt * .1
		end]]				if build_dt == 1 then			--Expand effect when build complete			local dt = math.Clamp(post_dt*3,0,1)			local color = colorutil.Brighten( Color( 61, 102, 31, 255 ), 3 )			surface.SetDrawColor(color.r,color.g,color.b,255*(1-dt))			expand = expand + dt * .1		end
		--Draw bg effect
		surface.DrawRect(
			x + (width/2) * (1-expand),
			y + (height/2) * (1-expand),
			width * expand,
			height * expand)
		if post_dt == 1 then
			if state.currentPayout <= #state.earnTable then
				--Advance to next payout
				state.currentPayout = state.currentPayout + 1
				state.payoutStart = CurTime()
				state.total = state.total + amount
				cv_total = true
			end
		end
	end
	local total = state.total + amount
	amount = gmc - amount
	if cv_total then
		--Total has been tally'd display that instead of total + amount
		total = state.total
	end
	cy = cy + 10
	--Draw payout amount
	local amount_y_offset = -15
	local title_y_offset = 5
	local align = TEXT_ALIGN_RIGHT
	local font = "PayoutTitle"
	local str = string.format( "%0.0f", total)
	local po_y = cy + 50
	if build_done and state.done then
		--Change attributes for total text
		str = "   " .. str .. " GMC"
		align = TEXT_ALIGN_CENTER
		font = "PayoutFinal"
		po_y = cy + ( 1 - cosSinInterpolate( 1 - alpha, 2 ) ) * 40 + amount_y_offset
	end
	if build_done then
		--Center total text when done building total
		align = TEXT_ALIGN_CENTER
	end
	if payout then
		--Draw payout title
		draw.SimpleTextOutlined( 
			payout.Name, 
			"PayoutTitle",
			cx,
			cy - 60 + title_y_offset, 
			Color(255,255,255,dtx*255), 
			TEXT_ALIGN_CENTER, 
			TEXT_ALIGN_CENTER,
			2,
			Color(0,0,0,100*alpha)
		)
		--Draw payout description
		local ysub = 30
		for k,v in pairs( string.Explode('\n', payout.Desc) ) do
			draw.SimpleTextOutlined( 
				v, 
				"PayoutDescription",
				cx,
				cy - ysub + title_y_offset, 
				colorutil.TweenColor(Color(255,255,255), Color(253,200,40), 1-dtx, dtx*255), 
				TEXT_ALIGN_CENTER, 
				TEXT_ALIGN_CENTER,
				2,
				Color(0,0,0,100*alpha)
			)
			ysub = ysub - 20
		end
	end
	ysub = 10
	--Draw stacked payouts
	for i=state.currentPayout, 1, -1 do
		--Ignore current payout
		if i == state.currentPayout then continue end
		local p = state.earnTable[i]
		
		--Draw stacked payout name
		draw.SimpleTextOutlined( 
			p.payout.Name, 
			"PayoutDescription",
			x + 5,
			y - ysub, 
			Color(255,255,255,255*alpha), 
			TEXT_ALIGN_LEFT, 
			TEXT_ALIGN_CENTER,
			2,
			Color(0,0,0,100*alpha)
		)
		--Draw stacked payout amount
		draw.SimpleTextOutlined( 
			"" .. p.gmc, 
			"PayoutDescription",
			x + width - 5,
			y - ysub, 
			Color(255,255,255,255*alpha), 
			TEXT_ALIGN_RIGHT, 
			TEXT_ALIGN_CENTER,
			2,
			Color(0,0,0,100*alpha)
		)
		ysub = ysub + 20
	end
	if alpha ~= 1 then
		--Smooth fadeout
		alpha = ( 1 - cosSinInterpolate(1 - alpha, 10) )
	end
	--Draw total
	draw.SimpleTextOutlined( 
		str, 
		font,
		cx - 10,
		po_y + amount_y_offset,
		Color(255,255,255,255*alpha), 
		align, 
		TEXT_ALIGN_CENTER,
		2,
		Color(0,0,0,100*alpha)
	)
	if not build_done then
		--Draw amount added
		draw.SimpleTextOutlined( 
			"+" .. string.format( "%0.0f", amount ), 
			"PayoutTitle",
			cx + 10,
			cy + 50 + amount_y_offset,
			Color(253,200,40,255*alpha), 
			TEXT_ALIGN_LEFT, 
			TEXT_ALIGN_CENTER,
			2,
			Color(0,0,0,100*alpha)
		)
	end
end
function DrawPayoutDisplay()
	local set = PAYOUT_FRAME	
	if not state.run then return end
	if Scoreboard then
		PAYOUT_FRAME.BG_COLOR = Scoreboard.Customization.ColorTabInnerActive
	end
	local frame_width = set.WIDTH
	local frame_height = set.HEIGHT
	local startDT = (CurTime() - state.startTime) * 2
	if startDT > 2 and not state.payoutStart then
		state.payoutStart = CurTime()
	end
	--Play open sound
	if startDT > 1 and not state.opened then
		surface.PlaySound( snd.open )
		state.opened = true
	end
	--Smooth open effect
	startDT = cosSinInterpolate(startDT, 10)
	local alpha = math.Clamp(startDT, 0, 1)
	local brt = 255 * (1-alpha)
	if state.fadeout then
		alpha = 1 - (CurTime() - state.fadeout) / 3
		alpha = math.Clamp(alpha, 0, 1)
		if alpha == 0 then
			state.run = nil
		end
	end
	--Effect width using open interpolator
	frame_width = frame_width * startDT
	local x = 0 //set.X
	local y = set.Y
	local payout_offset = (state.currentPayout - 1) * 20
	local fy = y - payout_offset
	local f_height = frame_height + payout_offset
	--Copy bg color
	local col = Color(
		set.BG_COLOR.r,
		set.BG_COLOR.g,
		set.BG_COLOR.b,
		set.BG_COLOR.a
	)
	--Add some effects to color
	surface.SetDrawColor(
		col.r + brt,
		col.g + brt,
		col.b + brt,
		col.a * alpha)
	surface.SetTexture( gradient )
	surface.DrawTexturedRect( 
		x,
		fy,
		frame_width,
		f_height)

	--Draw background frame
	surface.DrawRect(
		x,
		fy,
		frame_width,
		f_height)
	--Draw seperator for payout stack
	if state.currentPayout ~= 1 then
		surface.SetDrawColor(0,0,0,100*alpha)
		surface.DrawRect(x,y,frame_width,2)
	end
	DrawPayoutMain( x, y, frame_width, frame_height )
end
local PANEL = {}
function PANEL:Init()
	self:SetPos( PAYOUT_FRAME.X, 0 )
	self:SetSize( PAYOUT_FRAME.WIDTH, ScrH() )
	self:SetMouseInputEnabled( false )
	self:SetKeyBoardInputEnabled( false )
	self:SetZPos( -100 )
end
function PANEL:Think()
	if not state.run then
		self:Remove()
	end
end
function PANEL:Paint( w, h )
	DrawPayoutDisplay()
end
vgui.Register( "PayoutPanel", PANEL )
function DisplayEarned( earned )
	// Start displaying GUI
	state = {}
	state.run = true
	state.startTime = CurTime()
	state.nextStat = state.startTime + 2
	state.earnTable = {}
	state.currentPayout = 1
	state.total = 0
	// Create VGUI to display the GUI
	if !ValidPanel( PayoutPanel ) then
		PayoutPanel = vgui.Create( "PayoutPanel" )
	end
	// Display in console
	Msg( "\n|\n| Payouts\n|\n" )
	local total = 0
	for id, gmc in pairs( earned ) do
		local payout = earned[id]		local gmc = earned[id].GMC
		table.insert( state.earnTable, {
			payout = payout,
			gmc = gmc,
		})
		Msg( "|   " .. payout.Name .. " (" .. gmc ..")\n" )
		total = total + gmc
	end
	MsgN( "|\n\\__[ Total: " .. total .. " GMC ]" )

	// Sort them
	table.sort( state.earnTable, function(a,b) 
		if a.payout.Diff < b.payout.Diff then return true end		
		return false
	end )
end