
include('shared.lua')
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

local Player = FindMetaTable("Player")

function Player:ReplaceHat(model, index)
	if IsValid(self.Hat) then
		self.OldHat = self.Hat:GetModel()
	else
		self.Hat = ents.Create("gmt_hat")

		self.Hat:SetOwner(self)
		self.Hat:Spawn()
	end
	
	local id = index
	
	if ( id == 14 || id == 21 || id == 22 || id == 23 || id == 24 ) then
		self:SetBodygroup( 0, 0 ) // show hat when we use glasses
	else
		self:SetBodygroup( 0, 1 ) // hide model hat, if it exists
	end

	self.Hat:SetModel(model)
end

function Player:ReturnHat()
	if !IsValid(self.Hat) then return end

	if !self.OldHat then
		self.Hat:Remove()
		return
	end

	self.Hat:SetModel(self.OldHat)

	self.OldHat = nil
end

function Player:RemoveHat()
	if !IsValid(self.Hat) then return end

	self.Hat:Remove()
	
	// show model hat, if it exists
	self:SetBodygroup( 0, 0 )

	self.Hat, self.OldHat = nil, nil
end