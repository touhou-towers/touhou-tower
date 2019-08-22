
-----------------------------------------------------
include("shared.lua")

module( "AntiAFK", package.seeall )

surface.CreateFont( "AFKTimer", { font = "Oswald", size = 48, weight = 400 } )
//surface.CreateFont( "ImpactType", { font = "Impact", size = 80, weight = 400 } )

EndTime = nil
StartTime = 0
TotalTime = 0
DermaPanel = DermaPanel or nil

/*usermessage.Hook( "GTAfk", function( um )

	local Id = um:ReadChar()

	if Id == 0 then

		EndTime = um:ReadLong()
		StartTime =  CurTime()
		TotalTime = EndTime - StartTime

		CreateWarning()

	elseif Id == 1 then

		RemoveWarning()
		EndTime = nil

	end

end )*/
net.Receive( "GTAfk", function( len )

	local Id = net.ReadInt( 4 )

	if Id == 0 then

		EndTime = net.ReadInt( 32 )
		StartTime = CurTime()
		TotalTime = EndTime - StartTime

		CreateWarning()

	elseif Id == 1 then

		RemoveWarning()
		EndTime = nil

	end

end )

local function AfkTimerThink()

	if ValidPanel( LocalPlayer().ActiveBrowser ) then return end
	if !ValidPanel( DermaPanel ) then return end

	local TimeLeft = ( EndTime or 0 ) - CurTime()
	local Sine = math.sin( math.fmod( TimeLeft, 1 ) * math.pi ) * 200

	DermaPanel.WarningLabel:SetColor( Color( 255, 255 - Sine, 255 - Sine, 255 ) )
	DermaPanel.WarningLabel:SetText( T("AfkTimer", math.max( math.Round( TimeLeft ), 0 ) ) )

	if TimeLeft <= 0 then
		if string.StartWith(game.GetMap(),"gmt_build") then
			DermaPanel.WarningLabel:SetText( T("AfkTimerMessageShort") )
		else
			DermaPanel.WarningLabel:SetText( T("AfkTimerMessage") )
		end
	end

	DermaPanel.WarningLabel:SizeToContents()
	DermaPanel.WarningLabel:Center()

end

local function AfkTimerPaint( panel )

	if ValidPanel( LocalPlayer().ActiveBrowser ) then return end

	local TimeLeft = math.Clamp( ( ( EndTime or 0 ) - CurTime() ) / TotalTime , 0, 1 )
	local W, H = panel:GetSize()

	local BarWidth = TimeLeft * W

	surface.SetDrawColor( 255, 0, 0, 255 )
	surface.DrawRect( 0, 0, BarWidth, H )

	surface.SetDrawColor( 255, 0, 0, 155 )
	surface.DrawRect( BarWidth, 0, W - BarWidth, H )

end

function CreateWarning()

	RemoveWarning()

	if ValidPanel( LocalPlayer().ActiveBrowser ) then return end

	DermaPanel = vgui.Create("DPanel")
	DermaPanel.WarningLabel = Label( T("AfkTimer", 30.0), DermaPanel )
	DermaPanel.WarningLabel:SetFont( "AFKTimer" )
	DermaPanel:SetMouseInputEnabled( false )
	DermaPanel:SetKeyBoardInputEnabled( false )

	DermaPanel.Think = AfkTimerThink
	DermaPanel.Paint = AfkTimerPaint

	AfkTimerThink()

	DermaPanel:SetAlpha( 200 )
	DermaPanel:SetSize( DermaPanel.WarningLabel:GetWide() * 2.0, DermaPanel.WarningLabel:GetTall() * 1.5 )
	DermaPanel:CenterVertical( 0.75 )
	DermaPanel:CenterHorizontal( 0.5 )

	AfkTimerThink()

end

function RemoveWarning()

	if ValidPanel( DermaPanel ) then
		DermaPanel:Remove()
	end

end

function ForceReset()

	net.Start( "ResetAFK" )
	net.SendToServer()

end

/*function DrawStatus( ply )

	if !ply:Alive() then return end

	local pos = ply:GetPos()
	local ang = LocalPlayer():EyeAngles()

	local override = hook.Call( "AFKDrawOverride", GAMEMODE, ply )
	if override then
		pos = override
	end

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )

	pos = pos + Vector( 0, 0, 80 )

	local dist = LocalPlayer():GetPos():Distance( ply:GetPos() )

	if ( dist >= 800 ) then return end // no need to draw anything if the player is far away

	local opacity = math.Clamp( 310.526 - ( 0.394737 * dist ), 0, 255 ) // woot mathematica

	cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.25 )

		draw.DrawText( "AFK", "ImpactType", -42, 2, Color( 0, 0, 0, opacity ) )
		draw.DrawText( "AFK", "ImpactType", -40, 0, Color( 255, 255, 255, opacity ) )

	cam.End3D2D()

end

hook.Add( "PostDrawTranslucentRenderables", "AFKStatusDraw", function()

	for _, ply in pairs( player.GetAll() ) do

		if ply.IsAFK && ply:IsAFK() then
			DrawStatus( ply )
		end

	end

end )*/
