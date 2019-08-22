
GTowerTrivia.QuestionDataQ = {}
GTowerTrivia.QuestionDataC = {}

usermessage.Hook("GTriv", function(um)

	local MsgId = um:ReadChar()
	
	if MsgId == 0 then
		local Count = um:ReadChar()
		local Tbl = {}
		
		for i=1, Count do 
			local Id = um:ReadLong()
			local Cat = um:ReadString()
			local Question = um:ReadString()
			local OnPageId = um:ReadChar()
			
			GTowerTrivia.QuestionDataQ[ Id ] = Question
			GTowerTrivia.QuestionDataC[ Id ] = Cat
			
			
			
			if GTowerTrivia.VGUI && GTowerTrivia.VGUI.IndexPage && GTowerTrivia.VGUI.IndexPage.Items then
				GTowerTrivia.VGUI.IndexPage.Items[ OnPageId ]:SetId( Id )
			end
		end
		
		GTowerTrivia:CacheUpdated()
	
	elseif MsgId == 1 then
		
		local DataTable = {}
		
		DataTable.Id = um:ReadLong()
		DataTable.Question = um:ReadString()
		DataTable.Category = um:ReadString()
		DataTable.Ans1 = um:ReadString()
		DataTable.Ans2 = um:ReadString()
		DataTable.Ans3 = um:ReadString()
		DataTable.Ans4 = um:ReadString()
		DataTable.Enabled = um:ReadBool()
	
		GTowerTrivia:EditQuestion( DataTable )
		
	elseif MsgId == 2 then
	
		GTowerTrivia:ShowPage( GTowerTrivia.CurPage )
		
		local Sucess = um:ReadBool()
		
		if Sucess == false then
			local Error = um:ReadString()
			
			Derma_Message( "SQL ERROR:" .. Error, "GTrivia!")
		end
	
	end

end) 

function GTowerTrivia:GetQuestion( id )

	if self.QuestionDataQ[ id ] == nil then
		return nil
	end
	
	return self.QuestionDataQ[ id ], self.QuestionDataC[ id ]

end