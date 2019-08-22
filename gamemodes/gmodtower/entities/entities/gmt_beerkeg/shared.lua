
AddCSLuaFile("shared.lua")

ENT.Base		= "base_anim"
ENT.Type		= "anim"
ENT.PrintName	= "Beer Keg"

ENT.Model		= Model("models/props/de_inferno/wine_barrel.mdl")
ENT.Sound		= Sound("physics/glass/glass_impact_hard3.wav")

function ENT:Initialize()
	if CLIENT then return end

	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	self.Drinks = 36
	self.Color = 255
	self.DrinkIdx = self.Color / self.Drinks
end

function ENT:Use(ply)
	if CLIENT then return end

	self.Drinks = self.Drinks - 1

	ply:Drink()
	self:EmitSound( self.Sound, 100, 150 )
	self:ChangeColor()
	self:CheckDrinks()
end

function ENT:CheckDrinks()
	if self.Drinks <= 0 then
		self:Remove()
	end
end

function ENT:ChangeColor()
	self.Color = self.Color - self.DrinkIdx
	--self:SetColor( self.Color, self.Color, self.Color, 255 )
end
