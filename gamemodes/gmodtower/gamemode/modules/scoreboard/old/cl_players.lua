
GtowerScoreBoard.Players = {}


local ItemFont = "Gtowerbig"
local Line4  = surface.GetTextureID( 'scoreboard/line4' )
local ScoreBoardPlyData = {}
local TotalWidthSum = 0

local CalledColumnHook = false

function GtowerScoreBoard.Players:Add( Name, pos, width, func, order, admin, img)

	for _, v in pairs( ScoreBoardPlyData ) do
		if v.Name == Name then //No replicates
			return
		end
	end
	
	local tbl = {
		["Name"] = Name,
		["align"] = pos,
		["width"] = width,
		["func"] = func,
		["img"] = img,
		["order"] = order or 1,
	}

    table.insert( ScoreBoardPlyData, tbl )
	
	return tbl
end


GtowerScoreBoard.Players:Add( "Name", 4, 400, function(ply) return "   " .. ply:Name() end, -1 )
GtowerScoreBoard.Players:Add( "Ping", 5, 50, function(ply) return ply:Ping() end, 100 )


GtowerScoreBoard.Players.SortPlayers = function( a, b )
	
	local afrag, bfrag = a:GetPlayer():Frags(), b:GetPlayer():Frags()

	if afrag == bfrag then
		return a:GetPlayer():Deaths() < b:GetPlayer():Deaths()
	end
	
	return afrag > bfrag
	
end




local PANEL = {}
function PANEL:Init()

	if CalledColumnHook  == false then
		hook.Call("GTowerScorePlayer")
		CalledColumnHook = true
	end

	table.sort( ScoreBoardPlyData, function( a, b ) 
		return a.order < b.order		
	end )

    self.DataText = {}

    for _, v in pairs( ScoreBoardPlyData ) do
        
        local panel = vgui.Create("Label", self)
        panel:SetContentAlignment( 5 )
        panel:SetText( v.Name )
        
        table.insert( self.DataText, panel )
        
    end
    
    self.NextUpdate = 0
    
    self.Items = {}
    
    self.TotalHeight = 23
    
    self.ItemParent = nil
end

function PANEL:OnMousePressed()
    GtowerMenu:CloseAll()
end

function PANEL:Removing()


end

function PANEL:Think()
    
    if CurTime() > self.NextUpdate then    
    
        for pl, v in pairs( self.Items ) do
            if !pl:IsValid() then
                
                v:Remove()
                self.Items[ pl ] = nil
                
            end
        end
        
        for _, v in pairs( player.GetAll() ) do
            if self.Items[ v ] == nil then
                
                self.Items[v] = vgui.Create( "ScoreBoardPlayer", self )
                self.Items[v]:SetPlayer( v )

            end            
        end 
        
        
        self.TotalHeight = 23
        local i = false
		local PlayerSorted = {}
		
		for _, v in pairs( self.Items ) do
			table.insert( PlayerSorted, v )
		end
		
		table.sort( PlayerSorted, GtowerScoreBoard.Players.SortPlayers )

        for _, v in pairs( PlayerSorted ) do
        
            v:SetPos(3, self.TotalHeight)
            v:SetSize( self:GetWide() - 6, 25 )
            
            self.TotalHeight = self.TotalHeight + v:GetTall()
            
            if i == false then
                v.Color = 99
            else
                v.Color = 106
            end
            
			v.Alt = i
			i = !i
			
            v:InvalidateLayout()
            
        end
        
        self.ItemParent:SetTargetTall( self.TotalHeight, self )
        
        self:SetSize( self:GetWide(), self.TotalHeight )

        self.NextUpdate = CurTime() + 1.0
    end

end

function PANEL:Paint()
	derma.SkinHook( "Paint", "ScoreboardHeaderItem", self )
end

function PANEL:PaintOver()
    surface.SetDrawColor(255,255,255,255)

    surface.SetTexture( Line4 ) 
    
    for k, v in pairs( self.DataText ) do
        if k != 1 then
            surface.DrawTexturedRect( v.x - 2, 0, 2, self.TotalHeight )
        end
    
    end

end


function PANEL:PerformLayout()

    

    local CurX = 0
    TotalWidthSum = 0
    
    for _, v in pairs( ScoreBoardPlyData ) do
        TotalWidthSum = TotalWidthSum + v.width
    end
    
    
    for k, v in pairs( self.DataText ) do
        v:SetPos( CurX + 3, 0  )
        v:SetSize(  ( ScoreBoardPlyData[k].width / TotalWidthSum ) * self:GetWide() - 3 , 23 )

        
        CurX = CurX + v:GetWide()
        
        v:InvalidateLayout()
    end
	
end



vgui.Register("ScoreBoardPlayers",PANEL, "Panel")










local PANEL = {}

function PANEL:Init()
    self.Player = nil
    
    self.Items = {}
    
    for k, v in pairs( ScoreBoardPlyData ) do

		local panel = nil
		
		if ( v.img ) then
			panel = vgui.Create( "DImage", self )
			panel.Image = v.img
		else
			panel = vgui.Create("Label", self)
		end
		
		panel:SetContentAlignment( v.align )
		panel.FunctionToCall = v.func
		panel:SetMouseInputEnabled( false )
			
		self.Items[ k ] = panel
		
    end
    
    self.Color = 99
    
end

function PANEL:SetPlayer( ply )
    self.Player = ply
end

function PANEL:GetPlayer()
	return self.Player
end

function PANEL:Think()
    
end

function PANEL:Paint()
	derma.SkinHook( "Paint", "ScoreboardListItem", self )
end

function PANEL:OnMousePressed( mc )
    
    GtowerClintClick:ClickOnPlayer( self.Player, mc )

end


function PANEL:PerformLayout()
    if !IsValid( self.Player ) || !self.Player:IsPlayer() then return end
    
    local CurX = 0
    
    for k, v in pairs( self.Items ) do
	
		local off = 3
		if ( Vip ) then off = 7 end
		
		v:SetPos( CurX + off, 0  )
        v:SetSize(  ( ScoreBoardPlyData[k].width / TotalWidthSum ) * self:GetWide() - 6, 23 )
        
		if ( self.Player:IsAdmin() ) then
			v:SetFGColor( self.Player:GetDisplayTextColor() )
			--v:SetFont( "Gtowerbold" )
		end
		
		if ( v.Image ) then
		
			local img = v.Image( self.Player )
			if ( img ) then v:SetImage( img ) end
			v:SetSize( 12, 12 )
			
			v:SetPos( CurX + 4, 6 )
			
		else
		
			v:SetText( v.FunctionToCall( self.Player ) )
			
		end
        
        CurX = CurX + v:GetWide() + 6
    end
end



vgui.Register("ScoreBoardPlayer",PANEL, "Panel")