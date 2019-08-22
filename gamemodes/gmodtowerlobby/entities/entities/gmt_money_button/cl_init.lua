
-----------------------------------------------------
include("shared.lua")

--Local user state ( shared among companion scripts )
localInfo_s = {
	usingButton 	= nil,
	fraction 		= 0,
	lastUse 		= 0,
	nextUser 		= nil,
	isNextUser		= nil
}

include("cl_overlay.lua")	--screenspace effects
include("cl_hud.lua")		--hud element

--Bring to localInfo to scope
local localInfo = localInfo_s

--Clear global
localInfo_s = nil

--Entity variables
ENT.CurrFraction 	= 0
ENT.RawFraction 	= 0
ENT.FractionSmooth	= 100
ENT.Sprite 			= Material("effects/blueflare1")
ENT.BarHeight = 0

--Returns true if the local player is using this button
function ENT:IsLocal() return self:GetUsePlayer() == LocalPlayer() end

--Get the current charge fraction
function ENT:GetFraction() return self.RawFraction end

--Get the current smoothed fraction
function ENT:GetRenderingFraction() return self.CurrFraction end

--Returns true if post-render effects should be used
function ENT:ShouldRenderFX()
	--No FX if the player isn't in the location
	local CurLoc = GTowerLocation:FindPlacePos(self:GetPos())
	if GTowerLocation:FindPlacePos(LocalPlayer():GetPos()) != CurLoc then return end
	return self:GetRenderingFraction() > 0
end

--Draw entity ( called only when the entity is visible on screen )
function ENT:Draw()

	self:DrawModel()			--Draw the prop model
	self:DrawProgressBars()		--Draw progress bars on the sides
	self:DrawGlowSprites()		--Draw red glowing sprites around the button

end
function ENT:Initialize()
	net.Receive("money_button_start",function()

		if net.ReadEntity() != self then return end

		self:RunPostProcessing(true)
		self.Active = true

		timer.Simple(7.5,function()
			self:StartPP()
		end)
		timer.Simple(10,function()
			self:EndPP()
			self.Active = false
			self.CoolDown = true
		end)
	end)
end
--Update entity ( called all the time no matter where you are )
function ENT:Think()

	self:CalculateCharge()		--Calculate the current charge level
	self:ShakePlayers()			--Shake people up, this is serious
	self:ProcessLocalPlayer()	--Do local player effects, updates hud too

	if self.Active then
		self.BarHeight = math.Approach( self.BarHeight, 1, 1 / 2000 )
	end

	if self.CoolDown then
		self.BarHeight = math.Approach( self.BarHeight, 0, 1 / 100 )
		if self.BarHeight == 0 then self.CoolDown = false end
	end

end

--Calculates the current charge fraction and the smoothed fraction
function ENT:CalculateCharge()

	self.RawFraction = self:GetChargeFraction()
	self.CurrFraction = math.Approach( self.CurrFraction, self.RawFraction, 1 / self.FractionSmooth )

end

--Toggles post processing
function ENT:RunPostProcessing( on )

	if not self.startedPP and on then
		self:StartPP()
		self.startedPP = true
	end
	if self.startedPP and not on then
		self:EndPP()
		self.startedPP = false
	end

end

--Start bloom flareout effect
function ENT:StartPP()

	local CurLoc = GTowerLocation:FindPlacePos(self:GetPos())
	if GTowerLocation:FindPlacePos(LocalPlayer():GetPos()) != CurLoc then return end

	local layer = postman.NewColorLayer()
	layer.addr = -0.1
	layer.addg = -0.1
	layer.addb = 0.25
	layer.mulr = 0.2
	layer.mulg = 0.2
	layer.mulb = 0.2
	layer.color = 0.1
	layer.contrast = 1.1
	layer.brightness = 0.1
	postman.FadeColorIn( "button_layer", layer, self.ChargeTimer * .3 )

	layer = postman.NewBloomLayer()
	layer.sizex = 10
	layer.sizey = 10
	layer.multiply = 0.5
	layer.color = 0.2
	layer.passes = 2
	postman.FadeBloomIn( "button_layer", layer, self.ChargeTimer * .3 )

