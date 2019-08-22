
GtowerMessages = {}
GtowerMessages.MsgObjs = {}
GtowerMessages.Type = 1
GtowerMessages.IsOpen = false
GtowerMessages.Dark = CreateClientConVar( "gmt_darknotif", 0, true, false )
--
GtowerMessages.ClosedAlpha = 230
GtowerMessages.ButtonAlpha = 150
GtowerMessages.ButtonOffAlpha = 0
GtowerMessages.OpnedAlpha  = 230
GtowerMessages.FullAlpha   = 255
--
if GtowerMessages.Dark:GetBool() then
function Msg2( ... )

    local arg = {...}

    if arg then
        return GtowerMessages:AddNewItem( unpack( arg ) )
    end
end
function GetMessageYPosition()
    return ScrH() - 70
end
function GtowerMessages:CloseMe()
    GtowerMessages.IsOpen = false

    for _, v in pairs( GtowerMessages.MsgObjs ) do

        v:SetTargetAlpha( GtowerMessages:GetCurAlpha( v ) )

        v:ResumeTimer()

    end
end
hook.Add("GtowerHideMenus", "ResumeTimers", GtowerMessages.CloseMe )
--
function GtowerMessages:AddNewItem(text, time, autoclose)
    local NewItem = vgui.Create( "GtowerNewMessage" )
    NewItem:SetText( text )
    NewItem:SetTargetAlpha( self:GetCurAlpha( NewItem ) )

    if time != nil then
        NewItem:SetDuration( time, true )
    end

    NewItem:SetAutoClose( autoclose != false )

    if self.IsOpen == true && NewItem:GetAutoClose() == true then
        NewItem:StopTimer()
    end

    table.insert( self.MsgObjs, NewItem )

    self:Invalidate()

	Msg( text .. "\n" )

    return NewItem
end

function GtowerMessages:GetCurAlpha( panel )
    if panel != nil && panel.Hovered then
        return self.FullAlpha
    end

    return self.IsOpen && self.OpnedAlpha || self.ClosedAlpha

end
--
function GtowerMessages:OpenMe()
    GtowerMessages.IsOpen = true

    for _, v in pairs( self.MsgObjs ) do

        v:SetTargetAlpha( self:GetCurAlpha( v ) )

        if v:GetAutoClose() == true then
            v:StopTimer()
        end

    end
end
--
--
function GtowerMessages:RemovePanel( panel )
    local id = nil

    for k, v in pairs( self.MsgObjs ) do
        if v != nil && v == panel then

            table.remove( self.MsgObjs, k ):Remove() // remove the object, and delete the panel

            break
        end
    end

    self:Invalidate()
end
--
--
function GtowerMessages:Invalidate()
    local TempTable = table.Copy( self.MsgObjs )

    table.sort( TempTable,
        function(a,b)
            return a.DieTime < b.DieTime
        end
    )

    local CurY = (self.Type == 1 && GetMessageYPosition ) && (GetMessageYPosition() - 50) or 50

    for _, v in pairs ( TempTable ) do
        v:SetTargetY( CurY )

        if self.Type == 1 then
            CurY = CurY - v:GetTall() - 1
        else
            CurY = CurY + v:GetTall() + 1
        end


    end
end
--
local PANEL = {}
--
AccessorFunc( PANEL, "bAutoClose", "AutoClose" )
--
function PANEL:Init()

    self.ReadyToDraw = true
    self.TargetX = 0
    self.TargetY = 0

    self:SetDuration( 10 )
    self:SetAutoClose( true )

    self.TextHeight = 5
    self.TextStartY = 0

    self.TargetAlpha = 230
    self.Alpha = 255

    self.Color = Color(10, 10, 10)
    self.ProgressColor = Color( 255, 255, 255 )
    self.TextColor = Color(255, 255, 255)

    self.Text = {}

    self.Timeleft = nil
    self.Question = nil
    self.QuestionAnswered = false

    self.Extra = nil

	self.TextXPos = 8
end
--
function PANEL:SetDuration( time , reset )
    self.Duration = time

    if self.DieTime != nil && reset != true then

        self.DieTime = CurTime() - (self.DieTime - CurTime()) + time

    else

        self.DieTime = CurTime() + time

    end

end
--
function PANEL:HasQuestion()
    return self.Question != nil
