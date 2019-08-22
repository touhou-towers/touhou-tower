
ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName		= "Jeopardy Main"
ENT.Author			= "Nican"
ENT.Contact			= ""
ENT.Purpose			= "For GMod Tower"
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true

ENT.Model = "models/props_lab/blastdoor001c.mdl"

GtowerPrecacheModel( ENT.Model )

hook.Add("LoadAchivements","AchiJeoperty", function () 

end )

function ENT:SharedInit()
	RegisterNWTable(self, { 
		{"State", 0, NWTYPE_CHAR, REPL_EVERYONE, self.StateChanged }, 
	})
end

ENT.TableHeight = 60
ENT.TableWidth = 60

ENT.NegativeX = -30
ENT.NegativeY = -30

ENT.UpPos = 20.25
ENT.FowrardsPos = 20.0

ENT.StartWaitLenght = 30.0
ENT.TimeToAnswer = 25.0
ENT.ShowAnswerTime = 7.0

if false then //DEBUG PURPUSES
	ENT.StartWaitLenght = 3.0
	ENT.TimeToAnswer = 3.0
	ENT.ShowAnswerTime = 3.0
end

function ENT:ReloadOBBBounds()
	local mins = self:OBBMins()
	local maxs = self:OBBMaxs()
	
	self.TableHeight = (maxs.z - mins.z) * 1.75
	self.TableWidth =  (maxs.y - mins.y) * 1.5
	
	self.NegativeX = self.TableWidth  / 2
	self.NegativeY = self.TableHeight / 2
	
	self.UpPos = maxs.z / 2
	self.FowardsPos = maxs.x
end


hook.Add("LoadAchivements","AchiTriviaMaster", function () 

	GtowerAchivements:Add( ACHIVEMENTS.TRIVIAMASTER, {
		Name = "Trivia Master", 
		Description = "Win a round of GMT Trivia.", 
		Value = 1,
		Group = 4
	})

	GtowerAchivements:Add( ACHIVEMENTS.MILLIONAIRE, {
		Name = "Trivia Millionaire", 
		Description = "Win 100 GMT Trivia games.", 
		Value = 100,
		Group = 4
	})
	
end )