end

--Stops bloom flareout effect
function ENT:EndPP()

	postman.ForceColorFade( "button_layer" )
	postman.FadeColorOut( "button_layer", .8 )

	postman.ForceBloomFade( "button_layer" )
	postman.FadeBloomOut( "button_layer", .8 )

end

--For only shaking when it's most of the way charged
function ENT:GetShakeFactor()
	return math.max( self:GetRenderingFraction() - .7, 0 ) * 2
end

--Shakes players who are close to the button while it's doing it's thing
function ENT:ShakePlayers()

	local shake = self.BarHeight / 50
	if shake > 0 then

		local range = self.ShakeRange
		local amp = 1 - (LocalPlayer():GetPos():Distance( self:GetPos() ) / range)
		if amp > 0 then
			util.ScreenShake(
				self:GetPos(),
				self.ShakeAmp * shake * amp,
				self.ShakeFrequency * shake,
				.1,
				range
			)
		end

	end

end

--Update local player variables
function ENT:ProcessLocalPlayer()

	--If the local player is using this button
	if self:IsLocal() then
		--Set this button as the button the player is using
		localInfo.usingButton = self

		--Set the next person to use this
		localInfo.nextUser = self:GetNextUsePlayer()

		--Start post-processing when the shaking begins
		self:RunPostProcessing( self:GetShakeFactor() > 0 )
	end

	--Am I next?
	if LocalPlayer() == self:GetNextUsePlayer() then
	localInfo.isNextUser = true
	end

	--If this is the button the player is using
	if localInfo.usingButton == self then

		--Update the player's fraction
		localInfo.fraction = self:GetFraction()

		--If the fraction is 0 either the button is not in use or it's finished
		if localInfo.fraction == 0 or not self:IsLocal() then

			--Clear the user's button
			localInfo.usingButton = nil

			localInfo.nextUser = nil

			--Stop post processing effects
			self:RunPostProcessing( false )
		end
	end

end

--Drawing on entity
function ENT:DrawProgressBar( id, frac, pos, normal, height, vOffset )
	--Draw the black background
	render.DrawQuadEasy(
		pos + normal * self.MeterHOffset + self:GetUp() * (self.MeterHeight/2 + self.MeterVOffset),
		normal, 5, self.MeterHeight, Color(0,0,0,255), 0 )

	--Draw the foreground bar
	render.DrawQuadEasy( pos + normal * self.MeterHOffset + vOffset, normal, 3, height, Color(255,100,100,255), 0 )
end

--Draw the progress bars on the button model
function ENT:DrawProgressBars()
	local frac = self.CurrFraction

	--Local rendering axis + origin
	local pos = self:GetPos()
	local forward = self:GetForward()
	local right = self:GetRight()
	local up = self:GetUp()

	--The height of the bar
	local height = self.MeterHeight * self.BarHeight

	--Move bar up slightly on the model
	local verticalOffset = up * (height/2 + self.MeterVOffset)

	render.SetColorMaterial()
	self:DrawProgressBar( 1, frac, pos, forward, height, verticalOffset )
	self:DrawProgressBar( 2, frac, pos, forward * -1, height, verticalOffset )
	self:DrawProgressBar( 3, frac, pos, right, height, verticalOffset )
	self:DrawProgressBar( 4, frac, pos, right * -1, height, verticalOffset )
end

--Draw red glowing sprites on the button
function ENT:DrawGlowSprites( frac )
	local frac = self.BarHeight
	local shake = self:GetShakeFactor()
	if self.CurrFraction ~= 0 then frac = frac * shake end

	render.SetMaterial( self.Sprite )
	render.DrawSprite( self:GetPos() + self:GetUp() * 40, 150 * frac, 150 * frac, Color( 255 * frac, 0, 0, 255) )
	render.DrawSprite( self:GetPos() + self:GetUp() * 40, 80 * frac, 80 * frac, Color( 255 * frac, 0, 0, 255) )
	render.DrawSprite( self:GetPos() + self:GetUp() * 40, 300 * frac, 300 * frac, Color( 255 * frac, 0, 0, 255) )
end