end
--
function PANEL:SetTargetY( GoY )
    self.TargetY = GoY
end
--
--

function PANEL:SetIcon( iconname )

	self.Icon = Material("gmod_tower/panelos/icons/"..iconname..".png")
	if self.Icon then

		self.IconName = iconname

		self.TextXPos = 32 + 4

	end

end

function PANEL:SetupQuestion( YesFunction, NoFunction, TimeoutFunction, extra, YesColor, NoColor ) //YesText, NoText

    local YesPanel = vgui.Create("GtowerMessageQuestion", self)
    local NoPanel = vgui.Create("GtowerMessageQuestion", self)

    YesPanel:SetFunc( YesFunction, NoPanel, surface.GetTextureID("icons/accept.vtf"), true )// YesText,
    NoPanel:SetFunc( NoFunction, YesPanel,  surface.GetTextureID("icons/decline.vtf"), false ) //NoText,

    if YesColor != nil then
        YesPanel:SetColor( YesColor[1], YesColor[2], YesColor[3] )
    end

    if NoColor != nil then
        NoPanel:SetColor( NoColor[1], NoColor[2], NoColor[3] )
    end

    self.Question = { YesPanel, NoPanel, TimeoutFunction }

    self.Extra = extra

	self.TextXPos = 58

	YesPanel:SetVisible( true )
	NoPanel:SetVisible( true )

    self:InvalidateLayout()
end

function PANEL:GetExtra()
    return self.Extra
end
--
function PANEL:SetTargetAlpha( alpha )
    self.TargetAlpha = alpha
end
--
function PANEL:SetColor( color )
  self.Color = color
end
--
function PANEL:SetTextColor( color )
  self.TextColor = color

  if color == Color(0,0,0,255) then self.ProgressColor = Color( 0,0,0 ) end

end
--
function PANEL:SetFriendIcon( ply )

  if ply then

	   local Avatar = vgui.Create( "AvatarImage", self )
     Avatar:SetSize( 28, 28 )
     Avatar:SetPlayer( ply, 28 )

	   self.TextXPos = 28 + 4

  end

end

--
function PANEL:Show()
    if GtowerMessages.Type == 1 then
        self.TargetX = ScrW() - self:GetWide()
    else
        self.TargetX = 0
    end
end
--
function PANEL:GetHidingPos()
    if GtowerMessages.Type == 1 then
        return ScrW()
    else
        return -self:GetWide()
    end
end
--
--
function PANEL:Hide( NoTimout, force )
    self.TargetX = self:GetHidingPos()
    self.Removing = true

    if NoTimout != true && self:HasQuestion() then
        if self.Question[3] != nil then
            self.Question[3]( self:GetExtra() )
        end
    end

    if force == true then
        self.DieTime = 0.0
    end
end
--
function PANEL:IsHiding()
    return self.TargetX == self:GetHidingPos()
end
--
function PANEL:SetText( text )
    self.Text = string.Explode( "\n", text )
    if string.StartWith( self.Text[1], "You've spent" ) then
      self.bgflash = true
      self:SetColor(Color( 50, 0, 0 ))
      self:SetIcon("money")
    elseif string.StartWith( self.Text[1], "You've earned" ) then
      self.bgflash = true
      self:SetColor(Color( 0, 50, 0 ))
      self:SetIcon("money")
    elseif string.StartWith( self.Text[1], "RESETTING YOUR DATA" ) then
      self.bgflash = true
      self:SetColor(Color( 0, 50, 0 ))
      self:SetIcon("exclamation")
      self.ProgressColor = Color( 0, 0, 0 )
      self:StopTimer()
    end

    if self.Color == Color( 255, 200, 14 ) then
      self.bgflash = true
    end

    self:InvalidateLayout()
end
--
--
--
function PANEL:StopTimer()
    self.Timeleft = self.DieTime - CurTime()
end

function PANEL:ResumeTimer()
    if self.Timeleft == nil then return end

    self.DieTime = CurTime() + self.Timeleft
    self.Timeleft = nil
end
--
--

function PANEL:Answered( accepted )
    self.QuestionAnswered = true
    self.Accepted = accepted
