
include('shared.lua')

surface.CreateFont( "JeoQuestion",{ font = "Tahoma", size = 18, weight = 200, antialias = true, additive = true })
surface.CreateFont( "JeoQuestionS",{ font = "Tahoma", size = 12, weight = 200, antialias = true, additive = true })

ENT.GameStartTransDelay = 1.0
ENT.ColorChangeDelay = 1.0

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.ColorNoPlayer = Color( 200, 50, 55, 255 )
ENT.ColorPlayer = Color(50,155,50,255)
ENT.ColorWaitingResponse = Color( 200, 200, 40, 255 )

ENT.TexButton    = surface.GetTextureID( "gmod_tower/gtrivia/gtrivia_button" )
ENT.TexPlayerBox = surface.GetTextureID( "gmod_tower/gtrivia/gtrivia_playerbox" )
ENT.TexQuestion  = surface.GetTextureID( "gmod_tower/gtrivia/gtrivia_questionbox" )
ENT.TexScoreBox  = surface.GetTextureID( "gmod_tower/gtrivia/gtrivia_scorebox" )

include('cl_waiting.lua')
include('cl_question.lua')
include('cl_scoreboard.lua')

function ENT:Initialize()
	self.ImageZoom = 0.6
	self:ReloadOBBBounds()
	
	self.Entities = {}
	self.PlayerData = {}
	
	local min, max = self:GetRenderBounds()
	min, max = min * 1.5, max * 1.5
	min.z = min.z - 50
	self:SetRenderBounds( min, max )
	
	self.GameStartTime = 0
	self.GameStartTime2 = 0
	
	self.CurQuestion = 1
	self.TotalQuestions = 10
	
	self.Answers = {}
	self.sCategory = ""
	self.sQuestion = ""
	self.sQuestionCount = "0/0"
	self.QuestionAskFinish = 0.0	
	self.ShowCorrectAns = false
	
	self.CorrectAnswer = 0
	self.LocalAnswer = 0
	
	//self:SetNetworkedVarProxy("state", self.StateChanged )
	self.State = 0
	self.StateTime = 0
	
	self.MinNamesY = 0
	
	
	self:CalculateDraw()
	timer.Simple( 0.0, function() if IsValid( self ) then self:FindChilds() end end )
	self:SharedInit()
end




function ENT:AnswerChanged( id, value )
	
	if string.len( value ) == 0 then
		self.Answers[id] = nil
		return
	end
	
	if self.Answers[id] == nil then
		self.Answers[id] = {}
	end
	
	self.Answers[id].x = (id-1) % 2
	self.Answers[id].y = ( (id-1) - self.Answers[id].x ) / 2
	self.Answers[id].str = value
	
end	

function ENT:StateChanged( name, old, new )
	if self.State != new then
		self.State = new
		self.StateTime = CurTime()
		
		if new == 0 then
			self:EndGame()
		
		elseif new == 1 then
			self.GameStartTime = CurTime() + self.StartWaitLenght
			self.DrawMain = self.DrawWaiting
			
		elseif new == 2 then
			self:StartGame()
		
		elseif new == 3 then
			self:StartScoreboard()
			
		end
		
		self:CalculateDraw()
		self:UpdateChildDraw()
	end
end

function ENT:EndGame()
	
	self.DrawMain = self.DrawWaiting
	self.GameStartTime = 0 
			
	for _, v in pairs( self.Entities ) do
		v:EndGame()
	end

end

function ENT:StartGame()

	self.GameStartTime2 = CurTime() + self.GameStartTransDelay
	self.DrawMain = self.DrawWaitingTranstition
	
	for _, v in pairs( self.Entities ) do
	
		if v:ValidPlayer() then
			v:StartGame()
		end
	
	end
	
	self.sCategory = ""
	self.sQuestion = ""
	self.LocalAnswer = 0
	
end

function ENT:FindChilds()

	for k, v in pairs( self.Entities ) do
		if !IsValid( v ) || v:GetBoard() != self then
			//Msg("Removing my child\n")
			table.remove( self.Entities, k )
		end
	end

	for _, v in pairs( ents.FindByClass( "gmt_jeo_table" ) ) do
	
		//Msg( tostring( v ) .. " parent is " .. tostring( v:GetBoard() ) .. "\n")
		
		if v:GetBoard() == self && table.HasValue( self.Entities, v ) == false then
			//Msg("Adding new child: " .. tostring( v ) .. "\n")
			table.insert( self.Entities, v )
		end
		
	end
	
	self:UpdateChildDraw()

end

