
ENT.Type = "anim"
ENT.Category = "GMTower"

ENT.PrintName = "Hula Doll"
ENT.Spawnable = true

function ENT:Dance()

	local seq = self:LookupSequence( "shake" )

	if ( seq == -1 ) then return end

  timer.Create("DanceRepeat",0.3,15,function()
		if !IsValid(self) then return end
	   self:ResetSequence( seq )
  end)

end
