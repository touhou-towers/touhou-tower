
GTowerTrivia = {}
GTowerTrivia.CurPage = 0
GTowerTrivia.VGUI = nil
GTowerTrivia.InsertVGUI = nil
GTowerTrivia.LastSearch = ""

include('shared.lua')
include('cl_message.lua')
include('cl_buttongui.lua')

local function OpenAdminTrivia()
	GTowerTrivia:OpenAdmin()
end

concommand.Add( "gmt_trivia", OpenAdminTrivia )

hook.Add("GTowerAdminMenus", "AdminOpenTrivia", function()
	return {
		["Name"] = "GTrivia",
		["function"] = OpenAdminTrivia
	}
end )

function GTowerTrivia:OpenAdmin()

	if ValidPanel( self.VGUI ) then
		self.VGUI:Remove()
		self.VGUI = nil
	end
	
	local w,h = ScrW() * 0.6, ScrH() * 0.7
	
	self.VGUI = vgui.Create("DFrame")
	self.VGUI:SetSize( w,h )
	
	self.VGUI:SetTitle( "GTrivia!" )
	self.VGUI:SetDraggable( true )
	self.VGUI:ShowCloseButton( true )
	
	self.VGUI:Center()
	self.VGUI:SetVisible(true)
	self.VGUI:MakePopup() 
	
	self:ShowPage( 0 )

end

function GTowerTrivia:CacheUpdated()
	
	if self.VGUI && self.VGUI.IndexPage && self.VGUI.IndexPage.Items then
		
		for _, v in pairs( self.VGUI.IndexPage.Items ) do
			v:InvalidateLayout()
		end
		
	end
	
end

function GTowerTrivia:UpdatePageCount( count )
	GTowerTrivia:ShowPage( math.max( GTowerTrivia.CurPage + count, 0 ) )
end

