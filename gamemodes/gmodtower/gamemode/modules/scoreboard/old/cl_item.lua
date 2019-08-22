
local MiddleSelected   = surface.GetTextureID( 'scoreboard/middle_selected' )
local MiddleUnselected = surface.GetTextureID( 'scoreboard/middle_unselected' )

local TopRightSelected   = surface.GetTextureID( 'scoreboard/top_right_corner' )
local TopLeftSelected    = surface.GetTextureID( 'scoreboard/top_left_corner' )
local TopRightUnselected = surface.GetTextureID( 'scoreboard/top_right_unselected' )
local TopLeftUnselected  = surface.GetTextureID( 'scoreboard/top_left_unselected' )

local ItemFont = "Gtowerbig"

local PANEL = {}

function PANEL:Init()
    self.Items = {}
	
	self:SetCursor("hand")

    self.IsFirst = false
    self.IsLast  = false
    
    self.MiddleTexture = MiddleUnselected
    self.LeftTexture   = nil
    self.RightTexture  = nil
    
    
    self.MiddlePosStart = 0
    self.MiddleWidth    = self:GetWide()
    
    self.RightPos = self:GetWide() - 16
    
    self.PanelName = ""
    self.Panel = nil
    self.PanelTarget = 0
    
    self.Text = ""
    self.TextX = 0
    self.TextY = 0
    
   // self.TextWhite = 255
	self.HoverTime = 0
    
    self.Id = 0
end

function PANEL:OnCursorEntered()
	if !self:IsSelected() then
		self.HoverTime = CurTime()
	end
end

PANEL.OnCursorExited = PANEL.OnCursorEntered

function PANEL:Think()

    //local TargetWhite = (self.Hovered or self:IsSelected()) and 255 or 124

   // if self.TextWhite != TargetWhite then
   //     self.TextWhite = ApproachSupport2( self.TextWhite, TargetWhite, 4.5 )
    //end
    
    if self.Panel != nil then
        if self.PanelTarget != self.Panel.x then
            
            self.Panel:SetPos( ApproachSupport( self.Panel.x, self.PanelTarget, 5 ), 0 )
            
            if self.Panel.x == self.PanelTarget && self.PanelTarget != 0 then
                self.Panel:Removing()
                self.Panel:Remove()
                self.Panel = nil
            end
        
        end    
        
    end
end

function PANEL:ShowPanel( fromleft )
    local parent = self:GetParent():GetFrame()

    if self.Panel == nil then
        self.Panel = vgui.Create( self.PanelName, parent )
        self.Panel.ItemParent = self
    else
        self.Panel:InvalidateLayout()
    end
    
    self:InvalidateLayout()
    
    
    self.Panel:SetPos( parent:GetWide() * ( fromleft and -1 or 1 ), 0 )
    self.Panel:SetSize( parent:GetWide(), self.Panel:GetTall() )
    self.PanelTarget = 0
    
end

function PANEL:SetTargetTall( tall, who )
    self:GetParent():SetTargetTall( tall, who )
end

function PANEL:HidePanel( fromleft )

    if self.Panel == nil then return end

    self.PanelTarget = self:GetParent():GetFrame():GetWide() * ( fromleft and 1 or -1 )
end

function PANEL:SetId( id )
    self.Id = id
end

function PANEL:IsSelected()
    return self:GetParent():SelectedObj() == self
end

function PANEL:Paint()
	derma.SkinHook( "Paint", "ScoreboardItem", self )
end
 


function PANEL:SetMyPanel( panel )
    self.PanelName = panel    
end


function PANEL:PerformLayout()
    
    self.MiddleWidth = self:GetWide()
    
    if self.IsFirst == true then
        self.MiddlePosStart = 16
        self.MiddleWidth = self.MiddleWidth - 16
    end
    
    if self.IsLast == true then
        self.MiddleWidth = self.MiddleWidth - 16
        self.RightPos = self:GetWide() - 16
    end 
    
    
    if self:IsSelected() == true then
    
        if self.IsFirst == true then
            self.LeftTexture = TopLeftSelected
        end
    
        if self.IsLast == true then
            self.RightTexture = TopRightSelected
        end
        
        self.MiddleTexture = MiddleSelected
        
    else
    
        if self.IsFirst == true then
            self.LeftTexture = TopLeftUnselected
        end
    
        if self.IsLast == true then
            self.RightTexture = TopRightUnselected
        end   
    
        self.MiddleTexture = MiddleUnselected
        
    end    
    
    local w, h = self:GetTextSize()
    
    self.TextX = self:GetWide() / 2 - w / 2
    self.TextY = self:GetTall() / 2 - h / 2
    
end


function PANEL:OnMousePressed()

    self:GetParent():SetSelected( self )
    
end

function PANEL:GetTextSize()
    surface.SetFont( ItemFont )
    
    return surface.GetTextSize( self.Text )
end


function PANEL:SetText( text )  
    self.Text = text or "UnNamed"


    
end

function PANEL:SetIsFirst( state )
    self.IsFirst = state
    
    self:InvalidateLayout()
end

function PANEL:SetIsLast( state ) 
     self.IsLast = state
     
     self:InvalidateLayout()
end


vgui.Register("ScoreBoardItem",PANEL, "Panel")

