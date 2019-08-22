
ENT.ColorWaitRespDiff = Color(
	ENT.ColorPlayer.r - ENT.ColorWaitingResponse.r,
	ENT.ColorPlayer.g - ENT.ColorWaitingResponse.g,
	ENT.ColorPlayer.b - ENT.ColorWaitingResponse.b,
	ENT.ColorPlayer.a - ENT.ColorWaitingResponse.a
)

function ENT:StartQuestions()
	self.DrawMain = self.DrawQuestionMain
	
	local CTime = CurTime()
	
	for _, v in pairs( self.PlayerData ) do
		v.Ent.LastAnswer = CTime + self.ColorChangeDelay
		v.Ent.Answered = false
	end
end

function ENT:DrawQuestionMain()
	self:DrawPlayers()
	self:DrawOnQuestion()
	
end

function ENT:OnGameGetColor( LastTime, State )

	if LastTime && LastTime > CurTime() then
		local TimeDiff =  1-(LastTime - CurTime()) / self.ColorChangeDelay
		
		if State == false then
			return Color(
				self.ColorPlayer.r - TimeDiff * self.ColorWaitRespDiff.r,
				self.ColorPlayer.g - TimeDiff * self.ColorWaitRespDiff.g,
				self.ColorPlayer.b - TimeDiff * self.ColorWaitRespDiff.b,
				255
			)
		end
	
		return Color(
			self.ColorWaitingResponse.r + TimeDiff * self.ColorWaitRespDiff.r,
			self.ColorWaitingResponse.g + TimeDiff * self.ColorWaitRespDiff.g,
			self.ColorWaitingResponse.b + TimeDiff * self.ColorWaitRespDiff.b,
			255
		)
	end
	
	if State == true then
		return self.ColorPlayer
	end

	return self.ColorWaitingResponse
end


function ENT:DrawPlayers()

	surface.SetFont("ChatFont")
	surface.SetTextColor( 255, 255, 255, 255 )

	for _, v in pairs( self.PlayerData ) do
		if v.Valid && IsValid( v.Ent:GetPlayer() ) then
		
			local PlyName = v.Ent:GetPlayerName()
			local w, h = surface.GetTextSize( PlyName )
			local BackColor = self:OnGameGetColor( v.Ent.LastAnswer , v.Ent.Answered )
			local MiddleY = v.YTruePos + self.PlayerHeight * 0.5 - h * 0.5 
			
			draw.RoundedBox( 8, 
				v.XTruePos, 
				v.YTruePos, 
				self.PlayerWidth, 
				self.PlayerHeight, 
				BackColor
			)
			
			surface.SetTextPos( 
				v.XTruePos + 12, 
				MiddleY
			)
			surface.DrawText( PlyName )
			
			local Points = v.Ent:GetPoints()
			w, h = surface.GetTextSize( Points )
			
			surface.SetTextPos( 
				v.XTruePos + self.PlayerWidth - w - 6, 
				MiddleY
			)
			surface.DrawText( Points )
			
		end
	end

end

