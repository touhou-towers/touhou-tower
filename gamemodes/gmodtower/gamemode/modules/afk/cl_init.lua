
--------------------------------
-- Antiafk
--------------------------------

include("shared.lua")

AntiAFK.EndTime = nil
AntiAFK.StartTime = 0
AntiAFK.TotalTime = 0
AntiAFK.DermaPanel = nil

usermessage.Hook("GTAfk", function( um ) 

	local Id = um:ReadChar()
	
	if Id == 0 then
	
		AntiAFK.EndTime = um:ReadLong()
		AntiAFK.StartTime =  CurTime()
		AntiAFK.TotalTime = AntiAFK.EndTime - AntiAFK.StartTime
		
		AntiAFK:CreateWarning()
		
	elseif Id == 1 then
	
		AntiAFK:RemoveWarning()
	
		AntiAFK.EndTime = nil

	end

end )

local function AfkTimerThink()

	local TimeLeft = AntiAFK.EndTime - CurTime()
	local Sine = math.sin( math.fmod( TimeLeft, 1 ) * math.pi ) * 200
	
	AntiAFK.DermaPanel.WarningLabel:SetColor( Color( 255, 255 - Sine, 255 - Sine, 255 ) )
	
	AntiAFK.DermaPanel.WarningLabel:SetText( T("AfkTimer", math.max( math.Round( TimeLeft ), 0 ) ) )
	AntiAFK.DermaPanel.WarningLabel:SizeToContents()
	AntiAFK.DermaPanel.WarningLabel:Center()
	
end

local function AfkTimerPaint( panel )
	
	local TimeLeft = math.Clamp( (AntiAFK.EndTime - CurTime() ) / AntiAFK.TotalTime , 0, 1 )
	local W, H = panel:GetSize()
	
	local BarWidth = TimeLeft * W
	
	surface.SetDrawColor( 255, 0, 0, 255 )
	
	surface.DrawRect( 0, 0, BarWidth, H )
	
	surface.SetDrawColor( 255, 0, 0, 155 )
	
	surface.DrawRect( BarWidth, 0, W - BarWidth, H )
	
end

function AntiAFK:CreateWarning()
	
	self:RemoveWarning()
	
	self.DermaPanel = vgui.Create("DPanel")
	self.DermaPanel.WarningLabel = Label(T("AfkTimer", 45.0), self.DermaPanel)
	self.DermaPanel.WarningLabel:SetFont( "Gtowerbig" )
	
	self.DermaPanel.Think = AfkTimerThink
	self.DermaPanel.Paint = AfkTimerPaint
	
	AfkTimerThink()
	
	self.DermaPanel:SetAlpha( 200 )
	self.DermaPanel:SetSize( AntiAFK.DermaPanel.WarningLabel:GetWide() * 2.0, AntiAFK.DermaPanel.WarningLabel:GetTall() * 1.5 )
	self.DermaPanel:CenterVertical( 0.75 )
	self.DermaPanel:CenterHorizontal( 0.5 )
	
	AfkTimerThink()
	

end

function AntiAFK:RemoveWarning()
	
	if ValidPanel( AntiAFK.DermaPanel ) then
		AntiAFK.DermaPanel:Remove()
	end	

end