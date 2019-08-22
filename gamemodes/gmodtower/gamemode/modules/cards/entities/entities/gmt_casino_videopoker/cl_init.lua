
-----------------------------------------------------
include("shared.lua")
include( "marquee.lua" )

function ENT:Initialize()

	self.Jackpot = 0
	self.Marquee = marquee.New( 27, 0.1 )
	self.Marquee.Index = math.random( 1, 3 )
	function self.Marquee:Draw( text, x, y )
		draw.SimpleText( string.rep( "8", string.len( text ) ), "poker_jackpot_1", x, y, Color( 40,40,40,100 ), 1 )
		draw.SimpleText( text, "poker_jackpot_1", x, y, Color( 255, 0, 0 ), 1 )
	end

end

local BG, FG, RED = Color( 25, 15, 38 ), Color( 180, 185, 90 ), Color( 175, 35, 25 )

local FontSizes = { 12, 24, 32, 48, 64, 96, 18 }
for k, v in pairs( FontSizes ) do
	surface.CreateFont( "poker_" .. k, {
		//font = "Calibri",
		font = "Tahoma",
		size = v,
		weight = k == 5 and 800 or ( k == 1 or k == 7 ) and 800 or 500
	} )
end
surface.CreateFont( "poker_jackpot_1", {
	font = "Digital-7 Mono",
	size = 32,
	weight = 500
} )
surface.CreateFont( "poker_jackpot_2", {
	font = "Digital-7 Mono",
	size = 85,
	weight = 500
} )
/*
function ENT:DrawCard( x, y, w, value, suit )
	if !suit then
		suit = value.suit
		value = value.value
	end
	local h = w * 1.443
	draw.RoundedBox( 4, x, y, w, h, Color( 0, 0, 0 ) )
	draw.RoundedBox( 4, x + 2, y + 2, w - 4, h - 4, Color( 255, 255, 255 ) )
	local v = { 'A', [11] = 'J', [12] = 'Q', [13] = 'K' }
	local s = { '♦', '♥', '♣', '♠' }
	local col = Color( 0, 0, 0 )
	if suit < 3 then
		col = Color( 255, 0, 0 )
	end
	local Text = ( value != 1 and value < 11 and value or v[value] ) .. "\n" .. s[suit]
	surface.SetFont( "poker_3" )
	local w2, h2 = surface.GetTextSize( Text )
	draw.DrawText( Text, "poker_3", x + w / 2, y + h / 2 - h2 / 2, col, TEXT_ALIGN_CENTER )

end
*/

local Materials = {}
for suit = 1, 4 do
	local ls = { "diamonds", "hearts", "clubs", "spades" }
	Materials[ suit ] = CreateMaterial( "cards_" .. ls[suit], "UnlitGeneric", {
		["$basetexture"] = "models/gmod_tower/casino/cards/cards_" .. ls[suit] .. ".vtf",
		["$ignorez"] = 1,
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
		["$nolod"] = 1,
		//["$basetextureoffset"] = "[" .. num .. " 0]",
		//["$basetexturetransform"] = "center .5 .5 scale 1 1 rotate 0 translate " .. num .. " 0",
	} )
end
function ENT:DrawCard( x, y, w, value, suit )

	if !suit then
		suit = value.suit
		value = value.value
	end
	if value == 1 then value = 0
	elseif value == 14 then value = 1 end
	local h = w * 1.443
	x, y, w, h = math.Round( x ), math.Round( y ), math.Round( w ), math.Round( h )
	draw.RoundedBox( 2, x, y, w, h, Color( 0, 0, 0 ) )
	surface.SetMaterial( Materials[ suit ] or Materials[ 1 ] )
	local back = ( value == 0 or suit == 0 ) and 0.445 or 0
	value = back > 0 and 1 or value
	local mult = 0.07674 * ( value - 1 ) 
	surface.SetDrawColor( 255, 255, 255 )
	surface.DrawTexturedRectUV( x + 1, y + 1, w - 2, h - 2, mult + 0.001, 0.01 + back, 0.078 + mult, 0.456 + back )
	//surface.DrawTexturedRectUV( x, y, w, h, 0.001, 0.01, 1 / 13 + 0.001, 0.456 )

end

