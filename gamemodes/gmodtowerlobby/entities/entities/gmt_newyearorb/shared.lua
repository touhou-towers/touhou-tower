-----------------------------------------------------
ENT.Type 	= "anim"
ENT.Base 	= "base_anim"

ENT.PrintName		= "New Year Orb"
ENT.Author		= ""
ENT.Contact		= ""
ENT.Purpose		= ""
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true

ENT.Model = Model( "models/gmod_tower/discoball.mdl" )

local center = Vector( 2607, 0, -927 )
ENT.FinishPos = center
ENT.StartPos = center + Vector( 0, 0, 1000 )

function ENT:SetupDataTables()

	self:NetworkVar( "Float", 0, "TimeLeft" )

end
function ENT:SharedInit()

	local currentYear = os.date( "*t" ).year
	local nextYear = {
		day = 1, month = 1, year = currentYear + 1,
		hour = 0, sec = 0, min = 0
	}

	/*
	RegisterNWTable( self, {
		{ "TimeLeft", 0, NWTYPE_NUMBER, REPL_EVERYONE },
	} )
	*/

	self.NewYearsTime = os.time( nextYear )

end

function ENT:TimeToNewYear()

	if SERVER then
		return self.NewYearsTime - os.time()
	else
		return self.NewYearsTime - os.time()
	end

end
