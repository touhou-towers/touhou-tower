local PANEL = {}
local COLOR = Color( 255, 255, 255, 255 )
local OUTLINECOLOR = Color( 0, 0, 0, 255 )

// HOLY SHIT DO NOT REORDER THESE!!!
// YOU WILL BREAK EVERYTHING SOHFSIGHISADHVODAubgsfgH
HudMessages =
{
	"Invalid Hud Message", // 1
	"You are the last survivor!",
	"The last survivor is %s!", // 3
	"This is the last round!",
	"15 seconds remaining!", // 5
	"5", "4", "3", "2", "1",
	"The infection has spread!", // 11
	"The survivors have won!",
	"%s has infected you!", // 13
	"You are the first to join, waiting for additional players!",
	"Waiting for additional players!",
	"%s has been infected!", // 16
	"%s was infected by %s!", 
	"The last infected has left. Another victim will be found...", // 18
	"The infected has become enraged!", // 19
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
	self.Font = "ImpactHud"

end

//Check http://wiki.garrysmod.com/?title=Markup.Parse for details
function PANEL:SetText( text, font, color )

	self.Font = font or "ImpactHud"
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
	
	if ( self.IgnoreY ) then
		messageNum = 1
	end
	
	local PosY = self:CenterY() + ( ( ScrH() / 20 ) * ( 1 + messageNum ) )

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

vgui.Register("virus_HudMessage", PANEL )



local function ClientHudMsg( um )

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
	if ( index == 3 || index == 13 || index == 16 ) then
	
		local playerName = "invalid player"
		if IsValid( ent ) && ent:IsPlayer() then
			playerName = ent:GetName()
		end
		
		message = string.format( message, playerName )
		
	elseif ( index == 17 ) then
	
		local player1 = "invalid player"
		local player2 = "invalid player"
		
		if IsValid( ent ) && ent:IsPlayer() then
			player1 = ent:GetName()
		end
		
		if IsValid( ent2 ) && ent2:IsPlayer() then
			player2 = ent2:GetName()
		end
		
		message = string.format( message, player1, player2 )
		
	end

	if index == 11 then
		surface.PlaySound( "GModTower/virus/announce_infectedwin.wav" )
	elseif index == 12 then
		surface.PlaySound( "GModTower/virus/announce_survivorswin.wav" )
	end

	if index == 2 then
		surface.PlaySound( "GModTower/virus/announce_lastchance.wav" )
	end
	
	HudMessage( message, time or 10, nil, nil, color )
	
end

usermessage.Hook( "HudMsg", ClientHudMsg )