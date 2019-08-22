
ENT.ColorNoPlayer = Color(155,150,150,155) 
ENT.ColorPlayer = Color(255,255,255,155) 
ENT.ColorPlayerDifference = Color(
	ENT.ColorPlayer.r - ENT.ColorNoPlayer.r,
	ENT.ColorPlayer.g - ENT.ColorNoPlayer.g,
	ENT.ColorPlayer.b - ENT.ColorNoPlayer.b,
	ENT.ColorPlayer.a - ENT.ColorNoPlayer.a
)


function ENT:PaintWaiting()

	self:DrawSubWaiting()

end

function ENT:ValidPlayerTrans()
	local diff = math.min( CurTime() - self.LastChange, 1 )
	
	if diff >= 1 then
		self.DrawSubWaiting = self.ValidPlayerWait
	end
	
	self:ValidPlayerWait(
		Color(
			self.ColorNoPlayer.r + diff * self.ColorPlayerDifference.r,
			self.ColorNoPlayer.g + diff * self.ColorPlayerDifference.g,
			self.ColorNoPlayer.b + diff * self.ColorPlayerDifference.b,
			self.ColorNoPlayer.a + diff * self.ColorPlayerDifference.a
		)	
	)
end

function ENT:InvalidPlayerTrans()

	local diff = math.min( CurTime() - self.LastChange, 1 )
	
	if diff >= 1 then
		self.DrawSubWaiting = self.InvalidPlayerWait
	end
	
	self:InvalidPlayerWait(
		Color(
			self.ColorPlayer.r - diff * self.ColorPlayerDifference.r,
			self.ColorPlayer.g - diff * self.ColorPlayerDifference.g,
			self.ColorPlayer.b - diff * self.ColorPlayerDifference.b,
			self.ColorPlayer.a - diff * self.ColorPlayerDifference.a
		)	
	)

end

function ENT:ValidPlayerWait( color )
	/*
	draw.RoundedBox( 
		8, 
		self.TotalMinX, 
		self.TotalMinY, 
		self.TotalWidth, 
		self.TotalHeight, 
		color or self.ColorPlayer
	) */
	
	self:WaitDrawBox( self.TotalMinX, self.TotalMinY, self.TotalWidth, self.TotalHeight, color or self.ColorPlayer )
	
	local Text = self:GetPlayerName()
	local w, h = surface.GetTextSize( Text )
	surface.SetTextPos( 
		self.TotalMinX + self.TotalWidth / 2 - w/2, 
		self.TotalMinY + (self.TableHeight / self.ImageZoom) * 0.75 - h/2 
	)
	surface.DrawText( Text )
	
end

function ENT:WaitDrawBox( x, y, w, h, color )

	surface.SetTexture( self.TexPlayerBox )
	surface.SetDrawColor( color.r, color.g, color.b, color.a )
	surface.DrawTexturedRect( x, y, w, h )
end

function ENT:InvalidPlayerWait( color )

	/*draw.RoundedBox(
		8, 
		self.TotalMinX, 
		self.TotalMinY, 
		self.TotalWidth, 
		self.TotalHeight, 
		color or self.ColorNoPlayer
	)*/
	
	self:WaitDrawBox( self.TotalMinX, self.TotalMinY, self.TotalWidth, self.TotalHeight, color or self.ColorNoPlayer )
	
	local Text = "Waiting for a player" 
	local w, h = surface.GetTextSize( Text )
	surface.SetTextPos( 
		self.TotalMinX + self.TotalWidth / 2 - w/2, 
		self.TotalMinY + (self.TableHeight / self.ImageZoom) * 0.75 - h/2 
	)
	surface.DrawText( Text .. string.rep( "." , (CurTime() + self.TimeOffset) % 3 + 1 ) )
end	

ENT.DrawSubWaiting = ENT.InvalidPlayerWait

function ENT:StartTransition()
	self.TimeTransiction = CurTime()
	self.LenghtTransiction = 2
	
	self.CurPaint = self.PaintNameTransition1

end


function ENT:PaintNameTransition1()
	
	local normalpercent = (CurTime() - self.TimeTransiction) / self.LenghtTransiction
	local percent = 1-normalpercent
	
	if percent > 1 || percent < 0 then
		self.TimeTransiction = CurTime()
		self.LenghtTransiction = 2
		self.CurPaint = self.PaintNameTransition2
		return
	end
	
	local width = (self.TotalWidth - self.NameWidth) * percent + self.NameWidth
	local height = (self.TotalHeight - self.NameScoreHeight) * percent + self.NameScoreHeight
	
	/*draw.RoundedBox(8, 
		self.TotalMinX, 
		self.TotalMinY, 
		width, 
		height, 
		Color(
			255 - 230 * normalpercent,
			255 - 55 * normalpercent, 
			25,
			155 + 50 * normalpercent
		) 
	)
	*/
	
	self:WaitDrawBox( self.TotalMinX, self.TotalMinY, width, height,
		Color(
			255,
			255, 
			255,
			155 + 100 * normalpercent
		) 
	)

	
	local w, h = surface.GetTextSize( self.PlyName )
	surface.SetTextPos( 
		self.TotalMinX + width * (0.5-0.45*normalpercent) - w * 0.5 * percent, 
		self.TotalMinY + height * (0.5 + percent * 0.25) - h/2 
	)
	surface.DrawText( self.PlyName )
	
end

function ENT:PaintNameTransition2()
	local percent = math.Clamp( (CurTime() - self.TimeTransiction) / self.LenghtTransiction, 0, 1 )
	
	if percent >= 1 then
		self:ResetColors()
		self.CurPaint =  self.PaintOnGame
	end
	
	self:DrawName()
	
	surface.SetTextColor( 255, 255, 255, 255 * percent )
	self.Alpha = 255 * percent
	
	self:DrawQuestions()
	self:DrawScore()

end