local PANEL = {}
local COLOR = Color( 255, 255, 255, 255 )
local OUTLINECOLOR = Color( 0, 0, 0, 255 )

HudMessages = {
	[MSG_FIRSTJOIN] = "You are the first to join, waiting for additional players!",
	[MSG_WAITJOIN] = "Waiting for next round!",
	[MSG_UCSELECT] = "%s is The Ultimate Chimera!",
	[MSG_UCNOTIFY] = "You are the The Ultimate Chimera, eat the Pigmasks!",
	[MSG_PIGNOTIFY] = "You are a %s PigMask, turn off The Ultimate Chimera!",
	[MSG_PIGWIN] = "Pigmasks have conquered The Ultimate Chimera!",
	[MSG_UCWIN] = "The Ultimate Chimera has devoured all the Pigmasks!",
	[MSG_TIEGAME] = "Time's up!  Round draw!",
	[MSG_30SEC] = "Less than 30 seconds left!",
	[MSG_MRSATURN] = "Mr. Saturn has appeared!",
	[MSG_MRSATURNDEAD] = "Mr. Saturn has been eaten!",
	[MSG_ANGRYUC] = "The Ultimate Chimera has become enraged!",
}

//graph x * x * ( 3 - 2 * x ) from x = 0 to 1
//A nice fade in/face out effect
local function Bezel( Val )
	return Val * Val * ( 3 - 2 * Val )
end

local NumMessages = 0

function PANEL:Init()
	
	self.Text = nil
	self.MovingTime = 1.0
	self.StayTime = 3.0
	
	NumMessages = NumMessages + 1
	
	self.MessageNumber = NumMessages
	
	self.CreatedTime = CurTime()
	self.Font = "UCH_KillFont3"

end

//Check http://wiki.garrysmod.com/?title=Markup.Parse for details
function PANEL:SetText( text, font, color )

	self.Font = font or "UCH_KillFont3"
	self.FontColor = color or COLOR
	
	surface.SetFont( self.Font )
	
	local w, h = surface.GetTextSize( text )
	
	self.Text = text
	
	self:SetSize( w + 10, h + 10 )	
	self:SetPos( ScrW(), ScrH() / 2 - self:GetTall() / 2 )
	self:SetZPos( 10000 ) // OMFG DRAW ON TOP FFFFFF
	
end

function PANEL:CenterX()
	return ( ScrW() / 2 ) - ( self:GetWide() / 2 )
end

function PANEL:CenterY()
	return ( ScrH() / 2 ) - ( self:GetTall() / 2 )
end

function PANEL:Think()

	local Life = CurTime() - self.CreatedTime

	local CenterX = self:CenterX()
	local messageNum = self.MessageNumber
	
	if self.IgnoreY then
		messageNum = 1
	end
	
	local PosY = self:CenterY() + ( ScrH() / 20 ) * ( 1 + messageNum )

	if Life < self.MovingTime then

		local PosX = Lerp( Bezel( Life / self.MovingTime ), ScrW(), CenterX )

		self:SetPos( PosX, PosY )

	elseif Life < self.MovingTime + self.StayTime then

		self:SetPos( CenterX, PosY )

	elseif Life < self.MovingTime + self.StayTime + self.MovingTime then

		local MovingLife = Life - self.MovingTime - self.StayTime
		local PosX = Lerp( Bezel( MovingLife / self.MovingTime ), CenterX, 0 - self:GetWide() )

		self:SetPos( PosX, PosY )

	else

		self:Remove()
		
		NumMessages = NumMessages - 1

	end

end

function PANEL:Paint()
	
	if self.Text then
		draw.SimpleTextOutlined( self.Text, self.Font, 5, 5, self.FontColor, nil, nil, 2, OUTLINECOLOR )
	end
	
end
vgui.Register("UCH_HudMessage", PANEL )

function HudMessage( msg, seconds, font, ignoreY, color )
	
	local VguiMsg = vgui.Create( "UCH_HudMessage")
	
	VguiMsg:SetText( msg, font, color )
	VguiMsg.StayTime = seconds
	VguiMsg.IgnoreY = ignoreY or false
	VguiMsg:SetVisible( true )
	
	Msg( msg .. "\n")
end

local function ClientHudMsg( um )

	local index = um:ReadChar()
	local time = um:ReadChar()
	local ent = um:ReadEntity()
	local ent2 = um:ReadEntity()
	
	local clrR = um:ReadShort() or 255
	local clrG = um:ReadShort() or 255
	local clrB = um:ReadShort() or 255
	local clrA = um:ReadShort() or 255

	local color = COLOR
	if clrA != 0 then
		color = Color( clrR, clrG, clrB, clrA )
	end
	
	local message = HudMessages[ index or 1 ]

	if index == MSG_UCSELECT then
	
		local playerName = "invalid player"
		if IsValid( ent ) && ent:IsPlayer() then
			playerName = ent:GetName()
		end
		
		message = string.format( message, playerName )
		
	end
	
	if index == MSG_PIGNOTIFY then
		
		local rankName = ""
		if IsValid( ent ) && ent:IsPlayer() then
			rankName = ent:GetRankName()
		end

		message = string.format( message, rankName )

	end
	
	HudMessage( message, time or 10, nil, nil, color )
	
end

usermessage.Hook( "HudMsg", ClientHudMsg )