function draw.OutlineText( text, font, x, y, color, outcolor, outsize, ax, ay )

	outcolor = outcolor or Color( 0, 0, 0 )
	outsize = outsize or 1
	for x2 = -1, 1, 1 do
		for y2 = -1, 1, 1 do
			draw.SimpleText( text, font, x + x2 * outsize, y + y2 * outsize, outcolor, ax, ay )
		end
	end
	draw.SimpleText( text, font, x, y, color, ax, ay )

end

ENT.mX, ENT.mY = -99999, -99999

local function RayQuadIntersect(vOrigin, vDirection, vPlane, vX, vY)
	local vp = vDirection:Cross(vY)
	local d = vX:DotProduct(vp)
	if (d <= 0.0) then return end
	local vt = vOrigin - vPlane
	local u = vt:DotProduct(vp)
	if (u < 0.0 or u > d) then return end
	local v = vDirection:DotProduct(vt:Cross(vX))
	if (v < 0.0 or v > d) then return end
	return Vector(u / d, v / d, 0)
end
function ENT:MouseRayInteresct( pos, ang, w, h )
	local plane = pos + ( ang:Forward() * ( ( w or self.Width ) / 2 / 2 ) ) + ( ang:Right() * ( ( h or self.Height ) / 2 / -2 ) )
	local x = ( ang:Forward() * -( ( w or self.Width ) / 2 ) )
	local y = ( ang:Right() * ( ( h or self.Height ) / 2 ) )
	return RayQuadIntersect( EyePos(), LocalPlayer():GetAimVector(), plane, x, y )
end
function ENT:GetCursorPos( pos, ang, scale, w, h )
	//if self:GetPlayer() != LocalPlayer() then return -99999, -99999 end
	scale = scale or self.Scale
	//print( "Checking is cursor is on", pos, ang, scale, w, h )
	//debug.Trace()
	local uv = self:MouseRayInteresct( pos, ang, w, h )
	if uv then
		local x,y = (( 0.5 - uv.x ) * ( ( w or self.Width ) / 2 )), (( uv.y - 0.5 ) * ( ( h or self.Height ) / 2 ) )
		return (x / scale), (y / scale)
	else
		//print( "Failed to get pos from ", pos, ang, scale, w, h )
	end
end
function ENT:MouseOn( x, y, w, h )

	local mx, my = self.mX, self.mY
	return ( mx >= x && mx <= (x+w) ) && (my >= y && my <= (y+h))

end

function ENT:DrawCursor( cur_x, cur_y )
	local cursorSize = 32
	surface.SetTexture( Cursor2D )
	if input.IsMouseDown( MOUSE_LEFT ) then
		cursorSize = 28
		surface.SetDrawColor( 255, 150, 150, 255 )
	else
		surface.SetDrawColor( 255, 255, 255, 255 )
	end
	local offset = cursorSize / 2
	surface.DrawTexturedRect( cur_x - offset + 15, cur_y - offset + 15, cursorSize, cursorSize )
	//draw.DrawText( math.Round( cur_x, 2 ) .. ", " .. math.Round( cur_y, 2 ), "poker_1", cur_x + 15, cur_y + 15, Color( 255, 0, 0 ) )
end


local buttonPressed, buttonFunc, bPressTime, bPressTime2

local EntData = {}

hook.Add( "PlayerBindPress", "VideoPokerClick", function( ply, bind, pressed )

	local self = EntData.Entity
	local pos, ang, scale = EntData.Pos, EntData.Ang, EntData.Scale
	if IsValid( self ) then

		//debugoverlay.Axis( pos, ang, 2, 5, true )
		local ply=LocalPlayer()
		if pos and ang and scale then

			local cx, cy = self:GetCursorPos(pos,ang,scale, EntData.Width, EntData.Height)
			local pos = {
				x = cx,
				y = cy
			}
			if not (pos.x and pos.y) then pos.x=-999999 pos.y=-999999 end
			local function mouseon(x,y,w,h)
				return ( pos.x >= x && pos.x <= (x+w) ) && (pos.y >= y && pos.y <= (y+h))
			end
			local function mob(button)
				if button.circle then
					return math.Distance(button.x,button.y,pos.x,pos.y)<=button.radius //mouseon(button.x-button.radius,button.y-button.radius,button.radius*2,button.radius*2)
				else
					return mouseon(button.x,button.y,button.w,button.h)
				end
			end

			if ply == LocalPlayer() and bind == "+attack" then

				//PrintTable( EntData.Buttons )
				for k, b in pairs( EntData.Buttons ) do

					if mob( b ) and b.func then

						b.func( self )

					end

				end

			end

		end

	end

end )

