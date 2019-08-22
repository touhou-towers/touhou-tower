
ENT.Type 				= "anim"
ENT.Base 				= "base_anim"

ENT.Model			= ""

function ENT:Initialize()
	
	self:SetModel( self.Model )
	
	if SERVER then
		self:DrawShadow( false )
	end
	
	RegisterNWTable( self, {
		{ "Title", "", NWTYPE_STRING, REPL_EVERYONE },
		{ "Sale", false, NWTYPE_BOOL, REPL_EVERYONE },
	} )
	
end

function ENT:SetTitle( title )
	self.Title = title
end

function ENT:PhysicsUpdate()
end

function ENT:PhysicsCollide(data,phys)
end