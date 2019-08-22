include("shared.lua")

local Color = Color
local CreateSound = CreateSound
local CurTime = CurTime
local draw = draw
local hook = hook
local LocalPlayer = LocalPlayer
local math = math
local net = net
local postman = postman
local ScrW = ScrW
local surface = surface
local tostring = tostring
local timer = timer
local GTowerChat = GTowerChat

module("minigames.fun")

local FunMeterEnabled = false
local FunPlayers = 0
local curFun = 0
local maxBarFun = 0

local EndLife1 = 0
local EndLife2 = 0
local EndLife3 = 0
local EndLife4 = 0

local HudFun1 = 0
local HudFun2 = 0
local HudFun3 = 0
local HudFun4 = 0

local RandX1 = 0
local RandY1 = 0
local RandX2 = 0
local RandY2 = 0
local RandX3= 0
local RandY3 = 0
local RandX4 = 0
local RandY4 = 0

local Music
local MusicLose

surface.CreateFont( "FunTitle", {
	font = "FOP Title Style Font", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 48,
	weight = 500,
	antialias = true,
	shadow = true,
	outline = true,
} )

surface.CreateFont( "FunHelp", {
	font = "Oswald", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 34,
	weight = 450,
	antialias = true,
	shadow = true,
} )

net.Receive("EndFun",function()
	local won = net.ReadBool()
	local delay = net.ReadInt(32)

	if won then
		surface.PlaySound("gmodtower/minigolf/effects/golfclap3.wav")
		surface.PlaySound("gmodtower/minigolf/effects/golfclap2.wav")
		surface.PlaySound("gmodtower/sourcekarts/effects/powerups/disco"..math.random(3,7)..".mp3")
	else
		StartBW()
		LoserMusic(true)

		local EndDelay = delay + 10

		timer.Simple(EndDelay,function() EndBW() LoserMusic(false) end)
	end
end)

net.Receive("AddFun",function()
	local AddedFun = net.ReadInt(32)
	curFun = curFun + AddedFun
	if AddedFun > 0 then
		if AddedFun == 1 then
			EndLife1 = CurTime() + 1
			HudFun1 = AddedFun
			RandX1 = math.random(ScrW()/4,ScrW()/4*3)
			RandY1 = math.random(50,75)
		elseif AddedFun == 2 then
			EndLife2 = CurTime() + 1
			HudFun2 = AddedFun
			RandX2 = math.random(ScrW()/4,ScrW()/4*3)
			RandY2 = math.random(50,75)
		elseif AddedFun == 5 then
			EndLife3 = CurTime() + 1
			HudFun3 = AddedFun
			RandX3 = math.random(ScrW()/4,ScrW()/4*3)
			RandY3 = math.random(50,75)
		elseif AddedFun == 10 then
			EndLife4 = CurTime() + 1
			HudFun4 = AddedFun
			RandX4 = math.random(ScrW()/4,ScrW()/4*3)
			RandY4 = math.random(50,75)
		end

		LocalPlayer():EmitSound("gmodtower/misc/payout/payout_start.wav",80,math.Rand(175,225))
	end
end)

net.Receive("FunMeterEnabled",function()
	if !net.ReadBool() then FunMeterEnabled = false return end
	FunMeterEnabled = true
	FunPlayers = net.ReadInt(8)
	curFun = (FunPlayers * FunPerPlayer) / 4
	maxBarFun = (FunPlayers * FunPerPlayer)
end)

net.Receive("PrintLeader",function()
	local leader = net.ReadString()
	local points = net.ReadInt(32)

	GTowerChat.Chat:AddText("The most fun player was "..leader.." with a score of "..points.." points!", Color(245, 65, 125, 255))

end)

net.Receive("FunBloom",function()
	local enabled = net.ReadBool()

	if enabled then
		StartBloom()
	else
		EndBloom()
	end
end)

net.Receive("ToggleMusic",function()
	if net.ReadBool() then
		Music = CreateSound( LocalPlayer(), "gmodtower/lobby/fun/fun_loop.wav" )
		Music:Play()
	else
		Music:FadeOut(1)
	end
end)

function LoserMusic(enabled)
	if enabled then
		MusicLose = CreateSound( LocalPlayer(), "gmodtower/lobby/fun/hell_loop.wav" )
		MusicLose:Play()
	else
		MusicLose:FadeOut(1)
	end
end

function DisplayRunFun()

	local x, y = ScrW() / 2, 80
	local w, h = ScrW() / 3, 20
	local x2, y2 = x-(w/2) + 2, y + 2
	local w2, h2 = w - 2 * 2, h - 2 * 2

	surface.SetFont( "GTowerSkyMsgSmall" )
	surface.SetTextColor( 0, 255, 0, math.max( (EndLife1-CurTime()) * 255, 0 ) )


	surface.SetTextPos( RandX1, y2 + RandY1 )
	surface.DrawText(  "+" .. tostring( HudFun1 ) )
end

function DisplayJumpFun()

	local x, y = ScrW() / 2, 80
	local w, h = ScrW() / 3, 20
	local x2, y2 = x-(w/2) + 2, y + 2
	local w2, h2 = w - 2 * 2, h - 2 * 2

	surface.SetFont( "GTowerSkyMsgSmall" )
	surface.SetTextColor( 0, 255, 0, math.max( (EndLife2-CurTime()) * 255, 0 ) )


	surface.SetTextPos( RandX2, y2 + RandY2 )
	surface.DrawText(  "+" .. tostring( HudFun2 ) )
end

