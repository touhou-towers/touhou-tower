
local PANEL = {}

local TRANSTIONTIME = 0.75
local DELAYTIME = 0.15

local EXTRAWIDTH = 16
local EXTRAHEIGHT = 16 

local DisapearingDireciton = math.pi * 0.5
local FONT = "smalltitle"

function PANEL:Init()
	
	self.Markup = nil
	self.LineParent = nil
	self.State = 0
	
end

function PANEL:SetLineParent( parent )
	self.LineParent = parent
end

function PANEL:SetState( state )
	self.State = state
end

function PANEL:GetState()
	return self.State
end

/* = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
	== State 1, Going down the side to show the answer and staying there
 = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = */
function PANEL:SetupAnswer( tbl, count, total )

	self.Table = tbl
	local Percent = 0.5
	
	if total != 1 then //Don't devide by 0
		Percent = (count - 1) / (total - 1)
	end
	
	self.Markup = markup.Parse( self:GetAnswer() , ScrW() * 0.25 )
	self:PanelToMarkup()
	
	self.OriginAngle =  math.rad( 0 )
	//self.TargetAngle = math.rad( STARTANGLE + ( ENDANGLE - STARTANGLE ) * (1-Percent) )
	self.TargetAngle = math.rad( -30 - 120 * (1-Percent) )
	self.Distance = ScrH() * 0.4
	self.TimeDelay = DELAYTIME * count

	self.Think = self.SlidingThink
	self.Paint = self.SlideDraw
	
	self:SetState( 1 )
	
end

function PANEL:SlidingThink()

	if self.TimeDelay then
		if CurTime() < self.TimeDelay then
			return
		end
		
		//Don't need to check this again, start sliding down
		self.TimeDelay = nil
		self.TargetTime = CurTime() + TRANSTIONTIME
	end
	
	local Percent = 1 - math.Max( 0, ( self.TargetTime - CurTime() ) / TRANSTIONTIME )
	self.CurAngle = self.OriginAngle + (self.TargetAngle - self.OriginAngle) * Percent
	
	self:AnglePos( self.CurAngle, self.Distance )
	
	self:SetAlpha( math.max( Percent * 1.5, 1.0 ) * 255 )

	if Percent >= 1.0 then	
		self.Think = EmptyFunction
	end

end

function PANEL:SlideDraw()

	self:DrawBackground()
	self.Markup:Draw( EXTRAWIDTH * 0.5 , EXTRAHEIGHT * 0.5 )

end

/* = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
	== State 2 - Disaperaing away if option not chosen
 = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = */

function PANEL:DisapearAnswer()

	self.TargetTime = CurTime() + TRANSTIONTIME

	self.Paint = self.DisapearAnswerDraw
	self.Think = EmptyFunction
	
	self:SetState( 2 )
end

function PANEL:DisapearAnswerDraw()

	local Percent = 1 - math.Max( 0, ( self.TargetTime - CurTime() ) / TRANSTIONTIME )
	local distance = self.Distance * (1+Percent * 0.25)
	
	self:AnglePos( self.CurAngle, distance )

	self:SetAlpha( 255 - Percent * 255 )
	self:DrawBackground()
	self.Markup:Draw( EXTRAWIDTH * 0.5 , EXTRAHEIGHT * 0.5 )
	
	if Percent >= 1.0 then
		self:Remove()
	end

end
 
/* = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
	== State 3, Going up to the middle of the screen
 = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = */
 
function PANEL:MoveToMiddle()

	self.TargetTime = CurTime() + TRANSTIONTIME
	self.MovePercent = 0
	self.NewMarkup = markup.Parse( self:GetQuestion() , ScrW() * 0.3 )
	self:SetAlpha( 255 )
	
	self.Think = self.MiddleMoveThink
	self.Paint = self.MiddleMoveDraw
	
	self:SetState( 3 )
	
end

function PANEL:MiddleMoveThink()

	self.MovePercent = 1- math.Max( 0, ( self.TargetTime - CurTime() ) / TRANSTIONTIME )
	local distance = self.Distance  * (1-self.MovePercent)

	self:SetSize(
		self.Markup:GetWidth() + (self.NewMarkup:GetWidth()+EXTRAWIDTH - self.Markup:GetWidth()) * self.MovePercent,
		self.Markup:GetHeight() + (self.NewMarkup:GetHeight()+EXTRAHEIGHT - self.Markup:GetHeight()) * self.MovePercent
	)
	
	//self:SetPos(
	//	ScrW() * 0.5 + math.cos( self.TargetAngle ) * distance - self:GetWide() * 0.5,
	//	ScrH() * 0.5 - math.sin( self.TargetAngle ) * distance - self:GetTall() * 0.5
	//)
	
	self:AnglePos( self.TargetAngle, distance )
	
	if self.MovePercent >= 1.0 then
		self.Think = EmptyFunction
		self.Paint = self.QuestionDraw
		self.Markup = self.NewMarkup
	end
	
end

function PANEL:MiddleMoveDraw()

	self:DrawBackground()
	
	if self.MovePercent < 0.5 then
		self.Markup:Draw( EXTRAWIDTH * 0.5 , EXTRAHEIGHT * 0.5, nil, nil, 255 - self.MovePercent * 2 * 255 )
	else
		self.NewMarkup:Draw( EXTRAWIDTH * 0.5 , EXTRAHEIGHT * 0.5, nil, nil, (0.5-self.MovePercent) * 2 * 255 )
	end
	
end


/* = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
	== State 4, Standing in the middle, asking the question
 = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = */
function PANEL:SetupQuestion( tbl )

	self.Table = tbl
	self.Markup = markup.Parse( self:GetQuestion() , ScrW() * 0.3 )
	
	self:PanelToMarkup()
	self:SetPos( 
		ScrW() * 0.5 - self:GetWide() * 0.5, 
		ScrH() * 0.5 - self:GetTall() * 0.5
	)
	
	if GtowerNPCChat.TalkingLady then
		self.Think = self.QuestionThink
	else
		self.Think = EmptyFunction
	end
	
	self.Paint = self.QuestionDraw
	
	self:SetState( 4 )
	self:CreateResponses()
end

function PANEL:QuestionThink()
	
	local Entities = ents.FindByClass( GtowerNPCChat.TalkingLady ) 
	local LocalPos = LocalPlayer():GetPos()
	
	for _, v in pairs( Entities ) do
		if v:GetPos():Distance( LocalPos ) <= GtowerRooms.NPCMaxTalkDistance then
			return
		end	
	end	
	
	self:DisperseSelf()
	
end

function PANEL:QuestionDraw()

	self:DrawBackground()
	self.Markup:Draw( EXTRAWIDTH * 0.5 , EXTRAHEIGHT * 0.5 )
	
end

/* = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
	== State 5 - Going up into oblivion
 = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = */
function PANEL:GoDisapear()

	self.TargetTime = CurTime() + TRANSTIONTIME
	self.Paint = self.DisapearingDraw
	self.Think = EmptyFunction
	
	self:SetState( 5 )
	
end
 
function PANEL:DisapearingDraw()

	local Percent = 1 - math.Max( 0, ( self.TargetTime - CurTime() ) / TRANSTIONTIME )
	local Distance = ScrH() * 0.2 * Percent
	
	self:AnglePos( DisapearingDireciton, Distance )
	self:SetAlpha( 255 - Percent * 255 )
	
	self:DrawBackground()
	self.Markup:Draw( EXTRAWIDTH * 0.5 , EXTRAHEIGHT * 0.5 )
	
	if Percent >= 1.0 then
		self:Remove()
	end

end
 
 
/* = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
	== MAIN FUNCTIONS
 = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = */
 
function PANEL:OnMouseReleased( mc ) 
	
	if self:GetState() == 1 then
	
		if type( self.Table.Func ) == "function" then
			self.Table.Func( self.Table.data )
		end
		
		if self.Table.Text then
			if self:CreateResponses() == true then
				self:MoveToMiddle()
				self:DisperseParent( self )
				GtowerNPCChat.MainChat = self
				return
			end
		end
		
		self:DisperseParent()
		GtowerMainGui:GtowerHideMenus()
		
	end
	
end

function PANEL:DisperseParent( iginore )
	if IsValid( self.LineParent ) then
		self.LineParent:DisperseSelf( iginore )
	end
end

function PANEL:PerformLayout()
	
end
 

/* = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
	== HELPER FUNCTIONS
 = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = */
function PANEL:DrawBackground()
	draw.RoundedBox( 8, 0, 0, self:GetWide(), self:GetTall(), Color( 5, 20, 40, 230 ) )
end


function PANEL:CreateResponses()

	local Responses = self:GetResponses()

	if Responses then
	
		self.Children = {}
		local TotalCount = table.Count( Responses )
		local Count = 1
	
		for k, v in pairs( Responses ) do
		
			local NewAnswer = vgui.Create("GtowerChatQuestion")
			NewAnswer:SetLineParent( self )
			NewAnswer:SetupAnswer( v, Count, TotalCount )
			
			table.insert( self.Children, NewAnswer )
			
			Count = Count + 1
		
		end
		
		return true
		
	end

	return false
end

function PANEL:DisperseSelf( iginore )

	if self.Children  then
		for k, v in pairs( self.Children ) do
			
			if IsValid( v ) && v != iginore then
				v:DisapearAnswer()
			end
		
		end	
	end
	
	self:GoDisapear()

end

local function GetParaseText( str )
	return "<font="..FONT.."><color=ltgrey>" .. str .. "</color></font>"
end

function PANEL:GetQuestion()

	if type( self.Table.Text ) == "function" then
		return GetParaseText( self.Table.Text( self.Table.data ) )
	end
	
	return GetParaseText( self.Table.Text )

end
 
function PANEL:GetAnswer()

	if type( self.Table.Response ) == "function" then
		return GetParaseText( self.Table.Response( self.Table.data ) )
	end
	
	return GetParaseText( self.Table.Response )

end

function PANEL:GetResponses()

	local Response = self.Table.Responses
	
	if type( Response ) == "function" then
		Response = Response( self.Table.data )
	end
	
	if type( Response ) == "table" then
		return Response
	end
	
	return {
		{
			Response = "Good Bye"
		}
	}

end

function PANEL:PanelToMarkup()
	self:SetSize( 
		self.Markup:GetWidth() + EXTRAWIDTH , 
		self.Markup:GetHeight() + EXTRAHEIGHT 
	)
end

function PANEL:AnglePos( angle, distance )
	
	self:SetPos(
		ScrW() * 0.5 + math.cos( angle or 0 ) * distance - self:GetWide() * 0.5,
		ScrH() * 0.5 - math.sin( angle or 0 ) * distance - self:GetTall() * 0.5
	)

end


vgui.Register("GtowerChatQuestion",PANEL, "Panel")