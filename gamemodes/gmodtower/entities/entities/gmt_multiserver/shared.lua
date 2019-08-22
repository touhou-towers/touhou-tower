
ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName		= "Multiserver"
ENT.Author			= "Nican"
ENT.Contact			= ""
ENT.Purpose			= "For GMod Tower"
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true

ENT.Model = "models/props_lab/blastdoor001c.mdl"

//GtowerPrecacheModel( ENT.Model )

hook.Add("LoadAchivements","AchiJeoperty", function () 

end )

ENT.TableHeight = 60
ENT.TableWidth = 60

ENT.NegativeX = -30
ENT.NegativeY = -30

ENT.UpPos = 20.25
ENT.FowrardsPos = 20.0

ENT.StartWaitLenght = 20.0
ENT.TimeToAnswer = 25.0
ENT.ShowAnswerTime = 7.0

function ENT:ReloadOBBBounds()
	local mins = self:OBBMins()
	local maxs = self:OBBMaxs()
	
	self.TableHeight = (maxs.z - mins.z)
	self.TableWidth =  (maxs.y - mins.y)
	
	self.NegativeX = self.TableWidth  / 2
	self.NegativeY = self.TableHeight / 2
	
	self.UpPos = maxs.z / 2  //math.abs( (self:LocalToWorld( maxs ) - CurPos).z  + 0.01 )
	self.FowardsPos = maxs.x

end