end
surface.CreateFont( "GtowerMessage", { font = "Arial", size = 16, weight = 600 } )
function PANEL:Paint( w, h )

    if !self.ReadyToDraw then return end

    local Wide, Tall = self:GetWide(), self:GetTall()
    local color

    // BG
    color = self.Color
    surface.SetDrawColor( color.r, color.g, color.b, self.Alpha )
    surface.DrawRect( 0,0, Wide, Tall )

		local alpha = self.Alpha

		if self.bgflash then alpha = alpha * SinBetween(.5,1,RealTime() * 5) end



		surface.SetDrawColor( color.r, color.g, color.b, alpha )


    // Text
    color = self.TextColor
    surface.SetFont( "GtowerMessage" )
    surface.SetTextColor( color.r, color.g, color.b, math.Clamp( self.Alpha * 2.5 , 128, 255 ) )

    local Height = 0

    if self.Icon then

		  surface.SetDrawColor( color.r, color.g, color.b, self.Alpha )

		  surface.SetMaterial( self.Icon )

		  surface.DrawTexturedRect( 0, -2, 32, 32 )

    end

    // Draw text
    for k, v in pairs( self.Text ) do

        local w, h = surface.GetTextSize( v )

        surface.SetTextPos( self.TextXPos, Height + self.TextStartY )
        surface.DrawText( v )

        Height = Height + h + 2

    end

    // Progress bar
    color = self.ProgressColor
    surface.SetDrawColor( color.r, color.g, color.b, self.Alpha )

    if self.Timeleft == nil then
        surface.DrawRect( 0, Tall - 2, Wide * ( ( self.DieTime - CurTime()) / self.Duration ), 2 )
    else
        surface.DrawRect( 0, Tall - 2, Wide * ( self.Timeleft / self.Duration ), 2 )
    end


    // Draw colors when they accept/deny
    if !self.QuestionAnswered then return end

    if self.Accepted then
        surface.SetDrawColor( 0, 255, 0, 128 )
    else
        surface.SetDrawColor( 255, 0, 0, 128 )
    end

    surface.DrawRect( 0, 0, Wide, Tall )

end
--
function PANEL:OnCursorEntered()
    self:SetTargetAlpha( GtowerMessages.FullAlpha )
end
--
function PANEL:OnCursorExited( )
    self:SetTargetAlpha( GtowerMessages:GetCurAlpha( self ) )
end
--
function PANEL:Think()

    if self.x != self.TargetX || self.y != self.TargetY then

        self:SetPos(
            ApproachSupport( self.x, self.TargetX, 6 ) ,
            ApproachSupport2( self.y, self.TargetY, 15 )
        )

        if self.x == self.TargetX && self:IsHiding() then
            GtowerMessages:RemovePanel( self )
        end
    end


    if self.Alpha != self.TargetAlpha then
        self.Alpha = ApproachSupport2( self.Alpha , self.TargetAlpha, 8 )
    end

    if self.Timeleft == nil && self.DieTime < CurTime() && !self:IsHiding() then
        self:Hide()
    end
end
--
--
function PANEL:PerformLayout()
    local Width, Height = 0,0

    surface.SetFont("GtowerMessage")

    for _, v in pairs( self.Text ) do
        local w, h = surface.GetTextSize( v )

        Height = Height + h + 2

        if h > self.TextHeight then
            self.TextHeight = h
        end

        if w > Width then
            Width = w
        end

    end

    self:SetSize( Width + 10 + self.TextXPos, Height + 10)
    self:SetPos( self:GetHidingPos() , self.y )

    self.TextStartY = self:GetTall() / 2 - Height / 2
    self:Show()


    if self:HasQuestion() then
        local YesPanel = self.Question[1]
        local NoPanel =  self.Question[2]

        YesPanel:SetPos( 0, 0 )
        NoPanel:SetPos( 26, 0 )

    end

end
vgui.Register("GtowerNewMessage",PANEL, "Panel")
--
--
--
--
--
--
--
--
local PANEL = {}
function PANEL:Init()
    self.Function = nil
    //self.Text = ""

    //self.TextX = 0
    //self.TextY = 0

    self.Color = Color(255,255,255, GtowerMessages.ButtonAlpha)
    self.TargetAlpha = GtowerMessages.ButtonAlpha

    self.Brother = nil

	self.BtnTexture = nil
	//self.Texturesize = 16
end

function PANEL:SetFunc( Function, brother, texture, accept )

    self.Function = Function
    //self.Text = Text

    self.Brother = brother

    if texture then
        self.BtnTexture = texture
        //self.Texturesize = surface.GetTextureSize( texture.img )
    end

    self.AcceptButton = accept

    self:InvalidateLayout()