function ENT:DrawOnQuestion()

	local PerWidth = math.max( self.QuestionAskFinish - CurTime(), 0 ) / self.TimeToAnswer

	surface.SetDrawColor( 25, 205, 55, 105 ) 
	surface.DrawRect( self.QuestionX, self.QuestionY, self.QuestionWidth * PerWidth, self.TitleHeight )
	


	surface.SetDrawColor( 255, 255, 255, 255 ) 
	surface.SetTextColor( 255, 255, 255, 255 )
	
	surface.DrawOutlinedRect( self.QuestionX, self.QuestionY, self.QuestionWidth, self.TitleHeight )

	surface.DrawOutlinedRect(  self.QuestionCategoryX, self.QuestionCategoryY, self.QuestionCategoryW, self.QuestionCategoryH )
	surface.DrawOutlinedRect(  self.QuestionCountX, self.QuestionCategoryY, self.QuestionCountW, self.QuestionCategoryH )
		
	surface.SetFont("JeoQuestion")
	
	local w, h = surface.GetTextSize( self.sQuestion )
	
	if w > self.QuestionWidth then
		surface.SetFont("JeoQuestionS")
		w, h = surface.GetTextSize( self.sQuestion )
	end

	surface.SetTextPos( self.QuestionX + self.QuestionWidth / 2 - w / 2, self.QuestionY + self.TitleHeight / 2 - h / 2 	)
	surface.DrawText( self.sQuestion )
	
	surface.SetFont("Default")
	
	w, h = surface.GetTextSize( self.sCategory )
	surface.SetTextPos( self.QuestionCategoryX + self.QuestionCategoryW / 2 - w / 2, self.QuestionCategoryY + self.QuestionCategoryH / 2 - h / 2 )
	surface.DrawText( self.sCategory )
	
	w, h = surface.GetTextSize( self.sQuestionCount )
	surface.SetTextPos( self.QuestionCountX + self.QuestionCountW / 2 - w / 2, self.QuestionCategoryY + self.QuestionCategoryH / 2 - h / 2 )
	surface.DrawText( self.sQuestionCount )
	
	
	surface.SetFont("ChatFont")
	
	for k, v in pairs( self.Answers ) do
		self:DrawQuestion( v.str , v.x, v.y, k )
	end
	
	//self:DrawQuestion( "A Peanut", 1, 0 )
	//self:DrawQuestion( "An Elephant", 1, 1 )
	//self:DrawQuestion( "The Moon", 0, 0 )
	//self:DrawQuestion( "A Kettie", 0, 1 )
	
end

function ENT:ShowCorrectAnswer( id )
	self.CorrectAnswer = id
	self.CorrectAnswerTime = CurTime()
end


function ENT:GetDQuestionColor( id, ans )
	if self.ShowCorrectAns == false then
		return Color(60,70,170,255)
	end
	
	local percent = math.min( CurTime() - self.CorrectAnswerTime, 1.5 ) / 1.5
	
	if id == self.CorrectAnswer then
		//return Color(60,170,70,255)
		return Color(60,70+percent*100,170-percent*100,255)
	
	elseif id == (ans or self.LocalAnswer) then
		//return Color( 170, 60, 70, 255 )
		return Color(60+percent*110, 70, 170-percent*100, 255)
	
	end
	
	return Color(60,70,170, 255 - percent * 205)
end

/*
function ENT:GetDQuestionColor( id, ans )
	if self.ShowCorrectAns == false then
		return Color(255,255,255,255)
	end
	
	local percent = math.min( CurTime() - self.CorrectAnswerTime, 1.5 ) / 1.5
	
	if id == self.CorrectAnswer then
		//return Color(60,170,70,255)
		return Color(255-100*percent,255,255-100*percent,255)
	
	elseif id == (ans or self.LocalAnswer) then
		//return Color( 170, 60, 70, 255 )
		return Color(255, 255-100*percent, 255-100*percent, 255)
	
	end
	
	return Color(255, 255, 255, 255 - percent * 205)
end
*/

function ENT:DrawQuestion( answer, x, y, id )

	local PosX = (x == 0 and self.Col1Question or self.Col2Question )
	local PosY = self.AnswerYOffset + self.TitleHeightSpace * y
	local BoxColor = self:GetDQuestionColor( id )
	
	surface.SetTextColor( 255, 255, 255, BoxColor.a )
	
	draw.RoundedBox(8, 
		PosX - self.AnswerWidth / 2,
		PosY,
		self.AnswerWidth,
		self.TitleHeight,
		BoxColor
	)
	
	local w, h = surface.GetTextSize( answer )
	
	surface.SetTextPos(
		PosX - w / 2,
		PosY + self.TitleHeight / 2 - h / 2
	)
	
	surface.DrawText( answer )

end