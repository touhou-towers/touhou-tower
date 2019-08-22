
include('shared.lua');

function ENT:Draw()
	self.Entity:DrawModel();
end

function ENT:DrawTranslucent()
	self:DrawEntityOutline( 0 );
	
	self.Entity:Draw();
end

