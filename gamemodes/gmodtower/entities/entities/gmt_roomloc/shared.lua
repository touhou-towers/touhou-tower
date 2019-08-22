
ENT.Base = "base_entity"
ENT.Type = "anim"

function ENT:Initialize()
	if CLIENT then
		timer.Simple( 0.1, function()
			GtowerRooms.FindRefEnts( GtowerRooms ) 
		end)
	end
	
	self:DrawShadow( false )
	self:SetNotSolid(true)
end