end

function PANEL:OnMouseReleased()

    if self.Function != nil then

        local parent = self:GetParent()

        if parent.QuestionAnswered == true then return end

        self.Function( parent:GetExtra() )
        parent:Hide( true, true )
        parent:Answered( self.AcceptButton )

    end

end

function PANEL:SetColor(r,g,b)
    self.Color.r = r or 255
    self.Color.b = b or 255
    self.Color.g = g or 255
end

function PANEL:Paint( w, h )

    //draw.RoundedBox( 4, 0,0, self:GetWide(), self:GetTall(), self.Color )

    local alpha = 255

    if self:GetParent().Removing || self:GetParent().QuestionAnswered then
        alpha = GtowerMessages.ButtonAlpha
    end

    surface.SetDrawColor( 255, 255, 255, alpha )
    surface.SetTexture( self.BtnTexture )
    surface.DrawTexturedRect( 0, 0, self:GetWide(), self:GetTall() )

    surface.SetDrawColor( 3, 25, 54, self.Color.a )
    surface.DrawRect( 0, 0, 26, 26 )

    /*if self.Hovered then
        surface.SetFont("small")
        surface.SetTextColor( 255, 255, 255, self.Color.a )
        surface.SetTextPos( self.TextX, self.TextY )
        surface.DrawText( self.Text )
    end*/

end

function PANEL:IsMouseOver()

    local x,y = self:CursorPos()
    return x >= 0 and y >= 0 and x <= 26 and y <= 26

end

function PANEL:Think()

    if self:IsMouseOver() then
        self.TargetAlpha = GtowerMessages.ButtonAlpha
        self:GetParent():SetTargetAlpha( GtowerMessages.FullAlpha )
    else
        self.TargetAlpha = GtowerMessages.ButtonOffAlpha
    end

    if self.TargetAlpha != self.Color.a then
        self.Color.a = math.Approach( self.Color.a , self.TargetAlpha, FrameTime() * 600 )
    end

end

function PANEL:PerformLayout()

    self:SetSize( 32, 32 )

    /*local w, h = surface.GetTextSize( self.Text )

    self.TextX = self:GetWide() / 2 - w / 2
    self.TextY = self:GetTall() / 2 - h / 2*/

end
vgui.Register("GtowerMessageQuestion",PANEL, "Panel")
else
function Msg2( ... )

    local arg = {...}

    if arg then
        return GtowerMessages:AddNewItem( unpack( arg ) )
    end
end
function GetMessageYPosition()
    return ScrH() - 70
end
function GtowerMessages:CloseMe()
    GtowerMessages.IsOpen = false

    for _, v in pairs( GtowerMessages.MsgObjs ) do

        v:SetTargetAlpha( GtowerMessages:GetCurAlpha( v ) )

        v:ResumeTimer()

    end
end
hook.Add("GtowerHideMenus", "ResumeTimers", GtowerMessages.CloseMe )
--
function GtowerMessages:AddNewItem(text, time, autoclose)
    local NewItem = vgui.Create( "GtowerNewMessage" )
    NewItem:SetText( text )
    NewItem:SetTargetAlpha( self:GetCurAlpha( NewItem ) )

    if time != nil then
        NewItem:SetDuration( time, true )
    end

    NewItem:SetAutoClose( autoclose != false )

    if self.IsOpen == true && NewItem:GetAutoClose() == true then
        NewItem:StopTimer()
    end

    table.insert( self.MsgObjs, NewItem )

    self:Invalidate()

	Msg( text .. "\n" )

    return NewItem
end

function GtowerMessages:GetCurAlpha( panel )
    if panel != nil && panel.Hovered then
        return self.FullAlpha
    end

    return self.IsOpen && self.OpnedAlpha || self.ClosedAlpha

end
--
function GtowerMessages:OpenMe()
    GtowerMessages.IsOpen = true

    for _, v in pairs( self.MsgObjs ) do

        v:SetTargetAlpha( self:GetCurAlpha( v ) )

        if v:GetAutoClose() == true then
            v:StopTimer()
        end

    end
