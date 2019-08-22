
-- surface.CreateFont( "VoiceName", { font = "Oswald Bold", size = 32, weight = 500, antialias = true } )

local PlayerVoicePanels = {}

local PANEL = {}
PANEL.Margin = 2
PANEL.Padding = 6
PANEL.WaveyColor = Color(255,255,255,255)
PANEL.Font = "GTowerHudCSubText"

function PANEL:Init()

	self.Avatar = vgui.Create( "AvatarImage", self )
	self.Avatar:SetSize( 32, 32 )
	self.Avatar:SetPos( self.Padding / 2, self.Padding / 2 )

	self.Color = color_transparent

	self:SetSize( 250, 32 + self.Padding )
	self:DockPadding( 0, 0, 0, 0 )
	self:Dock( BOTTOM )

end

function PANEL:Setup( ply )

	self.ply = ply

	--if ply:IsHidden() then
	--	self.Avatar:SetPlayer( nil )
	--else
		self.Avatar:SetPlayer( ply )
	--end

	self.Color = Color(255,0,0)

	self:InvalidateLayout()

end

function PANEL:Paint( w, h )

	if ( !IsValid( self.ply ) ) then return end

	local nick = self.ply:Name()

	surface.SetFont( self.Font )
	local tw = surface.GetTextSize(nick)

	local halfheight = h/2
	local volume = self.ply:VoiceVolume()
	local freq = 2 * volume

	local rainbow = colorutil.Rainbow( 20 + volume * 30 )
	rainbow.r = rainbow.r * volume
	rainbow.g = rainbow.g * volume
	rainbow.b = rainbow.b * volume
	rainbow.a = 200

	w = 32 + 8*2 + tw

	local color = self.ply:GetPlayerColor() * 255
	color = Color( math.Clamp( color.r, 30, 180 ), math.Clamp( color.g, 30, 180 ), math.Clamp( color.b, 30, 180 ), 50 )
	draw.RoundedBox( 4, 0, 0, w, h, color )

	draw.RoundedBox( 4, 0, 0, w, h, rainbow )

	local x = 32 + 10

	draw.WaveyText( nick, self.Font, x, halfheight,
		self.WaveyColor, nil, TEXT_ALIGN_CENTER, volume * 10, 10, freq )

end

function PANEL:Think( )

	if ( self.fadeAnim ) then
		self.fadeAnim:Run()
	end

end

function PANEL:FadeOut( anim, delta, data )

	if ( anim.Finished ) then

		if ( IsValid( PlayerVoicePanels[ self.ply ] ) ) then
			PlayerVoicePanels[ self.ply ]:Remove()
			PlayerVoicePanels[ self.ply ] = nil
			return
		end

	return end

	self:SetAlpha( 255 - (255 * delta) )

end

derma.DefineControl( "VoiceNotify", "", PANEL, "DPanel" )



function GM:PlayerStartVoice( ply )


	if ( !IsValid( g_VoicePanelList ) ) then return end

	-- There'd be an exta one if voice_loopback is on, so remove it.
	GAMEMODE:PlayerEndVoice( ply )


	if ( IsValid( PlayerVoicePanels[ ply ] ) ) then

		if ( PlayerVoicePanels[ ply ].fadeAnim ) then
			PlayerVoicePanels[ ply ].fadeAnim:Stop()
			PlayerVoicePanels[ ply ].fadeAnim = nil
		end

		PlayerVoicePanels[ ply ]:SetAlpha( 255 )

		return;

	end

	if ( !IsValid( ply ) ) then return end

	local pnl = g_VoicePanelList:Add( "VoiceNotify" )
	pnl:Setup( ply )

	PlayerVoicePanels[ ply ] = pnl

end


local function VoiceClean()

	for k, v in pairs( PlayerVoicePanels ) do

		if ( !IsValid( k ) ) then
			GAMEMODE:PlayerEndVoice( k )
		end

	end

end

timer.Create( "VoiceClean", 10, 0, function()
	VoiceClean()
end)


function GM:PlayerEndVoice( ply )

	if ( IsValid( PlayerVoicePanels[ ply ] ) ) then

		if ( PlayerVoicePanels[ ply ].fadeAnim ) then return end

		PlayerVoicePanels[ ply ].fadeAnim = Derma_Anim( "FadeOut", PlayerVoicePanels[ ply ], PlayerVoicePanels[ ply ].FadeOut )
		PlayerVoicePanels[ ply ].fadeAnim:Start( 2 )

	end

end
