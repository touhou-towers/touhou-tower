
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_waiting.lua" )
AddCSLuaFile( "cl_question.lua")
AddCSLuaFile( "cl_scoreboard.lua")

include('shared.lua')
include('jeo_text.lua')
include('jeo_sql.lua')

local MinPlayers = 2


function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	SpawnPos.z = SpawnPos.z + 64
	
	local ent = ents.Create( "gmt_jeo_main" )
	ent:SetPos( SpawnPos )	
	ent:Spawn()
	ent:Activate()
	
	return ent
end

function ENT:UpdateModel()
	self.Entity:SetModel( self.Model )
	self:DrawShadow(false)
end

function ENT:Initialize()
	self:UpdateModel()
	
	self:ReloadOBBBounds()
	
	self.Entities = {}
	self.AnswerConversions = {0,0,0,0}
	//self:SetNWInt("state", 0 )
	//self.State = 0
	self:SetState( 0 )
	
	self.GameStartTime = 0
	self.QuestionID = -1
	
	
	self.NumQuestions = 0
	self.NumQuestionAnswered = 0
	self.QuestionAnswered = {}
	self.CorrectAnswer = 0
	self.CheckAnswer = false
	self.QuestionAskTime = 0
	
	if tmysql then
		self:SQLQuestBegin()
	end

	self:SetKeyValue( "targetname", "trivia1")
	self:SetName("trivia1")
	self:SharedInit()
end

function ENT:AddTable( ent )

	if IsValid( ent ) && ent:GetClass() == "gmt_jeo_table" then
		if !table.HasValue( self.Entities, ent ) then
			table.insert( self.Entities, ent )
			ent:UpdateParent( self )
		end
	end

end

function ENT:RemoveChild( ent )
	
	for k, v in pairs( self.Entities ) do
		if v == ent then
			table.remove( self.Entities, k )
		end
	end
	
	ent:UpdateParent( nil )
	
end

function ENT:GetPlayerEnt( ply )
	
	for _, v in pairs( self.Entities ) do
		if v:GetPlayer() == ply then
			return v
		end
	end
	
	return nil

end

function ENT:SetState( state )

	self.State = state	
	//self:SetNWInt( "state", state )
	
end

function ENT:GetState()
	return self.State
end

function ENT:InGame()
	return self:GetState() == 2
end

function ENT:CanAnswer()
	-- Msg("Can asnwer: " .. tostring( self.CheckAnswer ) .. "\n" )
	return self.CheckAnswer == true
end

function ENT:PlayerUpdated()

	local PlayerCount = self:GetPlayerCount()
	
	if self:InGame() then
	
		if PlayerCount <= 1 && self:GetState() != 0 && self:GetState() != 3 then
			self:EndGame()
		end	
		
		return
	end
	
	if PlayerCount >= MinPlayers && self:GetState() != 1 then
		self:SetState( 1 )
		self.GameStartTime = CurTime() + self.StartWaitLenght
	elseif PlayerCount <= 1 && self:GetState() != 0 then
		self:SetState( 0 )
	end

end

function ENT:CanChangePlayers()
	return self:GetState() == 1 || self:GetState() == 0
end

function ENT:GetPlayerCount()
	local count = 0

	for _, v in pairs( self.Entities ) do
	
		if v:ValidPlayer() then
			count = count + 1
		end
	end

	return count
end

function ENT:GetLimitAnswers()
	if tmysql then
		return self:GetSQLLimit()
	end
	
	return #self.QuestionTable
end

function ENT:StartGame()

	for k,v in pairs(player.GetAll()) do v.Points = 0 end

	self:SetState( 2 )
	self.NextQuestionTime = CurTime() + 2.0

	self.NumQuestions = 3 + self:GetPlayerCount() * 3
	self.NumQuestionAnswered = 1
	self.CheckAnswer = false
	
	Msg("Start game with: " .. self.NumQuestions .. "\n")
	
	if self.NumQuestions > self:GetLimitAnswers() then
		self.NumQuestions = self.NumQuestions
	end
	
	self.QuestionAnswered = {}
end

function ENT:FindNewQuestion()

	local LimitAnswers = self:GetLimitAnswers()
	local i = 0
	print(LimitAnswers)
	if #self.QuestionAnswered >= LimitAnswers then
		return -1
	end
	
	//Setup a new seed
	math.randomseed( os.time() + CurTime() )
	
	for i=0, 15 do //Atemp 16 times
		
		local RandId = math.random( 1,LimitAnswers )
		
		if !table.HasValue( self.QuestionAnswered, RandId ) then
			return RandId
		end
		
	end
	
	for i=1, LimitAnswers do //Find first unused id
		
		if !table.HasValue( self.QuestionAnswered, k ) then
			return k
		end
		
	end
	
	return -1
end