end
--
--
function GtowerMessages:RemovePanel( panel )
    local id = nil

    for k, v in pairs( self.MsgObjs ) do
        if v != nil && v == panel then

            table.remove( self.MsgObjs, k ):Remove() // remove the object, and delete the panel

            break
        end
    end

    self:Invalidate()
end
--
--
function GtowerMessages:Invalidate()
    local TempTable = table.Copy( self.MsgObjs )

    table.sort( TempTable,
        function(a,b)
            return a.DieTime < b.DieTime
        end
    )

    local CurY = (self.Type == 1 && GetMessageYPosition ) && (GetMessageYPosition() - 50) or 50

    for _, v in pairs ( TempTable ) do
        v:SetTargetY( CurY )

        if self.Type == 1 then
            CurY = CurY - v:GetTall() - 1
        else
            CurY = CurY + v:GetTall() + 1
        end


    end
end
--
local PANEL = {}
--
AccessorFunc( PANEL, "bAutoClose", "AutoClose" )
--
function PANEL:Init()

    self.ReadyToDraw = true
    self.TargetX = 0
    self.TargetY = 0

    self:SetDuration( 10 )
    self:SetAutoClose( true )

    self.TextHeight = 5
    self.TextStartY = 0

    self.TargetAlpha = 230
    self.Alpha = 255

    self.Color = Color(16, 70, 101)
    self.ProgressColor = Color( 111, 237, 29 )
    self.TextColor = Color(255, 255, 255)

    self.Text = {}

    self.Timeleft = nil
    self.Question = nil
    self.QuestionAnswered = false

    self.Extra = nil

	self.TextXPos = 8
end
--
function PANEL:SetDuration( time , reset )
    self.Duration = time

    if self.DieTime != nil && reset != true then

        self.DieTime = CurTime() - (self.DieTime - CurTime()) + time

    else

        self.DieTime = CurTime() + time

    end

end
--
function PANEL:HasQuestion()
    return self.Question != nil
end
--
function PANEL:SetTargetY( GoY )
    self.TargetY = GoY
end
--
--

function PANEL:SetIcon( iconname )
	self.Icon = Material("gmod_tower/panelos/icons/"..iconname..".png")
	if self.Icon then
		self.IconName = iconname
		self.TextXPos = 32 + 4
	end
end

function PANEL:SetupQuestion( YesFunction, NoFunction, TimeoutFunction, extra, YesColor, NoColor ) //YesText, NoText

    local YesPanel = vgui.Create("GtowerMessageQuestion", self)
    local NoPanel = vgui.Create("GtowerMessageQuestion", self)

    YesPanel:SetFunc( YesFunction, NoPanel, surface.GetTextureID("icons/accept.vtf"), true )// YesText,
    NoPanel:SetFunc( NoFunction, YesPanel,  surface.GetTextureID("icons/decline.vtf"), false ) //NoText,

    if YesColor != nil then
        YesPanel:SetColor( YesColor[1], YesColor[2], YesColor[3] )
    end

    if NoColor != nil then
        NoPanel:SetColor( NoColor[1], NoColor[2], NoColor[3] )
    end

    self.Question = { YesPanel, NoPanel, TimeoutFunction }

    self.Extra = extra

	self.TextXPos = 58

	YesPanel:SetVisible( true )
	NoPanel:SetVisible( true )

    self:InvalidateLayout()
end

function PANEL:GetExtra()
    return self.Extra
end
--
function PANEL:SetTargetAlpha( alpha )
    self.TargetAlpha = alpha
end
--
function PANEL:SetColor( color )
  self.Color = color
end
--
function PANEL:SetTextColor( color )
  self.TextColor = color

  if color == Color(0,0,0,255) then self.ProgressColor = Color( 0,0,0 ) end

end
--
function PANEL:SetFriendIcon( ply )

  if ply then

	   local Avatar = vgui.Create( "AvatarImage", self )
     Avatar:SetSize( 28, 28 )
     Avatar:SetPlayer( ply, 28 )

	   self.TextXPos = 28 + 4

  end

end

--
function PANEL:Show()
    if GtowerMessages.Type == 1 then
        self.TargetX = ScrW() - self:GetWide()
    else
        self.TargetX = 0
    end
end
--
function PANEL:GetHidingPos()
    if GtowerMessages.Type == 1 then
        return ScrW()
    else
        return -self:GetWide()
    end
