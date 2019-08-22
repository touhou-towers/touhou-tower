

-----------------------------------------------------
ENT.Base		= "base_anim"
ENT.Type		= "anim"
ENT.PrintName	= "Stage"

ENT.Model		= Model( "models/gmod_tower/stage.mdl" )
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.AttNames = {
	Lights = {
		"light1", "light2", "light3", "light4",
		"light5", "light6", "light7", "light8",
		"light9", "light10", "light11",
	},
	Lasers = {
		"laser1", "laser2", "laser3", "laser4",
	},
	Emitters = {
		"emit1", "emit2", "emit3", "emit4",
		"emit5", "emit6", "emit7", "emit8",
		"emit9",
	},
	Screens = {
		"screen1", "screenside1", "screenside2",
	}	
}
ENT.Att = {}

function ENT:GatherAttachmentPos( tbl, name )

	for id, att in pairs( tbl ) do

		if type( att ) != "string" then continue end

		local attach = self:LookupAttachment( att )
		if attach < 0 then continue end

		attach = self:GetAttachment( attach )
		if !self.Att[name] then self.Att[name] = {} end

		self.Att[name][id] = { pos = attach.Pos + ( attach.Ang:Forward() * 12.5 ), ang = attach.Ang }

	end

	//PrintTable( self.Att )

end

function ENT:UpdateAttachments()

	for name, tbl in pairs( self.AttNames ) do
		self:GatherAttachmentPos( tbl, name )
	end

end