function ENT:ShuffleTbl( tbl )

	local AnsTbl = {}
	local ReturnTbl = {}
	local IdTable = {}

	for k, v in pairs( tbl ) do
		table.insert( AnsTbl, k )
	end	
	
	for i=1, #tbl do
		local OldIndex = table.remove( AnsTbl, math.random( 1, #AnsTbl ) )
		local NewIndex = table.insert( ReturnTbl, tbl[ OldIndex ] )
	
		IdTable[ NewIndex ] = OldIndex
	end
	
	return ReturnTbl, IdTable
	
end

//Why wait when all player have already answered?
function ENT:AnswersUpdate()
	//Check if all players answered
	
	if self.NextQuestionTime - CurTime() < 2 then
		return
	end
	
	for _, v in pairs( self.Entities ) do
		if v:ValidPlayer() && v:GetAnswer() == 0 then
			return
		end
	end
	
	//All players have answered,. End it already!
	self.NextQuestionTime = CurTime() + 1.25
	
	umsg.Start( "Jeo" )
	
		umsg.Entity( self )
		umsg.Char( 2 )
		umsg.Long( self.NextQuestionTime )

	umsg.End() 

end

function ENT:QuestionPost()
	self.CheckAnswer = false
	self.NextQuestionTime = CurTime() + self.ShowAnswerTime
	
	umsg.Start( "Jeo", rp )
	
		umsg.Entity( self )
		umsg.Char( 1 )
		umsg.Char( self.CorrectAnswer )
			
	umsg.End() 
		
	self.NumQuestionAnswered = self.NumQuestionAnswered + 1
		
	for _, v in pairs( self.Entities ) do
		if v:GetAnswer() == self.CorrectAnswer then
			v:AddPoints( 10 )
		elseif v:GetAnswer() == 0 then
			v:AddAnswerTime( self.TimeToAnswer )
		end
	end
	
	if tmysql then
		self:SQLQuestionPost()
	end
end

function ENT:AskQuestion()
	
	if self.CheckAnswer == true then
		print("Posting question")
		self:QuestionPost()
		
		return
	end
	
	if self.NumQuestionAnswered > self.NumQuestions then
		print("All questions answered")
		self:EndGame()
		return
	end
	
	local NewQ = self:FindNewQuestion()
	self.QuestionID = NewQ
	
	if NewQ == -1 then
		print("QuestionID -1")
		self:EndGame()
		return
	end
	
	if tmysql then
		self:SQLQuestionOfId( NewQ )
		return
	end
	
	self:SendQuestion ( self.QuestionTable[ NewQ ] )
	
end


function ENT:SendQuestion ( QuestionTbl )
	
	if QuestionTbl == nil then
		self:EndGame()
		return
	end
	
	local AnswerTable = {}
	
	for k, v in pairs( QuestionTbl["a"] ) do
		if string.len( string.Trim( v ) ) > 0 then
			table.insert( AnswerTable, v )
		end
	end
	
	local MixedAnswers, AnswerConversions = self:ShuffleTbl( AnswerTable )
	self.AnswerConversions = AnswerConversions
	
	self.NextQuestionTime = CurTime() + self.TimeToAnswer
	table.insert( self.QuestionAnswered, self.QuestionID )
	
	for k, v in pairs( MixedAnswers ) do
		if v == AnswerTable[1] then
			self.CorrectAnswer = k
		end
	end
	
	umsg.Start( "Jeo" )
	
		umsg.Entity( self )
		umsg.Char( 0 )
		
		umsg.Char( #MixedAnswers )
		umsg.Char( self.NumQuestions )
		umsg.Char( self.NumQuestionAnswered )
		
		umsg.String( QuestionTbl["q"] )
		umsg.String( QuestionTbl["c"] )
		umsg.Long( self.NextQuestionTime )
		
		for _, v in pairs( MixedAnswers ) do
			umsg.String( v )
		end
		
	umsg.End() 
	
	self.QuestionAskTime = CurTime()
	self.CheckAnswer = true
	
	for _, v in pairs( self.Entities ) do
		v:ResetAnswer()
	end
end


function ENT:EndGame()

	self:SetState(3)
	self.ScoreBoardEnd = CurTime() + 20.0
	
	local HighestPlayer = nil
	local HighestPoint = -1
	local LowestTime = 90000
	
	local winners = {}
	
	for _, v in pairs( self.Entities ) do
		if IsValid( v:GetPlayer() ) then
			table.insert( winners, { Player = v:GetPlayer(), Points = v.Points, Time = v.AnswerTime } )
		end
	end
	
	table.sort( winners, function( a, b )
		if a.Points > b.Points then
			return true
		end
		
		if a.Points == b.Points && a.Time < b.Time then
			return true
		end
		
		return false
	end )
	
	
	local prizeMoney = { 200, 150, 100 }
	local thanksForPlaying = 50
	
	local maxWinners = #prizeMoney
	if #winners < maxWinners then
		maxWinners = #winners
	end
	
	local maxPoints = self.NumQuestions * 10
	local answerScale = ( self.NumQuestionAnswered - 1 ) / self.NumQuestions
	
	winners[1].Player:SetAchivement( ACHIVEMENTS.TRIVIAMASTER, 1 )
	
	for i = 1, maxWinners do
	
		local pointScale = winners[ i ].Points / maxPoints
		
		local money = prizeMoney[ i ] or thanksForPlaying
		money = math.Clamp( money * pointScale * answerScale, 0, 200 )
		money = math.Round( money )

		local ply = winners[ i ].Player
		
		ply:AddMoney( money )
		
		--ply:SetAchivement( ACHIVEMENTS.TRIVIAMASTER, 1 )
		ply:AddAchivement( ACHIVEMENTS.MILLIONAIRE, 1 )
		
		local sfx = EffectData()
			sfx:SetOrigin( ply:GetPos() )
		util.Effect( "confetti", sfx )
		
	end
	
	
end

function ENT:ResetAll()
	for _, v in pairs( self.Entities ) do
		v:ResetAll()
	end

	self:SetState(0)
end

function ENT:Think()
	
	local state = self:GetState()
	
	if state == 1 then
		if CurTime() > self.GameStartTime then
			self:StartGame()
		end
	
	elseif state == 2 then
		if CurTime() > self.NextQuestionTime then
			self:AskQuestion()
		end
	
	elseif state == 3 then
		if CurTime() > self.ScoreBoardEnd then
			self:ResetAll()
		end
	
	end
	

end	

function ENT:OnRemove()

end