function GTowerTrivia:ShowPage( page )

	GTowerTrivia.CurPage = page

	if self.VGUI.IndexPage == nil then
	
		local w,h = self.VGUI:GetSize()
		
		self.VGUI.IndexPage = vgui.Create("Panel", self.VGUI )
		
		self.VGUI.IndexPage:SetSize( w - 20, h - 22 )
		self.VGUI.IndexPage:SetPos( 10, 22 )
		self.VGUI.IndexPage:SetVisible(true)
		
		self.VGUI.IndexPage.Items = {}
		
		local EachHeight = math.floor( h / (GTowerTrivia.ItemsPerPage + 4 ) )
		
		for i = 1, GTowerTrivia.ItemsPerPage do
			
			local NewItem = vgui.Create("GTTriviaButton", self.VGUI.IndexPage )
			NewItem:SetSize( self.VGUI.IndexPage:GetWide() - 20, EachHeight)
			NewItem:SetVisible(true)
			
			NewItem:SetPos( 10,  EachHeight * i + 15 )
			
			self.VGUI.IndexPage.Items[ i ] = NewItem
		end
		
		self.VGUI.IndexPage.GoFirst = vgui.Create("DButton", self.VGUI.IndexPage )
		self.VGUI.IndexPage.GoBack = vgui.Create("DButton", self.VGUI.IndexPage )
		self.VGUI.IndexPage.GoForward = vgui.Create("DButton", self.VGUI.IndexPage )
		//self.VGUI.IndexPage.GoLast = vgui.Create("DButton", self.VGUI.IndexPage )
		
		self.VGUI.IndexPage.GoFirst:SetSize( self.VGUI.IndexPage:GetWide() * 0.1, EachHeight )
		self.VGUI.IndexPage.GoBack:SetSize( self.VGUI.IndexPage:GetWide() * 0.1, EachHeight )
		self.VGUI.IndexPage.GoForward:SetSize( self.VGUI.IndexPage:GetWide() * 0.1, EachHeight )
		//self.VGUI.IndexPage.GoLast:SetSize( self.VGUI.IndexPage:GetWide() * 0.1, EachHeight )
		
		local YPos = self.VGUI.IndexPage:GetTall() - EachHeight - EachHeight / 2
		
		self.VGUI.IndexPage.GoFirst:SetPos( 30 , YPos )
		self.VGUI.IndexPage.GoBack:SetPos( 30 + self.VGUI.IndexPage.GoFirst:GetWide() + 10, YPos )
		self.VGUI.IndexPage.GoForward:SetPos( self.VGUI.IndexPage:GetWide() - 30 - self.VGUI.IndexPage.GoForward:GetWide() * 2 - 10, YPos )
		//self.VGUI.IndexPage.GoLast:SetPos( self.VGUI.IndexPage:GetWide() - 30 - self.VGUI.IndexPage.GoForward:GetWide(), YPos )
		
		self.VGUI.IndexPage.GoFirst:SetText("<< First")
		self.VGUI.IndexPage.GoBack:SetText("< Back")
		self.VGUI.IndexPage.GoForward:SetText("Next >")
		//self.VGUI.IndexPage.GoLast:SetText("Last >>")
		
		self.VGUI.IndexPage.GoFirst.DoClick = function() GTowerTrivia:ShowPage( 0 ) end
		self.VGUI.IndexPage.GoBack.DoClick = function() GTowerTrivia:UpdatePageCount( -1 ) end
		self.VGUI.IndexPage.GoForward.DoClick = function() GTowerTrivia:UpdatePageCount( 1 ) end
		//self.VGUI.IndexPage.GoLast.DoClick = function() GTowerTrivia:ShowPage( 0 ) end
		
		self.VGUI.IndexPage.SearchBox = vgui.Create("DTextEntry", self.VGUI.IndexPage )
		self.VGUI.IndexPage.SearchBox:SetSize( 150 ,25 )
		self.VGUI.IndexPage.SearchBox:SetPos( self.VGUI.IndexPage:GetWide() - self.VGUI.IndexPage.SearchBox:GetWide(), 3 )
		self.VGUI.IndexPage.SearchBox.OnTextChanged = function() GTowerTrivia:ShowPage( 0 ) end
		
		self.VGUI.IndexPage.Insert = vgui.Create("DButton", self.VGUI.IndexPage )
		self.VGUI.IndexPage.Insert:SetSize( self.VGUI.IndexPage:GetWide() * 0.1, EachHeight )
		self.VGUI.IndexPage.Insert:SetPos( 3 , 3 )
		self.VGUI.IndexPage.Insert:SetText("INSERT")
		self.VGUI.IndexPage.Insert.DoClick = function() GTowerTrivia:InsertNewPage() end
	end
	
	//for k, v in pairs( self.VGUI.IndexPage.Items ) do
		
	//	v:SetId( k + page * GTowerTrivia.ItemsPerPage )
	
	//end
	
	local Search = self.VGUI.IndexPage.SearchBox:GetValue()
	
	//if GTowerTrivia:GetQuestion( page * GTowerTrivia.ItemsPerPage + 1 ) == nil || GTowerTrivia.LastSearch != Search then
	//	GTowerTrivia.LastSearch = Search
		RunConsoleCommand("gm_triv1", page, Search )
	//end

end

