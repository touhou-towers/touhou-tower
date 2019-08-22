
--[[
	GMod Tower

	func_suitepanel
	Suite Management Touchpanel

	Written by PackRat ( packrat (at) plebsquad (dot) com )
]]--

ENT.PrintName		= "The LADY!"
ENT.Type 				= "ai"
ENT.Base 				= "base_anim"
ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.Model				= "models/Humans/Group01/Female_01.mdl"

GtowerPrecacheModel( ENT.Model )

function GTowerNPCSharedInit(ent)
	RegisterNWTable(ent, {
		{"Sale", false, NWTYPE_BOOL, REPL_EVERYONE, CreateSaleSign},
	})
end

function CreateSaleSign(npc, name, old, new)
	if new && !old then
		local edata = EffectData()
		edata:SetOrigin(npc:EyePos() + Vector(0,0,24))
		edata:SetEntity(npc)

		util.Effect("saleeffect", edata)

		return
	end

end