end
--
--
function PANEL:Hide( NoTimout, force )
    self.TargetX = self:GetHidingPos()
    self.Removing = true

    if NoTimout != true && self:HasQuestion() then
        if self.Question[3] != nil then
            self.Question[3]( self:GetExtra() )
        end
    end

    if force == true then
        self.DieTime = 0.0
    end
end
--
function PANEL:IsHiding()
    return self.TargetX == self:GetHidingPos()
end
--
function PANEL:SetText( text )
    self.Text = string.Explode( "\n", text )
    /*if string.StartWith( self.Text[1], "You've spent" ) then
      self.bgflash = true
      self:SetColor(Color( 50, 0, 0 ))
      self:SetIcon("money")
    elseif string.StartWith( self.Text[1], "You've earned" ) then
      self.bgflash = true
      self:SetColor(Color( 0, 50, 0 ))
      self:SetIcon("money")
    elseif string.StartWith( self.Text[1], "RESETTING YOUR DATA" ) then
      self.bgflash = true
      self:SetColor(Color( 0, 50, 0 ))
      self:SetIcon("exclamation")
      self.ProgressColor = Color( 0, 0, 0 )
      self:StopTimer()
    end*/

    if self.Color == Color( 255, 200, 14 ) then
      self.bgflash = true
    end

    self:InvalidateLayout()
end
--
--
--
function PANEL:StopTimer()
    self.Timeleft = self.DieTime - CurTime()
end

function PANEL:ResumeTimer()
    if self.Timeleft == nil then return end

    self.DieTime = CurTime() + self.Timeleft
    self.Timeleft = nil
end
--
--

function PANEL:Answered( accepted )
    self.QuestionAnswered = true
    self.Accepted = accepted
end
surface.CreateFont( "GtowerMessage", { font = "Arial", size = 16, weight = 600 } )
function PANEL:Paint( w, h )

    if !self.ReadyToDraw then return end

    local Wide, Tall = self:GetWide(), self:GetTall()
    local color

    // BG
    color = self.Color
    surface.SetDrawColor( color.r, color.g, color.b, self.Alpha )
    surface.DrawRect( 0,0, Wide, Tall )

		local alpha = self.Alpha
		if self.bgflash then alpha = alpha * SinBetween(.5,1,RealTime() * 5) end

		surface.SetDrawColor( color.r, color.g, color.b, alpha )

    // Text
    color = self.TextColor
    surface.SetFont( "GtowerMessage" )
    surface.SetTextColor( color.r, color.g, color.b, math.Clamp( self.Alpha * 2.5 , 128, 255 ) )

    local Height = 0

    if self.Icon then
		  surface.SetDrawColor( color.r, color.g, color.b, self.Alpha )
		  surface.SetMaterial( self.Icon )
		  surface.DrawTexturedRect( 0, -2, 32, 32 )
    end

    // Draw text
    for k, v in pairs( self.Text ) do

        local w, h = surface.GetTextSize( v )

        surface.SetTextPos( self.TextXPos, Height + self.TextStartY )
        surface.DrawText( v )

        Height = Height + h + 2

    end

    // Progress bar
    color = self.ProgressColor
    surface.SetDrawColor( color.r, color.g, color.b, self.Alpha )

    if self.Timeleft == nil then
        surface.DrawRect( 0, Tall - 2, Wide * ( ( self.DieTime - CurTime()) / self.Duration ), 2 )
    else
        surface.DrawRect( 0, Tall - 2, Wide * ( self.Timeleft / self.Duration ), 2 )
    end


    // Draw colors when they accept/deny
    if !self.QuestionAnswered then return end

    if self.Accepted then
        surface.SetDrawColor( 0, 255, 0, 128 )
    else
        surface.SetDrawColor( 255, 0, 0, 128 )
    end

    surface.DrawRect( 0, 0, Wide, Tall )

end
--
function PANEL:OnCursorEntered()
    self:SetTargetAlpha( GtowerMessages.FullAlpha )
end
--
function PANEL:OnCursorExited( )
    self:SetTargetAlpha( GtowerMessages:GetCurAlpha( self ) )