function GTowerTrivia:InsertNewPage()
	
	if ValidPanel( GTowerTrivia.InsertVGUI ) then
		GTowerTrivia.InsertVGUI:Remove()
		GTowerTrivia.InsertVGUI = nil
	end
	
	local w,h = ScrW() * 0.25, 450
	
	GTowerTrivia.InsertVGUI = vgui.Create("DFrame")
	GTowerTrivia.InsertVGUI:SetSize( w,h )
	
	GTowerTrivia.InsertVGUI:SetTitle( "GTrivia! New Item" )
	GTowerTrivia.InsertVGUI:SetDraggable( true )
	GTowerTrivia.InsertVGUI:ShowCloseButton( true )
	
	GTowerTrivia.InsertVGUI:Center()
	GTowerTrivia.InsertVGUI:SetVisible(true)
	GTowerTrivia.InsertVGUI:MakePopup()
	
	GTowerTrivia.InsertVGUI.DermaList = vgui.Create( "DPanelList", GTowerTrivia.InsertVGUI )
	GTowerTrivia.InsertVGUI.DermaList:SetPos( 3 ,25 )
	GTowerTrivia.InsertVGUI.DermaList:SetSize( w-6, h-40 )
	GTowerTrivia.InsertVGUI.DermaList:SetSpacing( 5 ) // Spacing between items
	GTowerTrivia.InsertVGUI.DermaList:EnableHorizontal( false ) // Only vertical items
	GTowerTrivia.InsertVGUI.DermaList:EnableVerticalScrollbar( true )

	//-----------
	local DText = vgui.Create("DLabel")
	DText:SetText("Question:")
	DText:SizeToContents()
		GTowerTrivia.InsertVGUI.DermaList:AddItem( DText )
	
	GTowerTrivia.InsertVGUI.QuestionEntry = vgui.Create("DTextEntry")
	GTowerTrivia.InsertVGUI.QuestionEntry:SetSize( w-10, 20 )
		GTowerTrivia.InsertVGUI.DermaList:AddItem( GTowerTrivia.InsertVGUI.QuestionEntry )
	
	//-----------
	DText = vgui.Create("DLabel")
	DText:SetText("Category:")
	DText:SizeToContents()
		GTowerTrivia.InsertVGUI.DermaList:AddItem( DText )
	
	GTowerTrivia.InsertVGUI.CatEntry = vgui.Create("DTextEntry")
	GTowerTrivia.InsertVGUI.CatEntry:SetSize( w - 10, 20 )
		GTowerTrivia.InsertVGUI.DermaList:AddItem( GTowerTrivia.InsertVGUI.CatEntry )
	
	//-----------
	local SpaceText = vgui.Create("DLabel")
	SpaceText:SetText("-- -- -- -- -- --")
		GTowerTrivia.InsertVGUI.DermaList:AddItem( SpaceText )
		
	//-----------
	/*local DText = vgui.Create("DLabel")
	DText:SetText("Answer 1:")
	DText:SizeToContents()
		GTowerTrivia.InsertVGUI.DermaList:AddItem( DText )
	
	GTowerTrivia.InsertVGUI.Answer1Entry = vgui.Create("DTextEntry")
	GTowerTrivia.InsertVGUI.Answer1Entry:SetSize( w-10, 20 )
		GTowerTrivia.InsertVGUI.DermaList:AddItem( GTowerTrivia.InsertVGUI.Answer1Entry )
		*/
	
	GTowerTrivia.InsertVGUI.Answers = {}
	
	//-----------
	for i=1, 4 do
		local DText = vgui.Create("DLabel")
		DText:SetText("Answer ".. i ..":")
		DText:SizeToContents()
			GTowerTrivia.InsertVGUI.DermaList:AddItem( DText )
		
		GTowerTrivia.InsertVGUI.Answers[i] = vgui.Create("DTextEntry")
		GTowerTrivia.InsertVGUI.Answers[i]:SetSize( w-10, 20 )
			GTowerTrivia.InsertVGUI.DermaList:AddItem( GTowerTrivia.InsertVGUI.Answers[i] )
	end
	
		
	//--------------
	local SpaceText = vgui.Create("DLabel")
	SpaceText:SetText("-- -- -- -- -- --")
		GTowerTrivia.InsertVGUI.DermaList:AddItem( SpaceText )
		
	//-----------
	GTowerTrivia.InsertVGUI.QuestionEnabled = vgui.Create( "DCheckBoxLabel" )
	GTowerTrivia.InsertVGUI.QuestionEnabled:SetText( "Disabled (Question should not be asked)" )
	GTowerTrivia.InsertVGUI.QuestionEnabled:SetValue( 0 )
	GTowerTrivia.InsertVGUI.QuestionEnabled:SizeToContents()
		GTowerTrivia.InsertVGUI.DermaList:AddItem( GTowerTrivia.InsertVGUI.QuestionEnabled )
	
	//-----------
	
	GTowerTrivia.InsertVGUI.FinalButton = vgui.Create( "DButton", TestingPanel )
	GTowerTrivia.InsertVGUI.FinalButton:SetText( "Insert question!" )
	GTowerTrivia.InsertVGUI.FinalButton:SetSize( w-10, 30 )
	GTowerTrivia.InsertVGUI.FinalButton.DoClick = function ()
		GTowerTrivia:VerifyNewQuestion()
	end 
	
	GTowerTrivia.InsertVGUI.DermaList:AddItem( GTowerTrivia.InsertVGUI.FinalButton )

