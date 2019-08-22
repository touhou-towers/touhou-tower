
ENT.Type 			= "anim"
ENT.PrintName 		= "Trampoline"
ENT.Author 			= "GMod Tower Team"
ENT.Contact 		= "http://www.gmodtower.org"
ENT.Purpose 		= "Jump around all crazy like!"
ENT.Instructions 	= "Jump on me."


function ENT:Boing()

	local seq = self:LookupSequence( "bounce" )
	
	if ( seq == -1 ) then return end
	
	self:ResetSequence( seq )
	
end