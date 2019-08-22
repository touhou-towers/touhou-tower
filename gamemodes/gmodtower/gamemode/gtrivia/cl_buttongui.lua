
local PANEL = {}
local CatXPosition = 0
local MaxCatBack = 0

function PANEL:Init()

	self.Id = 0
	self.Question = ""
	self.Cat = ""
	
	self.TextY = 0
	self.CatX = 300

end

function PANEL:SetId( id )
	
	self.Id = id
	
	self:InvalidateLayout()
end

function PANEL:Paint()
	if self.Hovered then 
		surface.SetDrawColor( 38, 109, 175, 255 )
	else
		surface.SetDrawColor( 65, 148, 207, 255 )
	end
	
	surface.DrawRect( 0,0, self:GetWide(), self:GetTall() )
	
	
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetFont("Default")
	
	surface.SetTextPos( 10,  self.TextY )
	surface.DrawText( self.Id )
	
	surface.SetTextPos( 50,  self.TextY )
	surface.DrawText( self.Question )
	
	surface.SetTextPos( CatXPosition - self.CatX,  self.TextY )
	surface.DrawText( self.Cat )

end

function PANEL:OnMouseReleased()
	GTowerTrivia:AskToEditQuestion( self.Id )
end

function PANEL:PerformLayout()

	local parent = self:GetParent()
	
	self:SetSize( parent:GetWide() - 30, self:GetTall() )
	self:SetPos( 15, self.y )

	local question, cat = GTowerTrivia:GetQuestion( self.Id )
	
	if question == nil then
		self.Question = ""
		self.Cat = ""
	else
		self.Question = question
		self.Cat = cat
	end

	surface.SetFont("Default")
	local w, h = surface.GetTextSize( self.Cat )
	
	if MaxCatBack < w then
		MaxCatBack = w
		CatXPosition = self:GetWide() - w / 2 - 10
	end
	
	self.TextY = self:GetTall() / 2 - h / 2
	self.CatX = w / 2

end

vgui.Register("GTTriviaButton",PANEL, "Panel")