function DisplayChatFun()

	local x, y = ScrW() / 2, 80
	local w, h = ScrW() / 3, 20
	local x2, y2 = x-(w/2) + 2, y + 2
	local w2, h2 = w - 2 * 2, h - 2 * 2

	surface.SetFont( "GTowerSkyMsgSmall" )
	surface.SetTextColor( 0, 255, 0, math.max( (EndLife3-CurTime()) * 255, 0 ) )


	surface.SetTextPos( RandX3, y2 + RandY3 )
	surface.DrawText(  "+" .. tostring( HudFun3 ) )
end

function DisplayDanceFun()

	local x, y = ScrW() / 2, 80
	local w, h = ScrW() / 3, 20
	local x2, y2 = x-(w/2) + 2, y + 2
	local w2, h2 = w - 2 * 2, h - 2 * 2

	surface.SetFont( "GTowerSkyMsgSmall" )
	surface.SetTextColor( 0, 255, 0, math.max( (EndLife4-CurTime()) * 255, 0 ) )


	surface.SetTextPos( RandX4, y2 + RandY4 )
	surface.DrawText(  "+" .. tostring( HudFun4 ) )
end

local gradientUp = surface.GetTextureID( "VGUI/gradient_up" )
local deltaVelocity = 0.08 -- [0-1]
local bw = 12 -- bar segment width
local padding = 2
local curPercent = nil

function DrawFunMeter()

	if !FunMeterEnabled then return end

	local maxFun = FunPlayers * FunPerPlayer

	local curFunBar = curFun
	-- Let's do some calculations first
	local curBarFun = math.floor( curFun / maxFun )

	if curFun % maxFun == 0 then
		curFunBar = curFunBar - 1
	end

	local percent = ( curFun - curBarFun * maxFun ) / maxFun
	curPercent = !curPercent and 1 or math.Approach( curPercent, percent, math.abs( curPercent - percent ) * 0.08 )

	local x, y = ScrW() / 2, 80
	local w, h = ScrW() / 3, 20

	-- Health bar background
	draw.RoundedBox( 4, x-(w/2), y, w, h + 15, Color( 0, 0, 0, 200 ) )
	draw.RoundedBox( 4, x-(w/2), y * 1.5, w, h + 15, Color( 0, 0, 0, 225 ) )
	draw.DrawText("JUMP | RUN | CHAT | DANCE | BUY","FunHelp",ScrW()/2 + math.sin(CurTime() * 2) * 48, y * 1.5,Color( 255, 255, 255, 255 ),1)

	-- Health bar
	//local color = ply:GetPlayerColor() * 255
	//color = Color( math.Clamp( color.r, 30, 255 ), math.Clamp( color.g, 30, 255 ), math.Clamp( color.b, 30, 255 ) )

	//local darkColor = Color( color.r - 25, color.g - 25, color.b - 25 )

	local x2, y2 = x-(w/2) + padding, y + padding
	local w2, h2 = w - padding * 2, h - padding * 2
	draw.RoundedBox( 4, x2, y2, w2, h2 + 15, Color(math.sin(CurTime()*2)*32 + 31, 31, 31), 50 )
	draw.RoundedBox( 0, x2, y2, w * curPercent - padding * 2, h2 + 15, Color(245, 65, 125) )

	draw.DrawText("FUN METER","FunTitle",ScrW()/2,10 - math.sin(CurTime() * 2) * 2,Color( 255, 255, 255, 255 ),1)

	surface.SetDrawColor( 0, 0, 0, 100 )
	surface.SetTexture( gradientUp )
	surface.DrawTexturedRect( x2, y2, w2, h2 + 15 )
end

function StartBloom()
	local layer = postman.NewColorLayer()
	layer.contrast = 1.10
	layer.color = 3.5
	postman.FadeColorIn( "puheadphones_on", layer, 0.2 )

	layer = postman.NewBloomLayer()
	layer.sizex = 7.5
	layer.sizey = 7.5
	layer.multiply = 0.3
	layer.color = 1.0
	layer.passes = 0.0
	layer.darken = 0.0
	postman.FadeBloomIn( "puheadphones_on", layer, 1 )

	layer = postman.NewSharpenLayer()
	layer.contrast = .15
	layer.distance = 3
	postman.FadeSharpenIn( "puheadphones_on", layer, 1.5 )
end

function EndBloom()
  postman.ForceColorFade( "puheadphones_on" )
  postman.FadeColorOut( "puheadphones_on", 1 )

  postman.ForceBloomFade( "puheadphones_on" )
  postman.FadeBloomOut( "puheadphones_on", 1 )

  postman.ForceSharpenFade( "puheadphones_on" )
  postman.FadeSharpenOut( "puheadphones_on", 1 )
end

function StartBW()
  local layer = postman.NewColorLayer()
  layer.contrast = 0.5
  layer.color = 0
  postman.FadeColorIn( "bw_on", layer, 0.2 )

  local layer = postman.NewMotionBlurLayer()
  layer.addalpha = 0.02
  layer.drawalpha = 0.8
  postman.FadeMotionBlurIn( "bw_blur", layer, 3 )

  layer = postman.NewSharpenLayer()
  layer.contrast = .5
  layer.distance = 3
  postman.FadeSharpenIn( "bw", layer, 1.5 )
end

function EndBW()
  postman.ForceColorFade( "bw_on" )
  postman.FadeColorOut( "bw_on", 1 )

  postman.ForceMotionBlurFade( "bw_blur" )
  postman.FadeMotionBlurOut( "bw_blur", 1 )

  postman.ForceSharpenFade( "bw" )
  postman.FadeSharpenOut( "bw", 1 )
end

hook.Add( "HUDPaint", "FunMeterDrawing", function()
  if FunMeterEnabled then
    DrawFunMeter()
    DisplayRunFun()
    DisplayJumpFun()
    DisplayChatFun()
    DisplayDanceFun()
  end
end)
