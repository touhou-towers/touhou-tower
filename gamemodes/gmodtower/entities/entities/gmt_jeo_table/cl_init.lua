
include('shared.lua')
include('cl_waiting.lua')

local function MakeMainFindChilds()
	for _, v in pairs( ents.FindByClass( "gmt_jeo_main" ) ) do
		v:FindChilds()
	end
end

local TexButton    = surface.GetTextureID( "gmod_tower/gtrivia/gtrivia_button" )
local TexPlayerBox = surface.GetTextureID( "gmod_tower/gtrivia/gtrivia_playerbox" )
local TexQuestion  = surface.GetTextureID( "gmod_tower/gtrivia/gtrivia_questionbox" )
local TexScoreBox  = surface.GetTextureID( "gmod_tower/gtrivia/gtrivia_scorebox" )

ENT.TexPlayerBox = TexPlayerBox

function ENT:Initialize()
	self.ImageZoom = 0.4
	
	self:ReloadOBBBounds()
	self:CalculateDraw()
	self:ResetColors()
	
	self.Ply = Entity(0)
	self.LastChange = 0
	self.Points = 0
	self.AnswerTime = 0.0
	
	self.ChosenAnswer = 0
	self.TimeOffset = math.Rand( 0, 4 )
	
	self.MultiLine = false
	self.QuestionLines = {"",""}
	self.LinesWidth = {0,0}
	self.LineHeight = 0
	
	self.PlyName = ""
	self.Alpha = 255
	
	timer.Simple( 1.0, function()
		MakeMainFindChilds()
	end)
	
	self:SharedInit()
end

function ENT:UpdateOwner( name, old, new )
	
	if IsValid( new ) && new:GetClass() == "gmt_jeo_main" then
		timer.Simple( 0, function()
			new.FindChilds(new)
		end)
	end
	
end

function ENT:GetPlayerName()
	
	local ply = self:GetPlayer()
	
	if IsValid( ply ) then
		return string.sub(ply:Name(), 1, 16)
	end
	
	return "OFF-LINE"
	
end

function ENT:UpdateQuestion( str )
	
	surface.SetFont("ChatFont")
	local w, h = surface.GetTextSize( str )
	
	self.LineHeight = h
	self.DrawQuesSubChoosing = self.QuestionChoosing
	self.PlyName = string.sub(self:GetPlayer():GetName(), 1, 16)

	if w < self.TotalWidth then
		self.MultiLine = false
		self.QuestionLines[1] = str
		self.LinesWidth[1] = w
		
		return
	end
	
	self.MultiLine = true
	self.QuestionLines = {""}
	
	local ExplodedQuestion = string.Explode(" ", str )
	local LocalWidth = 0
	local CurLine = 1
	local MaxLineWidth = w / 2
	
	for k, v in pairs( ExplodedQuestion ) do
		w, h = surface.GetTextSize( v )
		
		LocalWidth = LocalWidth + w
		
		if LocalWidth > MaxLineWidth then
			CurLine = CurLine + 1
			LocalWidth = 0
			
			self.QuestionLines[ CurLine ] = ""
		end
		
		self.QuestionLines[ CurLine ] = self.QuestionLines[ CurLine ] .. v .. " "
		
	end
	
	for k, v in pairs( self.QuestionLines ) do
		w, h = surface.GetTextSize( v )
	
		self.LinesWidth[ k ] = w
	end

end
/*
function ENT:UpdateAsnwerTime( name, old, new )
	self.AnswerTime = new
end

function ENT:PointsChanged( name, old, new )
	self.Points = new
end
*/
function ENT:AnswerChosen( name, old, new )

	if self.ChosenAnswer != new then
		self.ChosenAnswer = new
	
		self.LastAnswer = CurTime() + self:GetBoard().ColorChangeDelay
		
		if self.Ply == LocalPlayer() then
			self:GetBoard().LocalAnswer = self.ChosenAnswer
		end
		
		if self.ChosenAnswer == 0 then
			self.Answered = false
			self.DrawQuesSubChoosing = self.QuestionChoosing
			
		else
			self.Answered = true
			
			if LocalPlayer() == self:GetPlayer() then
				self.DrawQuesSubChoosing = self.QuestionChoosen
			end
		end
		
	end
	
end

function ENT:GetPoints()
	return self.Points
end

function ENT:UpdateUser( name, old, new )

	if new == Entity(0) then
		new = nil
	end

	if new != self.Ply then
	
		if IsValid( new ) && new:IsPlayer() then
			self.DrawSubWaiting = self.ValidPlayerTrans
			self.PlyName = new:GetName()
		else
			self.DrawSubWaiting = self.InvalidPlayerTrans
		end
		
		self.Ply = new
		self.LastChange = CurTime()
		
		self:EndGame()
		
	end

end

function ENT:StartGame()
	self:StartTransition()
end

function ENT:EndGame()
	self.CurPaint = self.PaintWaiting
end


function ENT:GetPlayer()
	return self.Ply
end

