
-----------------------------------------------------
local PANEL = {}
local COLOR = Color( 255, 255, 255, 255 )
local OUTLINECOLOR = Color( 0, 0, 0, 255 )
// HOLY SHIT DO NOT REORDER THESE!!!
// YOU WILL BREAK EVERYTHING SOHFSIGHISADHVODAubgsfgH
HudMessages =
{
	"HELICOPTER IS LANDING. YOU HAVE 15 SECONDS!", // 1
	"5", "4", "3", "2", "1",
	"%s HAS DIED", // 7
	"YOU HAVE SURVIVED",
	"THE ZOMBIES HAVE TAKEN OVER", // 9
	"THE DIFFICULTY HAS BEEN INCREASED",
	"WARNING: INCOMING BOSS!", // 11
}
//graph x * x * ( 3 - 2 * x ) from x = 0 to 1
//A nice fade in/face out effect
local function Bezel( Val )
	return Val * Val * ( 3 - 2 * Val )
end
local Messages = {}
function PANEL:Init()
	self.Text = nil
	self.MovingTime = 1.0
	self.StayTime = 3.0
	table.insert( Messages, self )
	self.CreatedTime = CurTime()
	self.Font = "ZomStatusAlt"
	self:SetMouseInputEnabled( false )
	self:MouseCapture( false )
end

//Check http://wiki.garrysmod.com/?title=Markup.Parse for details
function PANEL:SetText( text, font, color )
	self.Font = font or "ZomStatusAlt"
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
	local messageID = table.KeyFromValue( Messages, self )
	local messageNum = messageID
	if ( self.IgnoreY ) then
		messageNum = 1
	end
	local PosY = self:CenterY() + ( ( ScrH() / 20 ) * ( 1 + messageNum ) )
	if Life < self.MovingTime then
		local PosX = Lerp( Bezel( Life / self.MovingTime ), ScrW(), CenterX )
		self:SetPos( PosX, PosY )
	elseif Life < self.MovingTime + self.StayTime then
		self:SetPos( CenterX, PosY )
		if self.SinAlpha then
			self:SetAlpha( SinBetween( 0, 255, CurTime() * 4 ) )
		else
			self:SetAlpha( 255 )
		end
	elseif Life < self.MovingTime + self.StayTime + self.MovingTime then
		local MovingLife = Life - self.MovingTime - self.StayTime
		local PosX = Lerp( Bezel( MovingLife / self.MovingTime ), CenterX, 0 - self:GetWide() )
		self:SetPos( PosX, PosY )
	else
		self:Remove()
		table.remove( Messages, messageID )
	end
end

function PANEL:Paint()
	if self.Text then
		draw.SimpleTextOutlined( self.Text, self.Font, 5, 5, self.FontColor, nil, nil, 2, OUTLINECOLOR )
	end
end
vgui.Register( "HUDMessage", PANEL )
function HUDMessage( msg, seconds, font, ignoreY, color, index )
	local message = vgui.Create( "HUDMessage" )
	message:SetText( msg, font, color )
	message.StayTime = seconds
	message.IgnoreY = ignoreY or false
	message:SetVisible( true )
	if index == 11 then
		message.SinAlpha = true
	end

	Msg( msg .. "\n")
end
usermessage.Hook( "HUDMessage", function( um )
	local index = um:ReadChar()
	local time = um:ReadChar()
	local ent = um:ReadEntity()
	local ent2 = um:ReadEntity()
	local clrR = um:ReadShort()
	local clrG = um:ReadShort()
	local clrB = um:ReadShort()
	local clrA = um:ReadShort()
	local color = COLOR
	if ( clrA != 0 ) then
		color = Color( clrR, clrG, clrB, clrA )
	end
	local message = HudMessages[ index or 1 ]
	// these indexes use the entity parameter
	if index == 7 then
		local playerName = "invalid player"
		if IsValid( ent ) && ent:IsPlayer() then
			playerName = string.upper( ent:GetName() )

			if ent == LocalPlayer() then return end // don't display the message for them!
		end
		message = string.format( message, playerName )
	end
	if index == 11 then
		color = Color( 255, 0, 0 )
	end
	HUDMessage( message, time or 10, nil, nil, color, index )
end )
