AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)
	self:SetUseType(SIMPLE_USE)
end

function ENT:Use(ply, caller)

	SafeCall( self.GivePresent, self, ply )

end

function ENT:TimedPickup(bool)

	self.Timed = bool

end

function ENT:GivePresent(ply)

	if !IsValid(ply) or !ply:IsPlayer() then return end

	if self.Timed then
		if NextPresent[ply:SteamID()] and NextPresent[ply:SteamID()] > CurTime() then
			ply:Msg2("You have taken a present already. Wait " .. math.ceil(NextPresent[ply:SteamID()] - CurTime()) .. " seconds")
			return
		else
			NextPresent[ply:SteamID()] = CurTime() + 600
		end
	end

  self:EmitSoundInLocation( self.SoundOpen, 80, math.random(80,125) )

	local function giveItem(item)
		local itemID = GTowerItems:Get(item)

		if !GTowerItems:NewItemSlot(ply):Allow(itemID, true) then
			ply:AddMoney(math.random(512, 2048))
			return
		end
		ply:InvGiveItem(item)
		ply:Msg2("You've earned " .. itemID.Name)
	end

	math.randomseed(os.time())

	local rnd = math.Rand(0, 1)

	if rnd <= .001 then
		giveItem(ITEMS.mikucake)
	elseif rnd <= .002 then
		giveItem(ITEMS.piano)
	elseif rnd <= .009 then
		giveItem(ITEMS.autopiano)
	elseif rnd <= .01 then
		giveItem(ITEMS.magicscroll)
	elseif rnd <= .3 then
		giveItem(ITEMS.nesguitar)
	elseif rnd <= .45 then
		giveItem(ITEMS.fwork_multi)
	elseif rnd <= .55 then
		giveItem(ITEMS.lsaber)
	else
		ply:AddMoney(math.random(512, 2048))
	end

	self:Remove()
end
