AddCSLuaFile()
ENT.Base = "base_entity"
ENT.Type = "point"
ENT.Hole = ENT.Hole || 0;
ENT.par  = ENT.par || 0;
ENT.name = ENT.name || "";
/*---------------------------------------------------------
   Name: Initialize
   Desc: First function called. Use to set up your entity
---------------------------------------------------------*/
function ENT:Initialize()
end

function ENT:KeyValue(key, value)
	if key == "Hole" then
		self.Hole = value
	end
	if key == "hole" then
		self.Hole = value
	end
	if key == "par" then
		self.par = value
	end
	if key == "name" then
		self.name = value
	end
end

function ENT:GetPar()
	return self.par
end

function ENT:GetName()
	return self.name
end

function ENT:GetHole()
	return self.Hole
end