end

function GTowerTrivia:AskToEditQuestion( id )
	RunConsoleCommand("gm_triv3", tostring(id) )
end

function GTowerTrivia:EditQuestion( tbl )
	
	GTowerTrivia:InsertNewPage()
	
	GTowerTrivia.InsertVGUI.QuestionEntry:SetText( tbl.Question )
	GTowerTrivia.InsertVGUI.CatEntry:SetText( tbl.Category )
	
	GTowerTrivia.InsertVGUI.Answers[1]:SetText( tbl.Ans1 )
	GTowerTrivia.InsertVGUI.Answers[2]:SetText( tbl.Ans2 )
	GTowerTrivia.InsertVGUI.Answers[3]:SetText( tbl.Ans3 )
	GTowerTrivia.InsertVGUI.Answers[4]:SetText( tbl.Ans4 )
	
	GTowerTrivia.InsertVGUI.QuestionEnabled:SetValue( tbl.Enabled )
	
	GTowerTrivia.InsertVGUI.FinalButton:SetText( "Update question!")
	
	GTowerTrivia.InsertVGUI.FinalButton.DoClick = function ()
		GTowerTrivia:VerifyNewQuestion( tbl.Id )
	end 
	
end

function GTowerTrivia:VerifyNewQuestion( Id )

	if !GTowerTrivia.InsertVGUI then
		return
	end
	
	local Question = GTowerTrivia.InsertVGUI.QuestionEntry:GetValue()
	local Category = GTowerTrivia.InsertVGUI.CatEntry:GetValue()
	local Answer1 = GTowerTrivia.InsertVGUI.Answers[1]:GetValue()
	local Answer2 = GTowerTrivia.InsertVGUI.Answers[2]:GetValue()
	local Answer3 = GTowerTrivia.InsertVGUI.Answers[3]:GetValue()
	local Answer4 = GTowerTrivia.InsertVGUI.Answers[4]:GetValue()
	local Active = tostring( GTowerTrivia.InsertVGUI.QuestionEnabled:GetValue() )
	
	
	
	if string.len( Question ) < 6 then
		Derma_Message( "The question is not long enough.", "GTrivia!")
		return
	end
	
	if string.len( Category ) < 3 then
		Derma_Message( "The category is not long enough.", "GTrivia!")
		return
	end
	
	if string.len( Answer1 ) < 1 then
		Derma_Message( "No answer1 found. Please insert at least two answers.", "GTrivia!")
		return
	end
	
	if string.len( Answer2 ) < 1 then
		Derma_Message( "No answer1 found. Please insert at least two answers.", "GTrivia!")
		return
	end
	
	GTowerTrivia.InsertVGUI:Remove()
	GTowerTrivia.InsertVGUI = nil
	
	if Id then
		RunConsoleCommand("gm_triv4", Id, Question, Category, Answer1, Answer2, Answer3, Answer4, Active )
	else
		RunConsoleCommand("gm_triv2", Question, Category, Answer1, Answer2, Answer3, Answer4, Active )
	end
end