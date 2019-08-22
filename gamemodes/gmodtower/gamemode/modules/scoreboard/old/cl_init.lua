
GtowerScoreBoard = {}
GtowerScoreBoard.Panel = nil

include("cl_item.lua")
include("cl_players.lua")
include("cl_settings.lua")

local function DefaultSize()
	return math.Clamp( ScrW() * 0.65, 640, ScrW() * 0.85 )
end


local PANEL = {}

function PANEL:Init()
    self.Items = {}
    
    GtowerScoreBoard.Panel = self
    
    self:GetInsertItems()    
    
    self.Frame = vgui.Create( "Panel", self )
    self.VBar = vgui.Create( "SlideBar", self )
	
	self.Resizer = vgui.Create("GTowerResizer" )
	self.Resizer:SetSettingName( "scoreboard_size" )
	self.Resizer:BothSides( true )
	self.Resizer.DefaultValue = DefaultSize()
	self.Resizer:SetMinMax( 640, ScrW() * 0.85 )
	self.Resizer:OnChange( 
		function(value)
            if type(GtowerScoreBoard.Panel) == "Panel" then
                GtowerScoreBoard.Panel:ConfigSize()
            end
        end
	)
    
    self:SetSelected( self.Items[1] )
    
    self.CurHeight = 824
    self.TargetHeight = ScrH() * 0.95
    
    self.Frame:SetPos(0, 48)
    
    self.IsTooBig = false
end

function PANEL:GetInsertItems()

	self:InsertItem( "Player List" , "ScoreBoardPlayers")
	
	
	local HookTable = hook.GetTable().GTowerScoreBoard
	
	if HookTable then
		for _, v in pairs( HookTable ) do
			
			local NewItem = v()
			
			self:InsertItem( NewItem["Name"] , NewItem["vgui"] )
		
		end
	end
	
	self:InsertItem( "Settings" , "ScoreBoardSettings" )
end

function PANEL:GetPanel()
    return self.Selected.Panel
end

function PANEL:GetFrame()
    return self.Frame
end

function PANEL:SelectedObj()
    return self.Selected
end


function PANEL:OnMouseWheeled( dlta )
	self.VBar:AddVelocity( dlta )
end

function PANEL:SetChildScroll()
	local panel = self:GetPanel()
	local MaxOffset = self:GetPanel():GetTall() - self.Frame:GetTall()
	
	self.YOffset = MaxOffset * self.VBar:Value()
	panel:SetPos( panel.x, self.YOffset * -1)
end

function PANEL:Think()
    
	if self.TargetHeight != self.CurHeight then
		self.CurHeight = ApproachSupport( self.CurHeight, self.TargetHeight, 6 )
		self:ConfigSize()
	end

	if self.VBar:Changed() then
		self:SetChildScroll()
	end
    
    
end

function PANEL:SetTargetTall( tall, who )
    if who != self:GetPanel() then return end

    self.TargetHeight = tall + 48 + 5
    
    self.IsTooBig = self.TargetHeight > ScrH() * 0.8
    self.VBar:SetVisible( self.IsTooBig )
    
    if !self.IsTooBig then
        self.VBar:SetScroll(0)
        self:SetChildScroll()
    end

    self:ConfigVBar()
    
end

function PANEL:ConfigVBar()
	if self.IsTooBig == true then
        self.TargetHeight = ScrH() * 0.8        
        
        self.Frame:SetSize( self:GetWide() - 18, self:GetTall() - 51 )
    
        self.VBar:SetPos( self:GetWide() - 18, 50 )
        self.VBar:SetSize( 16, self:GetTall() - 52 )
        self.VBar:SetBarScale( self:GetPanel():GetTall() / self.Frame:GetTall() )
    else
        self.Frame:SetSize( self:GetWide(), self:GetTall() - 51 )
    end
	
	 self:GetPanel():SetSize( self.Frame:GetWide(), self:GetPanel():GetTall() )
end

function PANEL:ConfigSize()
    self:SetSize(cookie.GetNumber( "scoreboard_size" ) or DefaultSize() , self.CurHeight )
    
    self:SetPos( ScrW() / 2 - self:GetWide() / 2, ScrH() / 2 - self:GetTall() / 2 ) 
    
    local CurX = 0
    local WidthForEach = self:GetWide() / #self.Items
    
    for k, v in pairs( self.Items ) do
        v:SetPos( CurX , 0)
        
        if k == #self.Items then  //calculate the amount left
            WidthForEach = self:GetWide() - CurX
        end
        
        v:SetSize( WidthForEach, 48 )
        
        CurX = CurX + v:GetWide()
        
        v:InvalidateLayout()
    end
	
	self:ConfigVBar()
	
	if self.Resizer then
		self.Resizer:SetSize( self:GetWide() + 4, self:GetTall() )
		self.Resizer:SetPos( self.x - 2, self.y  )
	end
    
end


function PANEL:SetSelected( panel )

    if panel == self.Selected then return end
	
	GtowerMenu:CloseAll()

    local IsLeft = true
    
    if self.Selected != nil then
    
        IsLeft = self.Selected.Id < panel.Id
        
        self.Selected:InvalidateLayout()
        self.Selected:HidePanel( IsLeft )
    
    end 
    
    panel:ShowPanel( IsLeft )
    panel:InvalidateLayout(true)
    
    self.Selected = panel
    
    self:ConfigSize()
end


function PANEL:InsertItem(Name, panelName)
    
    local panel = vgui.Create( "ScoreBoardItem", self)
    local NumItems = #self.Items
    local LastPanel = self.Items[ NumItems ]
    
    panel:SetText   ( Name )
    panel:SetIsFirst( NumItems == 0 )
    panel:SetIsLast ( true )
    panel:SetMyPanel( panelName )
    
    
    if LastPanel != nil then
        LastPanel:SetIsLast( false )
        
        LastPanel:InvalidateLayout()
    end
    
    
    panel:SetId( table.insert( self.Items, panel ) )
end

function PANEL:Paint()
	derma.SkinHook( "Paint", "Scoreboard", self )
end

function PANEL:NormalItemWidth()
    return self:GetWide() / #self.Items 
end





function PANEL:PerformLayout()
   
end


function PANEL:UpdateScoreboard( open )

	if open == true then
		
		if !self.Selected then
			self:SetSelected( self.Items[1] )
			self:ConfigSize()
		
		elseif self.Selected.Panel && type( self.Selected.Panel.ScoreboardOpen ) == "function" then
			self.Selected.Panel:ScoreboardOpen()
		end
		
		if self.Resizer then
			self.Resizer:SetVisible( true )
		end
	
	else
		if self.Resizer then
			self.Resizer:SetVisible( false )
		end
	end

end



vgui.Register("ScoreBoard",PANEL, "Panel")
