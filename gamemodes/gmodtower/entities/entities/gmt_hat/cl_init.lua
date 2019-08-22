
include('shared.lua')

function ENT:InitOffset()
	self.OffsetTable = GTowerHats.DefaultValue
end

function ENT:PositionItem(ply)
	local eyes = ply:LookupAttachment( GTowerHats.HatAttachment )
	local EyeTbl = ply:GetAttachment( eyes )

	if !EyeTbl then return false end

	local pos, ang = EyeTbl.Pos, EyeTbl.Ang

	local scale = ply:GetModelScale()
	if !string.StartWith(game.GetMap(),"gmt_build") then scale = 1 end
	local Offsets = GTowerHats:GetTranslation( self.HatModel, self.PlyModel )

	ang:RotateAroundAxis(ang:Right(), Offsets[4])
	ang:RotateAroundAxis(ang:Up(), Offsets[5])
	ang:RotateAroundAxis(ang:Right(), Offsets[6])

	local HatOffsets = ang:Up() * Offsets[1] + ang:Forward() * Offsets[2] + ang:Right() * Offsets[3]

	HatOffsets.x = HatOffsets.x * scale
	HatOffsets.y = HatOffsets.y * scale
	HatOffsets.z = HatOffsets.z * scale

	pos = pos + HatOffsets

	return pos, ang
end

function ENT:UpdatedModel(ply)
	local PlyModel = string.lower( ply:GetModel() )
	local HatModel = self:GetModel()

	local PlayerId = GTowerHats:FindPlayerModelByName( PlyModel )
	local HatId = GTowerHats:FindByModel( HatModel ) or ""

	self.PlyModel = PlayerId
	self.HatModel = HatId
	self.OffsetTable = GTowerHats:GetTranslation( self.HatModel, self.PlyModel )

	self:SetModelScale( self.OffsetTable[7] * ply:GetModelScale() )
end



// debug:

concommand.Add("gmt_printhatoffsets", function()

	for _, ent in pairs( ents.FindByClass("gmt_hat") ) do
		local ply = ent:GetOwner()

		if IsValid( ply ) then

			local PlyModel =  string.lower( ply:GetModel() )
			local HatModel = ent:GetModel()
			local PlyModel2 = string.sub( PlyModel, 1, 7 ) .. "player" .. string.sub( PlyModel, 7 )

			local PlayerId = GTowerHats:FindPlayerModelByName( PlyModel )
			local HatId = GTowerHats:FindByModel( HatModel ) or ""

			//self.OffsetTable = table.Copy( GTowerHats:GetTranslation( self.HatModel, self.PlyModel ) )
			local eyes = ply:LookupAttachment( GTowerHats.HatAttachment )
			local EyeTbl = ply:GetAttachment( eyes )
			if !EyeTbl then
				return
			end
			local pos, ang = EyeTbl.Pos, EyeTbl.Ang

			local scale = ply:GetModelScale()
			local Offsets = GTowerHats:GetTranslation( HatId, PlayerId )

			ang:RotateAroundAxis(ang:Right(), Offsets[4])
			ang:RotateAroundAxis(ang:Up(), Offsets[5])
			ang:RotateAroundAxis(ang:Right(), Offsets[6])

			Msg( ply , " (", ply:GetModelScale() ,")\n")
			Msg("\t", PlayerId, " - ", PlyModel, "\n" )
			Msg("\t", HatId, " - ", HatModel, "\n" )
			Msg("\tOffsetTable: ", Offsets[1] ," - ", Offsets[2] ," - ", Offsets[3] ,"\n")

		end

	end

end )
