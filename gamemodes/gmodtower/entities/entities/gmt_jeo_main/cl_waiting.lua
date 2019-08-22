

ENT.ColorPlayerDifference = Color(
	ENT.ColorPlayer.r - ENT.ColorNoPlayer.r,
	ENT.ColorPlayer.g - ENT.ColorNoPlayer.g,
	ENT.ColorPlayer.b - ENT.ColorNoPlayer.b,
	ENT.ColorPlayer.a - ENT.ColorNoPlayer.a
)

function ENT:GetWaitPlyColor( ValidPlayer, time ) 
	
	local TimeDiff = CurTime() - time
	
	if TimeDiff < 1 then
		if ValidPlayer then
			return Color(
				self.ColorNoPlayer.r + TimeDiff * self.ColorPlayerDifference.r,
				self.ColorNoPlayer.g + TimeDiff * self.ColorPlayerDifference.g,
				self.ColorNoPlayer.b + TimeDiff * self.ColorPlayerDifference.b,
				255		
			)	
		end
	
		return Color(
			self.ColorPlayer.r - TimeDiff * self.ColorPlayerDifference.r,
			self.ColorPlayer.g - TimeDiff * self.ColorPlayerDifference.g,
			self.ColorPlayer.b - TimeDiff * self.ColorPlayerDifference.b,
			255		
		)	
	end
	
	if ValidPlayer then
		//return Color(50,155,200,255)
		return self.ColorPlayer
	end
	
	return self.ColorNoPlayer
end

function ENT:GetWaitingText()
	if self.GameStartTime > 0 then
		return "Game starts in: " .. math.Max( math.ceil( self.GameStartTime - CurTime() ), 0 )
	end
	
	return "Waiting for players" 
end

function ENT:DrawBarTitle( SizeDecrease )

	local Text = self:GetWaitingText()
	local w, h = surface.GetTextSize( Text )
	local CenterX = self.TotalMinX + self.TotalWidth / 2
	local CenterY = self.TotalMinY + self.TotalHeight * 0.5
	
	local BoxX = CenterX - w
	local BoxY = CenterY - h * SizeDecrease
	local BoxW = w * 2
	local BoxH = h * 2 * SizeDecrease
	
	if self.GameStartTime > 0 then
		local TimePercent = 1 - math.Clamp( (self.GameStartTime - CurTime()) / self.StartWaitLenght, 0, 1)
	
		surface.SetDrawColor( 55, 255, 55, 100 * SizeDecrease ) 
		surface.DrawRect( 
			BoxX, 
			BoxY, 
			BoxW * TimePercent, 
			BoxH
		)
	end
	
	
	surface.SetDrawColor( 255, 255, 255, 255 * SizeDecrease ) 
	surface.DrawOutlinedRect( 
		BoxX, 
		BoxY, 
		BoxW, 
		BoxH
	)
	
		
	surface.SetTextPos( 
		CenterX - w / 2, 
		CenterY - h / 2 
	)
	
	surface.DrawText( Text .. string.rep( ".", CurTime() % 3 + 1 ) )

end

function ENT:DrawWaiting()

	surface.SetFont("JeoQuestion")
	surface.SetTextColor( 255, 255, 255, 255 )

	self:DrawBarTitle( 1.0 )
	self:DrawWaitingNames( 1.0 )
	
end

function ENT:DrawWaitingNames( percent )

	for _, v in pairs( self.PlayerData ) do
	
		if IsValid( v.Ent ) then	
			local ValidPlayer = IsValid( v.Ent:GetPlayer() )
			
			local XPos = v.XPos
			local YPos = v.YPos
			local BackColor = self:GetWaitPlyColor( ValidPlayer, v.Ent.LastChange ) 
			
			if percent < 1 then
				if ValidPlayer then
					XPos = XPos + (1-percent) * ( v.XTruePos - v.XPos )
					YPos = YPos + (1-percent) * ( v.YTruePos - v.YPos )
					surface.SetTextColor( 255, 255, 255, 255 )
				else
					surface.SetTextColor( 255, 255, 255, 255 * percent )
					BackColor.a = BackColor.a * percent
				end
				
			else
				BackColor.a = 255
			end
			
			draw.RoundedBox( 8, 
				XPos, 
				YPos, 
				self.PlayerWidth, 
				self.PlayerHeight, 
				BackColor
			)
			
			if ValidPlayer then
				
				surface.SetFont("ChatFont")
				local Text = string.sub(v.Ent:GetPlayer():Name(), 1, 16)
				local w, h = surface.GetTextSize( Text )
				surface.SetTextPos( 
					XPos + 12, 
					YPos + self.PlayerHeight * 0.5 - h / 2 
				)
				surface.DrawText( Text )
				
			else
				
				surface.SetFont("JeoQuestion")
				local Text = "No Player"
				local w, h = surface.GetTextSize( Text )
				surface.SetTextPos( 
					XPos + self.PlayerWidth / 2 - w / 2, 
					YPos + self.PlayerHeight * 0.5 - h / 2 
				)
				
				surface.DrawText( Text )
			
			end
		end
	end

end

function ENT:DrawWaitingTranstition()

	local percent = math.Max( self.GameStartTime2 - CurTime(), 0 ) / self.GameStartTransDelay
	
	surface.SetFont("JeoQuestion")
	surface.SetTextColor( 255, 255, 255, 255 * percent )
	
	self:DrawBarTitle( percent )
	
	surface.SetTextColor( 255, 255, 255, 255 )
	self:DrawWaitingNames( percent )
	
	if percent == 0 then
		self:StartQuestions()
	end
end






