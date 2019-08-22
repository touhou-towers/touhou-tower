
module("questioner", package.seeall )

util.AddNetworkString("questioner")

CurrentQuestion = nil
CurrentAnswers = nil
QuestionOwnerId = nil
QuestionOwner = nil
QuestionLog = {}
VotingTime = 120 + 30

function Allow( ply )
	return ply:IsAdmin() || ply:GetSetting("GTAllowVote")
end

concommand.Add("gmt_startvote", function( ply, cmd, args )

	if !Allow( ply ) then
		return
	end

	if #args < 3 then
		ply:Msg2("You do not have enough arguments")
		return
	end

	if CurrentQuestion then
		EndVote()
	end

	local Question = args[1]
	local Answers = {}

	for i=2, #args do
		table.insert( Answers, args[i] )
	end

	CurrentQuestion = Question
	CurrentAnswers = Answers
	QuestionLog = {}
	QuestionOwnerId = ply:SQLId()

	SendToClients()

end )

concommand.Add("gmt_endvote", function( ply, cmd, args )

	if !Allow( ply ) then
		return
	end

	EndVote()

end )

function SendToClients()

	if !CurrentQuestion then
		return
	end

	for _, v in pairs( player.GetAll() ) do
		v._QuestionVoted = false
	end

	net.Start("questioner")
		net.WriteInt(0,16)
		net.WriteInt( CurTime() + VotingTime, 32 )
		net.WriteString( CurrentQuestion )
		net.WriteInt( #CurrentAnswers, 16 )

		for _, v in ipairs( CurrentAnswers ) do
			net.WriteString( v )
		end

	net.Broadcast()

	/*umsg.Start("questioner", nil )

		umsg.Char( 0 )
		umsg.Long( CurTime() + VotingTime )
		umsg.String( CurrentQuestion )
		umsg.Char( #CurrentAnswers )

		for _, v in ipairs( CurrentAnswers ) do
			umsg.String( v )
		end

	umsg.End()*/

	timer.Create("_QuestionerVote", VotingTime, 1, EndVote )

end

function GetTotalVotes()

	local VoteCount = {}

	for k, v in ipairs( CurrentAnswers ) do
		VoteCount[ k ] = 0
	end

	for ply, answer in pairs( QuestionLog ) do
		VoteCount[ answer ] = VoteCount[ answer ] + 1
	end

	return VoteCount

end

function SendCount()

	local VoteCount = GetTotalVotes()

	net.Start("questioner")

		net.WriteInt(1,16)
		net.WriteInt(#CurrentAnswers,16)

		for k, v in pairs( CurrentAnswers ) do
			net.WriteInt( VoteCount[ k ],16 )
		end

	net.Broadcast()


end

concommand.Add("gmt_voteopt", function( ply, cmd, args )

	if ply._QuestionVoted == false && #args > 0 then
		ply._QuestionVoted = tonumber( args[1] ) or 1

		QuestionLog[ ply:SQLId() ] = ply._QuestionVoted

		SendCount()
	end

end )

function EndVote()

	SafeCall( WriteToDatabase )

	net.Start("questioner")
		net.WriteInt(2,16)
	net.Broadcast()

	CurrentQuestion = nil

end

function WriteToDatabase()

	if CurrentQuestion == nil then
		return
	end

	local VoteHex = Hex()
	local AnswerHex = Hex()
	local TotalVotesHex = Hex()
	local TotalVotes = GetTotalVotes()

	for ply, answer in pairs( QuestionLog ) do
		VoteHex:Write( ply, 8 ) //4 bytes
		VoteHex:Write( answer, 2 ) //1 byte
	end

	for _, v in ipairs( CurrentAnswers ) do
		AnswerHex:WriteString( v ) //Null terminated string
	end

	for k, v in ipairs( TotalVotes ) do
		TotalVotesHex:Write( v, 2 ) //1 byte per vote, in same order order
	end

	local Query = string.format( "INSERT INTO `gmt_questions`(`question`,`votecount`,`answers`,`answercount`,`answerdata`,`owner`) VALUES ('%s',%s,%s,%s,%s,%s)",
		tmysql.escape( CurrentQuestion ),
		table.Count( QuestionLog ),
		AnswerHex:Get(),
		TotalVotesHex:Get(),
		VoteHex:Get(),
		QuestionOwnerId or 0
	)

	tmysql.query( Query, GTowerSQL.ErrorCheckCallback, nil, Query )

end

hook.Add("MapChange","InsertQuestionData", WriteToDatabase )