function ENT:CalculateDraw()
	self.TotalWidth = self.TableWidth / self.ImageZoom
	self.QuestionWidth = self.TotalWidth * 0.45
	
	self.TotalMinX = -self.NegativeX  / self.ImageZoom
	self.TotalMinY = -self.NegativeY  / self.ImageZoom

	self.Col1Question = self.TotalMinX  + self.TotalWidth * 0.25
	self.Col2Question = self.TotalMinX  + self.TotalWidth * 0.75
	
	self.TotalHeight = self.TableHeight / self.ImageZoom
	self.TitleHeight = (self.TableHeight * 0.264) / self.ImageZoom 
	self.TitleHeightSpace = (self.TableHeight * 0.271) / self.ImageZoom 
	
	self.YOffset = self.TableHeight / self.ImageZoom  - self.TitleHeightSpace * 3
	//self.TitleWeight = self.BlockWeightSpace  * 0.9
	
	self.NameWidth = self.TotalWidth * 0.6
	self.NameX = self.TotalMinX + self.TotalWidth * (0.6*0.5) - self.NameWidth / 2
	
	self.ScoreWidth = self.TotalWidth * 0.19
	self.ScoreX = self.TotalMinX + self.TotalWidth * (1.0-0.1) - self.ScoreWidth / 2
	self.TimeTakenX = self.TotalMinX + self.TotalWidth * (1.0-0.3) - self.ScoreWidth / 2
	
	
	self.NameScoreHeight = self.YOffset * 0.9

end

function ENT:ResetColors()
	
	self.HighLightColor = Color( 255, 255, 255, 255 )
	self.NoHighLightColor = Color( 200, 200, 200, 255 )
	self.ChoosenColor = Color( 170, 255, 170, 255 )
	
	self.Alpha = 255
end


function ENT:DrawTranslucent()
	

end

function ENT:Draw()

	self.Entity:DrawModel()

	local EntPos = self.Entity:GetPos()
	local EyeForward = self.Entity:EyeAngles():Up()
	
	local ang = self.Entity:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 		90 )
	ang:RotateAroundAxis(ang:Forward(), 		0.5 )
	
	local pos = EntPos + EyeForward * self.UpPos
	
	
	
	cam.Start3D2D( pos, ang, self.ImageZoom )
		
		surface.SetFont("ChatFont")
		surface.SetTextColor( 255, 255, 255, self.Alpha )
		
		self:CurPaint()
		
		//FOR D E B U G
		//local ax, ay = self:Get2DPos( LocalPlayer() )
		//surface.SetTextPos( self.TotalMinX, self.TotalMinY )
		//surface.DrawText( ax .. " " .. ay )
	
	cam.End3D2D()
	
end

function ENT:PaintOnGame()

	self:DrawQuestions()
	self:DrawName()
	self:DrawScore()
	
end

function ENT:ShowCorrectAnswer()
	self.DrawQuesSubChoosing = self.QuestionPost
end

function ENT:DrawQuestions()

	surface.SetDrawColor( 255, 255, 255, self.Alpha )
	surface.SetTexture( TexQuestion )
	surface.DrawTexturedRect( self.TotalMinX, self.YOffset + self.TotalMinY, self.TotalWidth, self.TitleHeight )
	/*surface.DrawOutlinedRect(
		self.TotalMinX, 
		self.YOffset + self.TotalMinY, 
		self.TotalWidth, 
		self.TitleHeight
	)*/
	
	if self.MultiLine == false then
		surface.SetTextPos( 
			self.TotalMinX + self.TotalWidth / 2 - self.LinesWidth[1]/2, 
			self.YOffset + self.TotalMinY + self.TitleHeight / 2 - self.LineHeight/2 
		)
		
		surface.DrawText( self.QuestionLines[1] )
	else
	
		surface.SetTextPos( 
			self.TotalMinX + self.TotalWidth / 2 - self.LinesWidth[1]/2, 
			self.YOffset + self.TotalMinY + self.TitleHeight * 0.25 - self.LineHeight/2 
		)
		surface.DrawText( self.QuestionLines[1] )
		
		surface.SetTextPos( 
			self.TotalMinX + self.TotalWidth / 2 - self.LinesWidth[2]/2, 
			self.YOffset + self.TotalMinY + self.TitleHeight * 0.75 - self.LineHeight/2 
		)
		surface.DrawText( self.QuestionLines[2] )
	end	
	
	/*
	local w, h = surface.GetTextSize( self:GetBoard().sQuestion )
	
	//if w > self.TotalWidth then
	//	surface.SetFont("JeoQuestionS")
	//	w, h = surface.GetTextSize( self:GetBoard().sQuestion )
	//end
	
	surface.SetTextPos( 
		self.TotalMinX + self.TotalWidth / 2 - w/2, 
		self.YOffset + self.TotalMinY + self.TitleHeight / 2 - h/2 )
	surface.DrawText( self:GetBoard().sQuestion )
*/
	
	self:DrawQuesSubChoosing()

end