function ENT:DrawButtons( pos, ang, scale, Buttons, setData )

	// Draw buttons
	if setData then
		EntData.Entity = self
		//EntData.Width = self.Width
		//EntData.Height = self.Height
	end
	local ply=LocalPlayer()
	local pos={self:GetCursorPos(pos,ang,scale, EntData.Width, EntData.Height)}
	pos.x=pos[1]
	pos.y=pos[2]
	if not (pos.x and pos.y) then pos.x=-999999 pos.y=-999999 end
	local function mouseon(x,y,w,h)
		return ( pos.x >= x && pos.x <= (x+w) ) && (pos.y >= y && pos.y <= (y+h))
	end
	local function mob(button)
		if button.circle then
			return math.Distance(button.x,button.y,pos.x,pos.y)<=button.radius //mouseon(button.x-button.radius,button.y-button.radius,button.radius*2,button.radius*2)
		else
			return mouseon(button.x,button.y,button.w,button.h)
		end
	end
	for k,b in pairs(Buttons)do
		local tw, th
		if b.text then
			surface.SetFont( b.font or "poker_1" )
			tw, th = surface.GetTextSize( b.text )
			if !b.w then
				b.w = tw
			end
			if !b.h then
				b.h = th
			end
		end
		local on=b.hcol or Color(b.col.r*.6,b.col.g*.6,b.col.b*.6,b.col.a)
		local p=b.hcol and Color( b.hcol.r * 0.8, b.hcol.g * 0.8, b.hcol.b * 0.8, b.hcol.a ) or Color(b.col.r*.8,b.col.g*.8,b.col.b*.8,b.col.a)
		if b.border then
			local bs=b.bordersize or 2
			if b.circle then
				draw.FilledCircle(b.x,b.y,b.radius+bs,32,b.border)
			else
				draw.RoundedBox((b.corner or 2),b.x-bs,b.y-bs,b.w+bs*2,b.h+bs*2,b.border)
			end
		end
		if b.circle then
			draw.FilledCircle(b.x,b.y,b.radius,32,(ply:KeyDown( IN_ATTACK ) and mob( b ) and p or (mob(b) and on) or b.col))
		else
			draw.RoundedBox((b.corner or 2),b.x,b.y,b.w,b.h,(ply:KeyDown( IN_ATTACK ) and mob( b ) and p or (mob(b) and on) or b.col))
		end
		if b.text then
			if b.circle then
				draw.DrawText(b.text,b.font or "poker_1",b.x,b.y + b.h / 2 - th / 2,b.tcol or Color(255,255,255),TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				draw.DrawText(b.text,b.font or "poker_1",b.x+b.w/2,b.y+b.h/2 - th / 2,b.tcol or Color(255,255,255),TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end
	for k,v in pairs(self.Text)do
		//draw.DrawText(v.text,v.font or "Default",v.x,v.y,(v.col or Color(255,255,255)),TEXT_ALIGN_CENTER)
	end

end

/*
button template
{
	x = 0,
	y = 0,
	w = 0,
	h = 0,
	col = Color( 0, 0, 0 ),
	text = "",
	font = "fontname",
	border = Color( 0, 0, 0 ),
	bordersize = 2,
	tcol = Color( 255, 255, 255 ),
	circle = false,
	sound = "path.wav",
	radius = 2,
	func = function()
	end
}
text template
{
	x = 0,
	y = 0,
	col = Color( 0, 0, 0 ),
	text = "",
	font = "fontname",
}
*/
ENT.Buttons = {}
ENT.Text = {
	
}
ENT.Width = 350
ENT.Height = 350
ENT.Scale = 0.035
function ENT:DrawTranslucent()

	// statistics
	local Data = {
		"Welcome to the tower casino!",
		"This machine's jackpot is being displayed below (in credits). In GMC, it is worth: " .. string.Comma( self:GetJackpot() * self.GMCPerCredit ) .. " GMC.",
		self.GMCPerCredit .. " GMC = 1 credit"
	}
	if #self:GetLastPlayer() > 0 then
		table.insert( Data, "The last player that played this machine was: " .. self:GetLastPlayer() .. " who " .. ( self:GetLastPlayerValue() < 0 and "lost" or "profited" ) .. " " .. string.Comma( math.abs( self:GetLastPlayerValue() ) ) .. " GMC from their session" )
	end
	if #self:GetLastJackpot() > 0 then
		table.insert( Data, "The last player that won the jackpot on this machine was: " .. self:GetLastJackpot() .. " who won " .. string.Comma( self:GetLastJackpotValue() ) .. " GMC" )
	end
	if #self:GetMostGMCSpent() > 0 then
		table.insert( Data, "The player that spent the most GMC on this machine was: " .. self:GetMostGMCSpent() .. " who spent " .. string.Comma( self:GetMostGMCSpentValue() ) .. " GMC" )
	end
	self.Marquee:SetData( Data )

	local pos, ang = self:GetPos(), self:GetAngles()

	ang:RotateAroundAxis( self:GetRight(), -90 )
	ang:RotateAroundAxis( self:GetForward(), 90 )

	pos = pos + self:GetUp() * 49.5 + self:GetForward() * 14.75
	cam.Start3D2D( pos, ang, 0.04 )

		ErrorTrace.Call( function()
			surface.SetFont( "poker_5" )
			local Text = string.Comma( self:GetJackpot() )
			Text = string.rep( " ", 10 - #Text ) .. Text
			local w2, h2 = surface.GetTextSize( Text )
			w2 = 250 + 96
			local w, h = w2 + 80, 100
			draw.RoundedBox( 8, w / -2, h / -2, w, h, Color( 40, 0, 0 ) )
			self.Marquee:SetPos( 0, h / -2 )
			marquee.Draw( self.Marquee )
			--draw.SimpleText( "8888888", "poker_jackpot_1", 0, h / -2, Color( 40, 40, 40, 100 ), 1 )
			--draw.SimpleText( "JACKPOT", "poker_jackpot_1", 0, h / -2, Color( 255, 0, 0 ), 1 )
			local digits = string.rep( "8", #Text )
			draw.SimpleText( digits, "poker_jackpot_2", 0, 0 - h2 / 2, Color( 40, 40, 40, 100 ), 1 )
			draw.SimpleText( Text, "poker_jackpot_2", 0, 0 - h2 / 2, Color( 255, 0, 0 ), TEXT_ALIGN_CENTER )
		end )

	cam.End3D2D()

	pos = self:GetPos()
	ang:RotateAroundAxis( self:GetRight(), 10 )
	pos = pos + self:GetUp() * 60 + self:GetForward() * 9.6 + self:GetRight() * 1 + ang:Right() * 0.4 + ang:Up() * 0.2
	local pos2 = pos:ToScreen()
	//local DrawScreen = LocalPlayer():EyePos():Distance( pos ) < 50 or math.Distance( ScrW() / 2, ScrH() / 2, pos2.x, pos2.y ) < 100 / ( math.Clamp( LocalPlayer():EyePos():Distance( pos ) / 200, 0, 1 ) * 10 )and pos2.visible or LocalPlayer():EyePos():Distance( pos ) < 50

	//self.Buttons2[1].text = self:GetState() == self.States.DISCARD and "DRAW" or "DEAL"

	self.Width = 350
	self.Height = 350
	self.Scale = 0.035
	local w, h = self.Width, self.Height

	local cx, cy, CursorVisible = 0, 0, false
	cx, cy = self:GetCursorPos( pos, ang )
	self.mX, self.mY = cx or -99999, cy or -99999
	if cx and self:MouseOn( w / -2, h / -2, w, h ) then CursorVisible = true end
	local DrawScreen = self:GetPlayer() == LocalPlayer() or LocalPlayer():EyePos():Distance( pos ) < 100 or CursorVisible

	cam.Start3D2D( pos, ang, self.Scale )

		ErrorTrace.Call( function()

			if self:GetPlayer() != LocalPlayer() then
				cx = -99999
				cy = -99999
				self.mX = cx
				self.mY = cy
			end

			if DrawScreen then

				surface.SetDrawColor( Color( 0, 0, 128 ) )
				surface.DrawRect( -self.Width / 2 - 50, -self.Height / 2 - 50, self.Width + 100, self.Height + 100 )

				local function MainText( text, x, y, ax, ay )
					draw.SimpleTextOutlined( text, "poker_2", x + 2, y + 2, Color( 0, 0, 0 ), ax, ay, 1, Color( 0, 0, 0 ) )
					draw.SimpleTextOutlined( text, "poker_2", x , y, RED, ax, ay, 1, FG )
				end

				for i = 1, 13 do
					self.Buttons[ i ] = nil
				end
				if self:GetState() == self.States.IDLE then

					MainText( "VIDEO POKER", 0, -40, TEXT_ALIGN_CENTER )

					surface.SetDrawColor( Color( 0, 0, 0 ) )
					surface.DrawRect( -70 + 1, -15 + 1, 142, 3 )

					surface.SetDrawColor( FG )
					surface.DrawRect( -70 - 1, -15 - 1, 140 + 2, 1 + 2 )

					surface.SetDrawColor( RED )
					surface.DrawRect( -70, -15, 140, 1 )

					MainText( "JACKS OR BETTER", 0, 0, 1 )

					MainText( self.GMCPerCredit .. " GMC = 1 CREDIT", 0, 50, 1 )
					MainText( "SIT TO PLAY", 0, 77, 1 )

				elseif self:GetState() == self.States.BEGIN then

					for y = 1, 3 do
						for x = 1, 3 do
							self.Buttons[ ( y - 1 ) * 3 + x ] = {
								x = -100 + ( x - 2 ) * 30 - 10,
								y = -20 + y * 30 + 0,
								w = 20,
								h = 20,
								text = ( y - 1 ) * 3 + x,
								tcol = FG,
								font = "poker_7",
								col = Color( FG.r / 2, FG.g / 2, FG.b / 2 ),
								border = FG,
								bordersize = 2,
								func = function( ent )
									RunConsoleCommand( "videopoker_credit", ( y - 1 ) * 3 + x )
								end,
								//sound = "gmod_tower/casino/videopoker/click.wav",
							}
						end
					end
					self.Buttons[ 10 ] = {
						x = -140,
						y = 70 + 30,
						w = 20,
						h = 20,
						text = "X",
						tcol = RED,
						font = "poker_7",
						col = Color( RED.r / 3, RED.g / 3, RED.b / 3 ),
						border = RED,
						bordersize = 2,
						func = function( ent )
							RunConsoleCommand( "videopoker_credit", "delete" )
						end,
						//sound = "gmod_tower/casino/videopoker/click.wav",
					}
					self.Buttons[ 11 ] = {
						x = -110,
						y = 70 + 30,
						w = 20,
						h = 20,
						text = "0",
						tcol = FG,
						font = "poker_7",
						col = Color( FG.r / 2, FG.g / 2, FG.b / 2 ),
						border = FG,
						bordersize = 2,
						func = function( ent )
							RunConsoleCommand( "videopoker_credit", 0 )
						end,
						//sound = "gmod_tower/casino/videopoker/click.wav",
					}
					self.Buttons[ 12 ] = {
						x = -80,
						y = 70 + 30,
						w = 20,
						h = 20,
						col = Color( 0, 66, 0 ),
						border = Color( 0, 200, 0 ),
						bordersize = 2,
						func = function( ent )
							ent.Cool = nil
							RunConsoleCommand( "videopoker_credit", "start" )
						end,
					}
					if CursorVisible and self:GetPlayer() == LocalPlayer() then
						EntData.Entity = self
						EntData.Pos = pos
						EntData.Ang = ang
						EntData.Width = self.Width
						EntData.Height = self.Height
						EntData.Scale = self.Scale
						EntData.Buttons = table.Copy( self.Buttons )
					end
					MainText( "ENTER CREDITS TO START WITH", 0, -50, 1 )

					draw.RoundedBox( 0, -40 - 2, 10 - 2 + 30, 200 + 4, 24 + 4, RED )
					draw.RoundedBox( 0, -40, 10 + 30, 200, 24, Color( 255, 255, 255 ) )

					draw.DrawText( self:GetBeginCredits() .. ( CurTime() % 1 > 0.5 and "" or "|" ), "poker_2", -35, 10 + 30, Color( 0, 0, 0 ) )
					MainText( string.Comma( self:GetBeginCredits() * self.GMCPerCredit ) .. " GMC", w / 2 + 24, 117, TEXT_ALIGN_RIGHT )

				else

					local hand = self.Hand
					if ( !hand or hand:ToInt() != self:GetHandInternal() ) and self:GetHandInternal() > 0 then
						hand = Cards.Hand():FromInt( self:GetHandInternal() )
						local scored = hand:Evaluate()
						self.Scored = scored.hand
						//self.Scored = Cards.rankstrings[ scored.hand ] .. " (" .. Cards.cardstrings[ scored.score ] .. " High)"
					end
					if hand and #hand.cards == 5 then
						for i = 1, 5 do

							if self:GetHeld()[i] then
								draw.SimpleTextOutlined( "HELD", "poker_1", 84 * ( i - 3 ) + 2.5, -28 - 0, Color( 255, 255, 255 ), 1, nil, 2, Color( 0, 0, 0 ) )
							end
							self:DrawCard( 84 * ( i - 3 ) - 37.5, -5 - 8, 80 , hand.cards[i].value, hand.cards[i].suit )

						end
					else

						draw.SimpleTextOutlined( "Start a new game!", "poker_4", 0, math.sin( CurTime() * 3 ) * 10 + -15, Color( 255, 255, 255 ), 1, nil, 2, Color( 0, 0, 0 ) )
						draw.SimpleTextOutlined( "(Set your bet then hit deal!)", "poker_2", 0, math.sin( CurTime() * 3 ) * 10 + 35, Color( 255, 255, 255 ), 1, nil, 2, Color( 0, 0, 0 ) )
						draw.SimpleTextOutlined( "Your bet affects what you win.", "poker_2", 0, -55, Color(255,255,255), 1, nil, 2, Color(0,0,0) )
						draw.SimpleTextOutlined( "(you are currently betting " .. self:GetBet() .. " credit" .. ( self:GetBet() == 1 and "" or "s" ) .. ")", "poker_7", 0, -34, Color(255,255,255), 1, nil, 2, Color(0,0,0) )

					end
					//draw.SimpleTextOutlined( self.Scored or "", "poker_3", 0, -6, Color( 255, 255, 255 ), 1, nil, 1, Color( 0, 0, 0 ) )
					MainText( "BET " .. self:GetBet(), 0, 147, 1 )
					//draw.SimpleTextOutlined( "BET " .. self:GetBet(), "poker_2", 0, 137, Color( 255, 255, 255 ), 1, nil, 1, Color( 0, 0, 0 ) )
					MainText( string.upper( self:GetStateName( self:GetState() ) ), 0, 100, 1 )
					//draw.SimpleTextOutlined( string.upper( self:GetStateName( self:GetState() ) ), "poker_1", 0, 157, Color( 255, 255, 255 ), 1, nil, 1, Color( 0, 0, 0 ) )

					MainText( "CREDIT " .. self:GetCredits(), w / 2 + 24, 147, TEXT_ALIGN_RIGHT )
					MainText( "PROFIT " .. self:GetProfit(), w / 2 + 24, 117, TEXT_ALIGN_RIGHT )

					if self:GetScore() > 1 then

						MainText( string.upper( self.Prizes[ self:GetScore() ].Name ), 0, -55, 1 )
						if self:GetState() == self.States.NOPLAY then
							local Score = self.Prizes[self:GetScore()][self:GetBet()]
							if Score == -1 then Score = "JACKPOT" end
							MainText( "WIN " .. Score, w / -2 - 24, 147 )
						end

					end

				end

				do
					// prizes
					local w2, h2 = w, h
					local w, h = w - 00, 110
					local x, y = w / -2, h2 / -2 + 10
					draw.RoundedBox( 0, x, y, w, h, BG )
					draw.RoundedBox( 0, x + 2, y + 2, w - 4, h - 4, FG )
					draw.RoundedBox( 0, x + 4, y + 4, 110, h - 8, BG )
					x = x + 4
					y = y + 4
					w = w - 8
					h = h - 8
					/*
					draw.RoundedBox( 0, x + 150, y, 2, h, FG )
					draw.RoundedBox( 0, x + 190, y, 2, h, FG )
					draw.RoundedBox( 0, x + 230, y, 2, h, FG )
					draw.RoundedBox( 0, x + 270, y, 2, h, FG )*/
					for i = 1, 5 do
						// inside of each box
						//draw.RoundedBox( 0, x + 110 + 40 * ( i - 1 ), y, 2, h, FG )
						draw.RoundedBox( 0, x + 112 + 44 * ( i - 1 ), y, i == 5 and 53 or 42, h, self:GetBet() == i and RED or BG )
					end
					local Count = 0

					for i = 1, 11 do

						v = self.Prizes[i]
						if !v then continue end
						Count = Count + 1
						local Text = v.Name .. " "
						local OVERFLOW = 0
						surface.SetFont( "poker_1" )
						while OVERFLOW < 1000 do
							OVERFLOW = OVERFLOW + 1
							local w, h = surface.GetTextSize( Text )
							if w < 100 then
								//Text = Text .. ( i % 2 == 0 and "+" or "-" )
								Text = Text .. "-"
							else break end
						end
						local y2 = y + 6 + 10 * ( 9 - Count )
						draw.SimpleText( Text, "poker_1", x + 6, y2, self:GetScore() != i and FG or nil)
						local Rainbow = colorutil.Smooth( 2 )
						for i2 = 1, 4 do

							local Prize = v[i2]
							draw.SimpleText( Prize, "poker_1", x + 147 + 44 * ( i2 - 1 ) + 4, y2, self:GetScore() == i and self:GetBet() == i2 and Rainbow or self:GetScore() != i and FG or nil, TEXT_ALIGN_RIGHT)

						end
						local Prize = v[5]
						Prize = Prize == -1 and "JACKPOT" or Prize
						draw.SimpleText( Prize, "poker_1", w / 2 - 2, y2, self:GetScore() == i and self:GetBet() == 5 and Rainbow or self:GetScore() != i and FG or nil, TEXT_ALIGN_RIGHT )

					end
				end
				self:DrawButtons( pos, ang, self.Scale, self.Buttons, true )
				if CursorVisible then

					self:DrawCursor( cx - 10, cy - 7 )

				end
				local Percent = math.Clamp(
					math.TimeFraction( 80, 100, LocalPlayer():EyePos():Distance( pos ) ),
				0, 1 ) * 255
				surface.SetDrawColor( 0, 0, 0, Percent )
				surface.DrawRect( -self.Width / 2 - 50, -self.Height / 2 - 50, self.Width + 100, self.Height + 100 )

			else
				surface.SetDrawColor( 0, 0, 0 )
				surface.DrawRect( -self.Width / 2 - 50, -self.Height / 2 - 50, self.Width + 100, self.Height + 100 )
				--draw.SimpleText( "PLAY ME", "poker_5", 0, SinBetween(-50,50,CurTime()), Color( 255,255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, Color( 0,0,0 ) )
			end

		end, function( error, stack )

			surface.SetDrawColor( Color( 0, 0, 128, 128 ) )
			surface.DrawRect( -self.Width / 2 - 50, -self.Height / 2 - 50, self.Width + 100, self.Height + 100 )
			draw.SimpleTextOutlined( "ERROR", "poker_4", 0, -self.Height / 2, Color( 255,255, 255 ), TEXT_ALIGN_CENTER, nil, 2, Color( 0,0,0 ) )
			draw.SimpleTextOutlined( error, "poker_1", 0, -self.Height / 2 + 45, Color( 255,255,255 ), TEXT_ALIGN_CENTER, nil, 2, Color( 0,0,0 ) )
			local y = -self.Height / 2 + 65
			for k, v in pairs( stack ) do

				local text = k .. ".   " .. v
				local h = 15
				local lastSpace = 0
				local lines = {""}
				for i = 1, #text do

					local sub, char = lines[#lines], string.sub( text, i, i )
					if char == " " then
						lastSpace = i
					end
					local size = draw.GetTextSize( sub, "poker_1" )
					if size.w > self.Width then
						lines[#lines + 1] = char
						text = string.sub( text, 1, ( lastSpace == 0 and i or lastSpace ) - 1 ) .. ( lastSpace == 0 and "-" or "" ) .. "\n" .. string.sub( text, ( lastSpace == 0 and i or lastSpace + 1 ) )
					else
						lines[#lines] = lines[#lines] .. char
					end

				end
				h = draw.GetTextSize( text, "poker_1" ).h
				for i = 1, #lines do
					draw.SimpleTextOutlined( lines[i], "poker_1", 0, y + 12 * ( i - 1 ), Color( 255,255,255 ), TEXT_ALIGN_CENTER, nil, 2, Color( 0,0,0 ))
				end
				y = y + h + 10


			end

		end, "cl_init.lua" )

	cam.End3D2D()


	pos = self:GetPos()
	pos = pos + self:GetForward() * 13.3 + self:GetUp() * 52.37
	local ang = Angle( ang.p, ang.y, ang.r )
	ang:RotateAroundAxis( self:GetRight(), -10 + 75 )

	self.Width = 180
	self.Height = 24
	self.Scale = 0.1

	local mx, my = self:GetCursorPos( pos, ang, self.Scale, self.Width, self.Height )
	self.mX, self.mY = mx or -99999, my or -99999

	cam.Start3D2D( pos, ang, self.Scale )

		pcall(function()
		local w, h = self.Width, self.Height

		if mx and self:MouseOn( w / -2, h / -2, w, h ) and self:GetPlayer() == LocalPlayer() then

			//draw.RoundedBox( 0, w / -2, h / -2, w, h, Color(0,255,0,100) )

			EntData.Pos = pos
			EntData.Ang = ang
			EntData.Scale = self.Scale
			EntData.Buttons = self.Buttons2
			EntData.Width = w
			EntData.Height = h
			EntData.Entity = self
			self:DrawButtons( pos, ang, self.Scale, self.Buttons2 )
			self:DrawCursor( mx - 10, my - 7 )

		else

			//draw.RoundedBox( 0, w / -2, h / -2, w, h, Color(255,0,0,100) )

		end
		end)

	cam.End3D2D()

end

ENT.Buttons2 = {
	[51] = {
		x = 57 - 3,
		y = -6 - 2,
		w = 12 + 5,
		h = 12 + 4,
		corner = 0,
		col = Color( 0, 0, 0, 0 ),
		hcol = Color( 250, 85, 65, 200 ),
		func = function( ent )
			ent.Jackpot = ent:GetJackpot()
			RunConsoleCommand( "videopoker_draw" )
		end
	},
	[52] = {
		x = 33 - 2,
		y = -6 - 2,
		w = 12 + 5,
		h = 12 + 4,
		corner = 0,
		col = Color( 0, 0, 0, 0 ),
		hcol = Color( 250, 85, 65, 200 ),
		func = function( ent )
			RunConsoleCommand( "videopoker_bet", "max" )
		end
	},
	[53] = {
		x = 10 - 2,
		y = -6 - 2,
		w = 12 + 5,
		h = 12 + 4,
		corner = 0,
		col = Color( 0, 0, 0, 0 ),
		hcol = Color( 250, 85, 65, 200 ),
		func = function( ent )
			RunConsoleCommand( "videopoker_bet" )
		end
	},
	/*
	[53] = {
		x = -88,
		y = -6,
		w = 12,
		h = 12,
		corner = 0,
		col = Color( 0, 0, 0, 0 ),
		hcol = Color( 250, 85, 65, 100 ),
		func = function( ent )
			RunConsoleCommand( "videopoker_cashout", ent:EntIndex() )
		end
	}*/
}
for i = 1, 5 do
	ENT.Buttons2[53 + i] = {
		x = -88 + ( i - 1 ) * 18.9,
		y = -6,
		w = 12,
		h = 12,
		corner = 0,
		col = Color( 0, 0, 0, 0 ),
		hcol = Color( 250, 85, 65, 200 ),
		func = function()
			RunConsoleCommand( "videopoker_hold", i )
		end,
		//sound = "gmod_tower/casino/videopoker/click.wav"
	}
end
