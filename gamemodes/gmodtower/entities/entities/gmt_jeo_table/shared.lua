
ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName		= "Jeopardy table"
ENT.Author			= "Nican"
ENT.Contact			= ""
ENT.Purpose			= "For GMod Tower"
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true

ENT.TableHeight = 60
ENT.TableWidth = 60

ENT.NegativeX = -30
ENT.NegativeY = -30

ENT.UpPos = 20.25

ENT.Model = "models/gmod_tower/answerboard.mdl"

GtowerPrecacheModel( ENT.Model )

function ENT:ReloadOBBBounds()
	local mins = self:OBBMins()
	local maxs = self:OBBMaxs()
	
	self.TableHeight = maxs.x - mins.x - 9
	self.TableWidth =  maxs.y - mins.y - 14
	
	self.NegativeX = self.TableWidth  / 2
	self.NegativeY = self.TableHeight / 2
	
	self.TableHeight = self.TableHeight - 10

	self.UpPos = maxs.z - 0.5 //math.abs( (self:LocalToWorld( maxs ) - CurPos).z  + 0.01 )

end

function ENT:SharedInit()
	RegisterNWTable(self, { 
		{"Ply", Entity(0), NWTYPE_ENTITY, REPL_EVERYONE, self.UpdateUser }, 
		{"ChosenAnswer", 0, NWTYPE_CHAR, REPL_EVERYONE, self.AnswerChosen }, 
		{"Points", 0, NWTYPE_SHORT, REPL_EVERYONE}, 
		{"AnswerTime", 0.0, NWTYPE_FLOAT, REPL_EVERYONE},
		{"BoardOwner", Entity(0), NWTYPE_ENTITY, REPL_EVERYONE, self.UpdateOwner }
	})
end


function ENT:Get2DPos( ply )
	if !IsValid(ply) then return end

	local tr = ply:GetEyeTrace()
	
	if tr.HitPos:Distance( ply:GetPos() ) > 256 then
		return
	end
	
	local LocalPos = self:WorldToLocal( tr.HitPos )
	
	return (LocalPos.x + self.NegativeY) / self.TableHeight, (LocalPos.y + self.NegativeX) / self.TableWidth
end


function ENT:GetAimButton( ply )
	
	local x,y = self:Get2DPos( ply )
	
	if !x || x < 0.44 || x > 1 || y < 0 || y > 1 then
		return 0
	end
	
	if y > 0.5 then
		if x > 0.45 && x < 0.72 then	
			return 2
		elseif x >= 0.73 && x < 0.97 then
			return 4
		end
	else
		if x > 0.45 && x < 0.72 then	
			return 1
		elseif x >= 0.73 && x < 0.97 then
			return 3
		end
	end
	
	return 0
end

function ENT:GetBoard()
	//return self:GetNWEntity("own")
	//return self:GetOwner()
	return self.BoardOwner
end

function ENT:ValidPlayer()
	return IsValid( self:GetPlayer() ) && self:GetPlayer():IsPlayer()
end
