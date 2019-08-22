AddCSLuaFile("shared.lua")
ENT.Base 	= "base_anim"

ENT.PrintName 		= "Raveball"
ENT.Author 			= "ogniK, edited by Bumpy"
ENT.Information 	= "Pretty lights :o"

ENT.Spawnable 		= true
ENT.AdminOnly 		= true
ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT
ENT.Editable  		= true

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "Song", { KeyName = "Song", Edit = { type = "String", order = 1 }})
	self:NetworkVar("Int", 0, "FadeDistance", {KeyName = "Fade Distance", Edit = { type = "Float", min = 200, max = 200*5, order = 2}})
end
