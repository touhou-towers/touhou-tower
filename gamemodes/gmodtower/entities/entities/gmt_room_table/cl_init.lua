
include('shared.lua')


function ENT:Initialize()
	
	self.BaseClass.Initialize( self )
	
	self.Draw = self.NoDraw
end

function ENT:LevelChaned( var, old, new )
	if new == 2 then
		self.Draw = self.BaseClass.Draw
	else
		self.Draw = self.NoDraw
	end
end


function ENT:NoDraw()
	self:DrawModel()
end


function ENT:DrawRotatingBoard()
end



function ENT:DrawTranslucent()
end