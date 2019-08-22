
local JeopertyEntities = {}

function ENT:GetSQLLimit()
	return #self.QuestionIDIndex
end

function ENT:SQLQuestBegin()

	self.QuestionIDIndex = {}
	self:UpdateSQLCache()
	
	if !table.HasValue( JeopertyEntities, self ) then
		table.insert( JeopertyEntities, self )
	end
	
end

function ENT:ParseSQLResults(res)
	if res[1].status != true then     
		ErrorNoHalt( tostring(res[1].error) .. " ("..tostring(res[1].status).. " - " .. tostring('-') .. ")\n" )
		return
	end
	
	self.QuestionIDIndex = {}
	
	for _, v in pairs( res[1].data ) do
		table.insert( self.QuestionIDIndex, v.id )
	end		
end

function ENT:UpdateSQLCache()
	local Query = "SELECT `id` FROM `gm_jeopardy`"
print(self)
	SQL.getDB():Query(Query, function(res) self:ParseSQLResults(res) end)
end


local function RecieveNewQuestion( res )

	if res[1].status != true then     
		Msg( "\n" .. self.LastSelectQuery .. "\n\n" )
		ErrorNoHalt( tostring(res[1].error) )
		Msg( res[1].status .. "\n")
		return
	end
	
	/*if #result == 0 then
		Msg("WARNING: NO ROW FOUND ON JEOPERTY")
		return
	end*/
	
	
	local Tbl = res[1].data[1]

	local questionId = tonumber( Tbl.id )
	print("-------------------")
	print(questionId)
	for k, v in pairs( JeopertyEntities ) do
		if IsValid( v ) && v:GetClass() == "gmt_jeo_main" then
			if v.QuestionID == questionId then
				v:SQLRecieveQuestion( Tbl )
				return
			end
		
		else
			table.remove( JeopertyEntities, k )	
		end	
	end

end

function ENT:SQLQuestionOfId( id )

	local SQLId = self.QuestionIDIndex[ id ]
	
	if !SQLId then
		self:UpdateSQLCache()
		self:EndGame()
		return
	end
	
	self.LastSelectQuery = "SELECT `id`,`question`,`cat`,`ans1`,`ans2`,`ans3`,`ans4` FROM gm_jeopardy WHERE `id`=" .. SQLId .. " LIMIT 1"

	SQL.getDB():Query(self.LastSelectQuery, RecieveNewQuestion )

end


function ENT:SQLRecieveQuestion( SqlTbl )	
	
	local QuesTbl = {}
	
	QuesTbl["q"] = SqlTbl["question"]
	QuesTbl["c"] = SqlTbl["cat"]
	QuesTbl["a"] = {}
	
	QuesTbl["a"][1] = SqlTbl["ans1"]
	QuesTbl["a"][2] = SqlTbl["ans2"]
	QuesTbl["a"][3] = SqlTbl["ans3"]
	QuesTbl["a"][4] = SqlTbl["ans4"]	
	
	self:SendQuestion ( QuesTbl )

end


function ENT:PostSQLQuestionPost(res)
	if res[1].status != true then
		ErrorNoHalt( res[1].error )
		Msg( res[1].status .. "\n")
	end 
end

function ENT:SQLQuestionPost()
	
	local AnswerCount = {0,0,0,0}
	local CountTouch = false
	
	for _, v in pairs( self.Entities ) do
		local Answer = v:GetAnswer()
		if Answer > 0 then
			if !self.AnswerConversions[ Answer ] then
				ErrorNoHalt("Missing answer for " .. tostring(Answer) .. " on {" .. table.concat(self.AnswerConversions, ",") .. "}")
			end

			local ActIndex = self.AnswerConversions[ Answer ]
			AnswerCount[ ActIndex ] = (AnswerCount[ ActIndex ] or 0) + 1
			CountTouch = true
		end
	end
	
	if CountTouch == false then
		return
	end

	local SQLQuery = "UPDATE gm_jeopardy SET"
	
	for k, v in pairs( AnswerCount ) do
		if v > 0 then
			SQLQuery = SQLQuery .. " `count" .. k .. "`=`count" .. k .. "`+1,"
		end
	end
	
	SQLQuery  =  SQLQuery .. "LastUse=" .. os.time() .. " WHERE `id`=".. self.QuestionIDIndex[self.QuestionID] .. " LIMIT 1"
	
	SQL.getDB():Query(SQLQuery, self.PostSQLQuestionPost)
end