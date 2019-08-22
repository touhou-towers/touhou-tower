
-----------------------------------------------------
ENT.Base		= "base_anim"
ENT.Type		= "anim"
ENT.PrintName	= "Start Line"

ENT.Model		= Model( "models/gmod_tower/sourcekarts/startline.mdl" )
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.AttNames = {
	Lights = {
		"light1", "light2", "light3"
	},
	Balloons = {
		"balloon1", "balloon2",
	},
	Screens = {
		"screen",
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