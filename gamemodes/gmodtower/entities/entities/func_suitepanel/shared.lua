
--[[
	GMod Tower
	
	func_suitepanel
	Suite Management Touchpanel
	
	Written by PackRat ( packrat (at) plebsquad (dot) com )
]]--

ENT.Type 				= "anim"
ENT.Base 				= "base_anim"

ENT.Model			= "models/func_touchpanel/terminal04.mdl"

-- Sounds
ENT.soundGranted 		= Sound( "buttons/button17.wav" )
ENT.soundDenied 		= Sound( "buttons/button18.wav" )
ENT.soundLock 			= Sound( "buttons/button16.wav" )
ENT.soundUnlock 		= Sound( "buttons/button14.wav" )

-- Dimensions
ENT.scr_x				= -260
ENT.scr_y				= -180
ENT.scr_x2				= 260
ENT.scr_y2				= 180
ENT.scr_width			= 520
ENT.scr_height			= 360
ENT.limit_x 			= 6.4
ENT.limit_y 			= 4.4


GtowerPrecacheModel(ENT.Model)
GtowerPrecacheSound(ENT.soundGranted)
GtowerPrecacheSound(ENT.soundDenied)
GtowerPrecacheSound(ENT.soundLock)
GtowerPrecacheSound(ENT.soundUnlock)

function ENT:PhysicsUpdate()
end

function ENT:PhysicsCollide(data,phys)
end


function ENT:MakeEyeTrace(ply)
    
    local trace = {}
        trace.start = ply:GetShootPos()
        trace.endpos = ply:GetAimVector() * 64 + trace.start
        trace.filter = ply
	local trace = util.TraceLine(trace)
		
	-- Get cursor position
	local pos = self.Entity:WorldToLocal( trace.HitPos )	
	local cur_x = ( pos.x / self.limit_x ) * self.scr_x
	local cur_y = ( pos.z / self.limit_y ) * self.scr_y

    return cur_x, cur_y, ( trace.Entity == self.Entity && math.abs( cur_x ) <= self.scr_x2 && math.abs( cur_y ) <= self.scr_y2 ) 

end
