/*
-----------------------------------------------------

--Bring to localInfo to scope
local localInfo = localInfo_s

--Shapes
local circlePoly = polygon.New():Circle(80,64) --outer circle polygon
local circlePoly2 = polygon.New():Circle(70,64) --inner circle polygon

--Radial progress bar
local function DrawRadialProgress( frac, x, y, scale )

	--This is a low-poly mask that is used to hide parts of the progress bar
	local maskPoly = polygon.New():Circle(100,10,-90,360 * (1-frac))

	--Position elements
	circlePoly:SetPos( x, y )
	circlePoly2:SetPos( x, y )
	maskPoly:SetPos( x, y )

	circlePoly:SetScale( scale, scale )
	circlePoly2:SetScale( scale, scale )
	maskPoly:SetScale( scale, scale )

	--Create a composite, subtracts the inner circle and the mask from the outer cirle, resulting in the progress bar.
	local comp = composite.New()
	comp:Add( circlePoly.Draw, circlePoly )
	comp:Subtract( circlePoly2.Draw, circlePoly2 )
	comp:Subtract( maskPoly.Draw, maskPoly )

	--Draw the composite
	surface.SetDrawColor( Color(255,255,255,180) )
	comp:Draw()

	--Draw the inner circle as the background
	surface.SetDrawColor( Color(0,0,0,80) )
	circlePoly2:Draw()

end

--Fonts
surface.CreateFont( "MoneyButtonUser", { font = "Bebas Neue", size = 32, weight = 200 } )
surface.CreateFont( "MoneyButtonUser2", { font = "Bebas Neue", size = 64, weight = 200 } )

local nextUserFade = 0
local function DrawOtherUser( x, y, scale )

	local yoffset = -110 * scale

	--Only if the next user isn't us
	if IsPlayer( localInfo.nextUser ) and localInfo.nextUser ~= LocalPlayer() then
		surface.SetTextColor( 255,255,255,200 * nextUserFade )
		surface.SetFont( "MoneyButtonUser" )
		local text = localInfo.nextUser:Nick() .. "'s got this."
		local tw, th = surface.GetTextSize( text )
		surface.SetTextPos( x - tw/2, y + yoffset )
		surface.DrawText( text )
		nextUserFade = math.min( nextUserFade + FrameTime() * 10, 1 )
	else
		nextUserFade = math.max( nextUserFade - FrameTime() * 10, 0 )
	end

end

--HUDPaint hook
local springLocal = 0
local currentUserFade = 0
local function PlayerHudPaint()

	local x,y = ScrW()/2, ScrH()/2
	local frac = localInfo.fraction

	--Draw a notification if we're next to use the button
	if localInfo.isNextUser then
		surface.SetTextColor( 255,255,255,200 * currentUserFade )
		surface.SetFont( "MoneyButtonUser2" )
		local text = "you got this."
		local tw, th = surface.GetTextSize( text )
		surface.SetTextPos( x - tw/2, y - th )
		surface.DrawText( text )
		currentUserFade = math.min( currentUserFade + FrameTime() * 10, 1 )
	else
		currentUserFade = math.max( currentUserFade - FrameTime() * 10, 0 )
	end

	localInfo.isNextUser = false

	if IsValid( localInfo.usingButton ) then

		--Spring effect
		local qfrac = math.min( springLocal, 1 )
		local scale = 1 + math.sin( qfrac * math.pi * 4 + math.pi * 2 ) * ( 1 - qfrac ) ^ 2

		--Spring timing
		springLocal = springLocal + FrameTime()

		--Record the last use time for the post-use fadeout
		localInfo.lastUse = CurTime()

		--Draw the progress bar
		DrawRadialProgress( frac, x, y, scale )

		--Draw the other user text
		DrawOtherUser( x, y, scale )

	else

		--Reset spring
		springLocal = 0

		--Post-use fadeout
		local scale = (1 - math.min( CurTime() - localInfo.lastUse, 1 )) ^ 8
		if scale > 0.1 then
			DrawRadialProgress( frac, x, y, scale )
		end

	end

end
hook.Add( "HUDPaint", "money_button_hud", PlayerHudPaint )
*/
