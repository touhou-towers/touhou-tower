AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

util.AddNetworkString("UpdateAuctionTable")
util.AddNetworkString("OpenBidWindow")
util.AddNetworkString("ReceiveBid")
util.AddNetworkString("ReceiveItem")

util.AddNetworkString("SetClItem")

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetUseType( SIMPLE_USE )
end

function ENT:Think()

	if !IsValid(self) then return end

	if !self.SendDelay || self.SendDelay < CurTime() then
		self:SendUpdate()
		self.SendDelay = CurTime() + 5
	end

end

function ENT:Use(ply)

	if !self.HasItem and ply:IsAdmin() then
		net.Start("OpenBidWindow")
		net.WriteBool(true)
		net.WriteEntity(self)
		net.Send(ply)
	end

	if !self.HasItem then return end

	if ply:IsPlayer() then
		net.Start("OpenBidWindow")
		net.WriteBool(false)
		net.Send(ply)
	end
end

function ENT:SendUpdate()
	net.Start("UpdateAuctionTable")
	net.WriteEntity(self)
	net.WriteInt(self:GetNWInt("bid"),32)
	net.WriteString(self:GetNWString("plyname"))

	if self.NetworkItemId then
		net.WriteInt(self.NetworkItemId,32)
	end

	net.Broadcast()
end

function ENT:SetItem(id)

	self.HasItem = true

	net.Start("SetClItem")
	net.WriteEntity( self )
	net.WriteInt( id, 32 )
	net.Broadcast()

	self.NetworkItemId = id

end

net.Receive("ReceiveItem",function()
	local ent = net.ReadEntity()
	local ID = net.ReadInt(32)

	if (IsValid(ent) and ID != nil) then
		ent:SetItem( ID )
	end

end)

net.Receive("ReceiveBid",function()
	local Table = net.ReadEntity()
	local ply = net.ReadEntity()
	local bid = net.ReadInt(32)

	if IsValid(Table) and IsValid(ply) and (Table:GetClass() == "gmt_auctiontable") then

		if bid > Table:GetNWInt("bid") then
			ply:Msg2("[AUCTION] You bet " .. bid .. " GMC.")
			ply:AddMoney(-bid,true)
			local BetTotal = ply:GetNWInt("BetTotal",0)
			ply:SetNWInt( "BetTotal", bid + BetTotal )
		else
			ply:Msg2("[AUCTION] Please bet more than the current bid. (" .. Table:GetNWInt("bid") .. " GMC)")
			return
		end

		Table:SetNWEntity("ply",ply)
		Table:SetNWString("plyname",ply:Name())
		Table:SetNWInt("bid",bid)

		local bzr = ents.Create("gmt_money_bezier")

		if IsValid( bzr ) then
			bzr:SetPos( Table:GetPos() + Vector(0,0,50) )
			bzr.GoalEntity = Table
			bzr.GMC = bid
			bzr.RandPosAmount = 25
			bzr:Spawn()
			bzr:Activate()
			bzr:Begin()
		end

	end
end)
