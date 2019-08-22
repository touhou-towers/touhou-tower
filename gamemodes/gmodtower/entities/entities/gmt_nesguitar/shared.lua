
ENT.Base		= "base_anim"
ENT.Type		= "anim"
ENT.PrintName	= "NES Guitar"

ENT.Model		= Model("models/gmod_tower/nesguitar.mdl")

ENT.Riffs = {"GModTower/lobby/nesguitar/nesguitar_riff|.mp3", 16} --Second value is the amount of songs, starting from 01.

function ENT:Precache()
	local tbl, str, strRiff = {}, string.Explode("|", self.Riffs[1])
	
	local function convertNum(num)
		if num >= 0 and num <= 9 then return tostring(0 .. num) end
		return num
	end
	
	for i = 1, self.Riffs[2] do
		strRiff = str[1] .. convertNum(i) .. str[2]
		table.insert(tbl, strRiff)
		GtowerPrecacheSound(strRiff)
	end
	
	self.Riffs = tbl
end