end
--
function PANEL:Think()

    if self.x != self.TargetX || self.y != self.TargetY then

        self:SetPos(
            ApproachSupport( self.x, self.TargetX, 6 ) ,
            ApproachSupport2( self.y, self.TargetY, 15 )
        )

        if self.x == self.TargetX && self:IsHiding() then
            GtowerMessages:RemovePanel( self )
        end
    end


    if self.Alpha != self.TargetAlpha then
        self.Alpha = ApproachSupport2( self.Alpha , self.TargetAlpha, 8 )
    end

    if self.Timeleft == nil && self.DieTime < CurTime() && !self:IsHiding() then
        self:Hide()
    end
end
--
--
function PANEL:PerformLayout()
    local Width, Height = 0,0

    surface.SetFont("GtowerMessage")

    for _, v in pairs( self.Text ) do
        local w, h = surface.GetTextSize( v )

        Height = Height + h + 2

        if h > self.TextHeight then
            self.TextHeight = h
        end

        if w > Width then
            Width = w
        end

    end

    self:SetSize( Width + 10 + self.TextXPos, Height + 10)
    self:SetPos( self:GetHidingPos() , self.y )

    self.TextStartY = self:GetTall() / 2 - Height / 2
    self:Show()


    if self:HasQuestion() then
        local YesPanel = self.Question[1]
        local NoPanel =  self.Question[2]

        YesPanel:SetPos( 0, 0 )
        NoPanel:SetPos( 26, 0 )

    end

end
vgui.Register("GtowerNewMessage",PANEL, "Panel")
--
--
--
--
--
--
--
--
local PANEL = {}
function PANEL:Init()
    self.Function = nil
    //self.Text = ""

    //self.TextX = 0
    //self.TextY = 0

    self.Color = Color(255,255,255, GtowerMessages.ButtonAlpha)
    self.TargetAlpha = GtowerMessages.ButtonAlpha

    self.Brother = nil

	self.BtnTexture = nil
	//self.Texturesize = 16
end

function PANEL:SetFunc( Function, brother, texture, accept )

    self.Function = Function
    //self.Text = Text

    self.Brother = brother

    if texture then
        self.BtnTexture = texture
        //self.Texturesize = surface.GetTextureSize( texture.img )
    end

    self.AcceptButton = accept

    self:InvalidateLayout()

end

function PANEL:OnMouseReleased()

    if self.Function != nil then

        local parent = self:GetParent()

        if parent.QuestionAnswered == true then return end

        self.Function( parent:GetExtra() )
        parent:Hide( true, true )
        parent:Answered( self.AcceptButton )

    end

end

function PANEL:SetColor(r,g,b)
    self.Color.r = r or 255
    self.Color.b = b or 255
    self.Color.g = g or 255
end

function PANEL:Paint( w, h )

    //draw.RoundedBox( 4, 0,0, self:GetWide(), self:GetTall(), self.Color )

    local alpha = 255

    if self:GetParent().Removing || self:GetParent().QuestionAnswered then
        alpha = GtowerMessages.ButtonAlpha
    end

    surface.SetDrawColor( 255, 255, 255, alpha )
    surface.SetTexture( self.BtnTexture )
    surface.DrawTexturedRect( 0, 0, self:GetWide(), self:GetTall() )

    surface.SetDrawColor( 3, 25, 54, self.Color.a )
    surface.DrawRect( 0, 0, 26, 26 )

    /*if self.Hovered then
        surface.SetFont("small")
        surface.SetTextColor( 255, 255, 255, self.Color.a )
        surface.SetTextPos( self.TextX, self.TextY )
        surface.DrawText( self.Text )
    end*/

end

function PANEL:IsMouseOver()

    local x,y = self:CursorPos()
    return x >= 0 and y >= 0 and x <= 26 and y <= 26

end

function PANEL:Think()

    if self:IsMouseOver() then
        self.TargetAlpha = GtowerMessages.ButtonAlpha
        self:GetParent():SetTargetAlpha( GtowerMessages.FullAlpha )
    else
        self.TargetAlpha = GtowerMessages.ButtonOffAlpha
    end

    if self.TargetAlpha != self.Color.a then
        self.Color.a = math.Approach( self.Color.a , self.TargetAlpha, FrameTime() * 600 )
    end

end

function PANEL:PerformLayout()

    self:SetSize( 32, 32 )

    /*local w, h = surface.GetTextSize( self.Text )

    self.TextX = self:GetWide() / 2 - w / 2
    self.TextY = self:GetTall() / 2 - h / 2*/

end
vgui.Register("GtowerMessageQuestion",PANEL, "Panel")
end