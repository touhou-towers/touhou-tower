

-----------------------------------------------------
module("questioner", package.seeall )



CanVote = false

CurrentQuestion = nil

CurrentAnswers = nil

MainPanel = nil

EndVoteVote = nil

TargetAlpha = 150.0

Votes = {}



--usermessage.Hook("questioner", function( um )
net.Receive("questioner",function()


	local Id = net.ReadInt(16)



	if Id == 0 then



		EndVoteVote = net.ReadInt(32)

		CurrentQuestion = net.ReadString()

		local Count = net.ReadInt(16)

		CurrentAnswers = {}



		for i=1, Count do

			CurrentAnswers[ i ] = net.ReadString()

		end



		CanVote = true

		Votes = {}



		Msg2( "A new vote has started!\n" .. CurrentQuestion )

		Msg2( "Hold Q to vote." )



		CreatePanel()



	elseif Id == 1 && CurrentQuestion != nil then



		local Count = net.ReadInt(16)

		Votes = {}



		for i=1, Count do

			Votes[ i ] = net.ReadInt(16)

		end



		CreatePanel()



	elseif Id == 2 then



		if CurrentQuestion then

			Msg( CurrentQuestion .. "\n")



			for k, v in pairs( CurrentAnswers ) do

				Msg( "\t" .. (Votes[k] or 0) .. "\t" .. v .. "\n")

			end

		end



		CanVote = false

		CurrentQuestion = nil

		SideMenu.Close()



		if MainPanel then

			MainPanel:Remove()

		end



	end



end )



function GetTimeLeft()

	local Diff = math.max( 0, ( EndVoteVote or 0 ) - CurTime() )



	return string.FormattedTime( Diff, "%02i:%02i")

end



function CreatePanel()



	if !CurrentQuestion then

		return

	end



	if MainPanel then

		MainPanel:Remove()

	end



	MainPanel = vgui.Create( "QuestionPanel" )



end



function AskQuestion( question, answers )



	CurrentQuestion = question

	CurrentAnswers = answer



	Msg2("A new vote has started!")



end



function Vote( voteid )



	if CurrentQuestion == nil then

		return

	end



	CanVote = false



	RunConsoleCommand("gmt_voteopt", voteid )



	SideMenu.Close()



	if !IsLobby then

		RememberCursorPosition()

		gui.EnableScreenClicker( false )

	end



end



hook.Add("OpenSideMenu", "ShowQuestion", function()



	if CanVote != true then

		return

	end



	local Form = vgui.Create("DForm")



	Form:SetName( "Vote: " .. CurrentQuestion )



	for k, v in pairs( CurrentAnswers ) do



		local Refresh = Form:Button( v )

		Refresh.DoClick = function() Vote( k ) end



	end



	return Form



end )





surface.CreateFont( "QuestionSmallTitle", { font = "Bebas Neue", size = 20, weight = 400 } )

surface.CreateFont( "QuestionTitle", { font = "Bebas Neue", size = 26, weight = 400 } )

surface.CreateFont( "AnswerTitle", { font = "Trebuchet MS", size = 18, weight = 400 } )



local PANEL = {}

PANEL.TitleHeight = 42

PANEL.AnswerHeight = 20



function PANEL:Init()



	self:SetZPos( 1 )

	self:SetSize( 200, 100 )



	self.Title = Label( "VOTE", self )

	self.Title:SetFont( "QuestionSmallTitle" )

	self.Title:SetColor( Color( 255, 255, 255 ) )



	self.Time = Label( "0:00", self )

	self.Time:SetFont( "QuestionSmallTitle" )

	self.Time:SetColor( Color( 255, 255, 255 ) )



	self.HowTo = Label( "HOLD Q TO VOTE", self )

	self.HowTo:SetFont( "QuestionSmallTitle" )

	self.HowTo:SetColor( Color( 255, 255, 255 ) )



	self.Question = Label( "QUESTION", self )

	self.Question:SetFont( "QuestionTitle" )

	self.Question:SetColor( Color( 255, 255, 255 ) )



	self:SetMouseInputEnabled( false )

	self:SetKeyboardInputEnabled( false )



	self.TargetAlpha = 0



	self.AnswerPanels = {}



	for k, v in pairs( CurrentAnswers ) do



		Votes[ k ] = Votes[ k ] or 0

		self.AnswerPanels[k] = vgui.Create( "AnswerPanel", self )



	end



end



function PANEL:Paint( w, h )



	// Background

	surface.SetDrawColor( 26, 30, 38, 200 )

	surface.DrawRect( 0, 0, self:GetSize() )



	// Title

	surface.SetDrawColor( 15, 78, 132, 200 )

	surface.DrawRect( 0, 0, self:GetWide(), self.TitleHeight )



end



function PANEL:PerformLayout()



	self.Title:SizeToContents()

	self.Title:AlignTop(2)

	self.Title:AlignLeft( 4 )



	self.Time:SizeToContents()

	self.Time:AlignTop(2)

	self.Time:AlignRight( 4 )



	self.HowTo:SizeToContents()

	self.HowTo:AlignBottom(2)

	self.HowTo:CenterHorizontal()



	self.Question:SizeToContents()

	self.Question:CenterHorizontal()

	self.Question:AlignTop( 18 )



	local wide = self.Question:GetWide() + 10



	local curY = self.TitleHeight + 4

	for k, panel in pairs( self.AnswerPanels ) do



		panel:SetPos( 0, curY )

		panel:SetSize( self:GetWide(), self.AnswerHeight )

		curY = curY + self.AnswerHeight + 2



		wide = math.max( wide, panel:GetWide() )



	end



	self:SetTall( curY + self.HowTo:GetTall() + 4 )

	self:SetWide( wide )

	self:SetPos( ScrW() - wide - 32, 32 )



end



function PANEL:Think()



	self.Question:SetText( CurrentQuestion )

	self.Time:SetText( GetTimeLeft() )



	self:FadeThink()



	for k, v in pairs( CurrentAnswers ) do



		local title = v

		local votes = Votes[k]

		local panel = self.AnswerPanels[k]



		if panel then

			panel:SetVoteData( title, votes )

		end



	end



end



function PANEL:FadeThink()



	if CanVote then

		self:SetAlpha( 255 )

		return

	end



	if vgui.CursorVisible() then

		self.TargetAlpha = 255

	else

		self.TargetAlpha = 50

	end



	self:SetAlpha( ApproachSupport( self:GetAlpha(), self.TargetAlpha ) )



end



vgui.Register( "QuestionPanel", PANEL )





local PANEL = {}



function PANEL:Init()



	self.Title = Label( "Answer", self )

	self.Title:SetFont( "AnswerTitle" )

	self.Title:SetColor( Color( 255, 255, 255 ) )



	self.Votes = Label( "0", self )

	self.Votes:SetFont( "AnswerTitle" )

	self.Votes:SetColor( Color( 255, 255, 255 ) )



end



function PANEL:Paint( w, h )



	surface.SetDrawColor( 15 - 5, 78 - 5, 132 - 5, 10 )

	surface.DrawRect( 0, 0, self:GetSize() )



	local votes = tonumber( self.Votes:GetText() )



	if votes > 0 then

		surface.SetDrawColor( 0, 255, 0, 10 )

		surface.DrawRect( 0, 0, self:GetWide() * ( votes / #Votes ), self:GetTall() )

	end



end



function PANEL:PerformLayout()



	self.Title:SizeToContents()

	self.Title:AlignLeft( 8 )



	self.Votes:SizeToContents()

	self.Votes:AlignRight( 8 )



end



function PANEL:SetVoteData( title, votes )



	self.Title:SetText( title )

	self.Votes:SetText( votes )



end



vgui.Register( "AnswerPanel", PANEL )
