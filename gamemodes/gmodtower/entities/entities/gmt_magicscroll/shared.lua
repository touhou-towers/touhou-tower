
ENT.Type = "anim"

ENT.PrintName = "Magic Scroll"
ENT.Spawnable = true

ENT.SpeedUp = false

ENT.Lines = {
  "You hear a trumpet in the distance...",
  "The paper jumps, like it tries to tell you something..",
  "You're not sure what's happening...",
  "You stare at the paper, as it's jumping...",
  "Trumpet sounds emits from the paper...",
  "You're not quite sure what this paper is for...",
  "You're wondering why the paper jumps...",
  "What could this mean?",
  "You're starting to question why yellow dots appear...",
  "Could this magical scroll mean something?",
  "If only you could open this scroll...",
  "...",
  "You're not sure what you're seeing...",
  "You're wondering why Basical sells this...",
}

function ENT:Use(eOtherEnt)
	if eOtherEnt:IsPlayer() then
    if(self.Wait) then return end
		self.Wait = true
    self:EmitSound(Sound("misc/taps_02.wav"),50,100)
    self:SetNWBool("ShouldSpeedUp",true)
    self:SetNWBool("ShouldSlowDown",false)
    eOtherEnt:SendLua([[Msg2("]]..table.Random(self.Lines)..[[")]])
    timer.Simple(2.5,function() self:SetNWBool("ShouldSpeedUp",false) self:SetNWBool("ShouldSlowDown",true) end)
		timer.Simple(5, function() self.Wait = false
		end)
		self:SetUseType( SIMPLE_USE )
	end
end