function ENT:UpdateChildDraw()
	
	local countTrue = 0
	local count = table.Count( self.Entities )
	
	for _, v in pairs( self.Entities ) do
		if IsValid( v:GetPlayer() ) && v:GetPlayer():IsPlayer() then
			countTrue = countTrue + 1
		end
	end
	
	
	local TotalYSpace = self.TotalHeight * 0.5
	local YSpacePerPlayer = math.Min( 
		draw.GetFontHeight( "JeoQuestion" ) * 1.5,  
		TotalYSpace / math.ceil( count / 2 ) 
	)
	local HeightPlayer = YSpacePerPlayer * 0.9
	local WidthPlayer = self.TotalWidth * 0.45
	local StartYOffset = self.TotalMinY + self.TotalHeight - (YSpacePerPlayer * math.ceil( count / 2 ))
	local TrueStartYOffset = self.TotalMinY + self.TotalHeight - (YSpacePerPlayer * math.ceil( countTrue / 2 ))
	local TruePlayersList = 1
	
	local function GetXRowPercent( val )
		if val % 2 == 1 then
			return 0.25
		end
		return 0.75
	end
	
	for k, v in pairs( self.Entities ) do
		
		if self.PlayerData[ k ] == nil then
			self.PlayerData[ k ] = {}
		end
		
		self.PlayerData[ k ].XPos = self.TotalMinX + self.TotalWidth * GetXRowPercent( k ) - WidthPlayer * 0.5
		self.PlayerData[ k ].YPos = StartYOffset + (math.ceil( k / 2 ) - 1) * YSpacePerPlayer
		self.PlayerData[ k ].Valid = IsValid( v:GetPlayer() ) && v:GetPlayer():IsPlayer()
		self.PlayerData[ k ].Ent = v
		
		if self.PlayerData[ k ].Valid then
			self.PlayerData[ k ].XTruePos = self.TotalMinX + self.TotalWidth * GetXRowPercent( TruePlayersList ) - WidthPlayer * 0.5
			self.PlayerData[ k ].YTruePos = TrueStartYOffset + (math.ceil( TruePlayersList / 2 ) - 1) * YSpacePerPlayer
			
			TruePlayersList = TruePlayersList + 1
			
		else
			self.PlayerData[ k ].XTruePos = 0
			self.PlayerData[ k ].YTruePos = 0
		end
		
	end
	
	self.PlayerWidth = WidthPlayer
	self.PlayerHeight = HeightPlayer
	self.MinNamesY = TrueStartYOffset
	
	self:CalculateDraw()
end


function ENT:CalculateDraw()
	self.TotalWidth = self.TableWidth / self.ImageZoom
	self.TotalHeight = self.TableHeight / self.ImageZoom 
	self.TotalMinX = -self.NegativeX  / self.ImageZoom
	self.TotalMinY = -self.NegativeY  / self.ImageZoom
	
	local StartOffset = 10
	local CategoryHeight = 20
	
	self.TitleHeight = draw.GetFontHeight( "JeoQuestion" ) * 1.75
	self.TitleHeightSpace = self.TitleHeight + 8
	self.QuestionWidth = self.TotalWidth * 0.92	
	
	local TotalHeight = StartOffset + CategoryHeight + self.TitleHeightSpace * (2+1)
	local StartYOffset = (self.MinNamesY + self.TotalMinY) / 2 - TotalHeight / 2
	
	if StartYOffset < self.TotalMinY then
		StartYOffset = self.TotalMinY
	end
	
	self.QuestionCategoryX = self.TotalMinX +  self.TotalWidth / 2 - self.QuestionWidth / 2
	self.QuestionCategoryY = StartYOffset + StartOffset
	self.QuestionCategoryW = self.TotalWidth * 0.25
	self.QuestionCategoryH = CategoryHeight + 1
	
	
	self.QuestionX = self.QuestionCategoryX
	self.QuestionY = self.QuestionCategoryY + CategoryHeight
	
	self.AnswerWidth = self.QuestionWidth * 0.45
	self.AnswerYOffset = self.QuestionY + self.TitleHeightSpace
	
	self.Col1Question = self.QuestionX  + self.QuestionWidth * 0.25
	self.Col2Question = self.QuestionX  + self.QuestionWidth * 0.75
	
	
	
	
	self.QuestionCountX = self.QuestionX + self.QuestionWidth - 50
	self.QuestionCountW = 50
	
end

function ENT:Draw()
	//self.Entity:DrawModel()
end

function ENT:DrawTranslucent()
	local EntPos = self.Entity:GetPos()
	local Eye = self.Entity:EyeAngles()
	
	local ang = self.Entity:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 		90 )
	ang:RotateAroundAxis(ang:Forward(), 		90 )
	
	local pos = EntPos + Eye:Up() * self.UpPos + Eye:Forward() * self.FowardsPos

	
	cam.Start3D2D( pos, ang, self.ImageZoom )
	
		draw.RoundedBox( 8, 
			self.TotalMinX, 
			self.TotalMinY, 
			self.TotalWidth, 
			self.TotalHeight, 
			Color(40,50,150,255) 
		)

		self:DrawMain()
	
	cam.End3D2D()

end

function ENT:RecieveMessage( um )

	local Type = um:ReadChar()
		
	if Type == 0 then
			
		local NumQuestions = um:ReadChar()
		local TotalQuestion = um:ReadChar()
		local CurQuestion = um:ReadChar()
		
		self.sQuestionCount = CurQuestion .. " / " .. TotalQuestion
		
		self.sQuestion = um:ReadString()
		self.sCategory = um:ReadString()
		self.QuestionAskFinish = um:ReadLong()
		self.Answers = {}
			
		for i=1, NumQuestions do
			 self:AnswerChanged( i, um:ReadString() )
		end
		
		for _, v in pairs( self.Entities ) do
			if v:ValidPlayer() then
				//Msg("Question update")
				v:UpdateQuestion( self.sQuestion )
			end
		end
	
		self.ShowCorrectAns = false
		self.QuestionAskTime = CurTime()
	
	elseif Type == 1 then
		
		self:ShowCorrectAnswer( um:ReadChar() )
		self.ShowCorrectAns = true
		
		for _, v in pairs( self.Entities ) do
			if IsValid( v:GetPlayer() ) && v:GetPlayer():IsPlayer() then
				v:ShowCorrectAnswer()
			end
		end
		
	elseif Type == 2 then
	
		self.QuestionAskFinish = um:ReadLong()
	end

end

function ENT:CanPredictTime()
	return self.State == 2 && self.ShowCorrectAns == false
end

ENT.DrawMain = ENT.DrawWaiting


usermessage.Hook("Jeo", function( um )

	local ent = um:ReadEntity()
	
	if IsValid( ent ) && ent:GetClass() == "gmt_jeo_main" then
	
		ent:RecieveMessage( um )
	
	end

end )