function ENT:QuestionChoosing()
	local ButtonAim = self:GetAimButton( self:GetPlayer() || LocalPlayer() )
	
	local function GetColor( k, aim )
		if k == aim then
			return self.HighLightColor
		end
		
		return self.NoHighLightColor
	end
	
	local function GetColor( k, aim )
		if k == aim then
			return 180
		end
		
		return 0
	end
	
	for k, v in pairs( self:GetBoard().Answers ) do
		self:DrawQuestion( v.str , v.x, v.y, Color(255, 255, 255, self.Alpha), GetColor( k, ButtonAim ) )
	end

end

function ENT:QuestionChoosen()
	local function GetColor( k )
		if self.ChosenAnswer == k then
			return self.ChoosenColor
		end
			
		return self.NoHighLightColor
	end

	for k, v in pairs( self:GetBoard().Answers ) do
		self:DrawQuestion( v.str , v.x, v.y, GetColor( k ) )
	end
end

function ENT:QuestionPost()
	local own = self:GetBoard()
	
	local function GetColor( id, ans )
		local percent = math.min( CurTime() - own.CorrectAnswerTime, 1.5 ) / 1.5
		
		if id == own.CorrectAnswer then
			//return Color(60,170,70,255)
			return Color(255-100*percent,255,255-100*percent,self.Alpha)
		
		elseif id == ans then
			//return Color( 170, 60, 70, 255 )
			return Color(255, 255-100*percent, 255-100*percent, self.Alpha)
		
		end
		
		return Color(255, 255, 255, self.Alpha - percent * 205)
	end
	
	for k, v in pairs( own.Answers ) do
		self:DrawQuestion( v.str , v.x, v.y, GetColor( k, self.ChosenAnswer ) )
	end
end

ENT.DrawQuesSubChoosing = ENT.QuestionChoosing

function ENT:DrawName()

	local ValidPlayer = IsValid( self:GetPlayer() )
	
	surface.SetTexture( TexPlayerBox )
	surface.SetDrawColor( 255, 255, 255, self.Alpha )
	surface.DrawTexturedRect( self.NameX, self.TotalMinY, self.NameWidth, self.NameScoreHeight )
	
	
	local w, h = surface.GetTextSize( self.PlyName )
	
	surface.SetTextPos(
		self.NameX + self.NameWidth  * 0.05,
		self.TotalMinY + self.NameScoreHeight / 2 - h / 2
	)
	
	surface.DrawText( self.PlyName )
	
end

function ENT:DrawScore()

	surface.SetDrawColor( 255, 255, 255, self.Alpha ) 
	surface.SetTexture( TexScoreBox )
	
	
	surface.DrawTexturedRect( self.ScoreX, self.TotalMinY, self.ScoreWidth, self.YOffset - 2 )
	surface.DrawTexturedRect( self.TimeTakenX, self.TotalMinY, self.ScoreWidth, self.YOffset - 2 )
	/*
	surface.DrawOutlinedRect( 
		self.ScoreX, 
		self.TotalMinY, 
		self.ScoreWidth, 
		self.YOffset - 2
	)
	surface.DrawOutlinedRect( 
		self.TimeTakenX, 
		self.TotalMinY, 
		self.ScoreWidth, 
		self.YOffset - 2
	)*/

	local w, h = surface.GetTextSize( self.Points )
	surface.SetTextPos(
		self.ScoreX + self.ScoreWidth / 2 - w / 2,
		self.TotalMinY + self.NameScoreHeight / 2 - h / 2
	)
	surface.DrawText( self.Points )
	
	

	local PredictedTime = self.AnswerTime
	
	if self.Answered == false && self:GetBoard():CanPredictTime() then
		PredictedTime = PredictedTime + ( CurTime() - (self:GetBoard().QuestionAskTime or CurTime() ) )
	end
	
	//if PredictedTime < 10000 then
	//	PredictedTime = math.Round( PredictedTime * 10 ) / 10
	//else
		PredictedTime = math.Round( PredictedTime )
	//end
	
	w, h = surface.GetTextSize( PredictedTime )
	surface.SetTextPos(
		self.TimeTakenX + self.ScoreWidth / 2 - w / 2,
		self.TotalMinY + self.NameScoreHeight / 2 - h / 2
	)
	surface.DrawText( PredictedTime )

end


function ENT:DrawQuestion( answer, x, y, color, rot )

	local PosX = (x == 0 and self.Col1Question or self.Col2Question )
	local PosY = self.YOffset + self.TotalMinY + self.TitleHeightSpace * (y+1) + 3 + self.TitleHeight / 2
	
	/*draw.RoundedBox(8, 
		PosX - self.QuestionWidth / 2, 
		PosY, 
		self.QuestionWidth, 
		self.TitleHeight,
		color
	) */
	
	surface.SetTexture( TexButton )
	surface.SetDrawColor( color.r, color.g, color.b, color.a )
	//surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRectRotated( PosX, PosY, self.QuestionWidth, self.TitleHeight * 0.9, rot or 0 )
	
	local w, h = surface.GetTextSize( answer )
	
	surface.SetTextPos(
		PosX - w / 2,
		PosY  - h / 2
	)
	
	surface.DrawText( answer )

end

ENT.CurPaint = ENT.PaintWaiting 