
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:InitializeAfter()

	self:SetupChair(
		Vector( 35, -35, -5 ), Angle( 0, 0, 0 ), // chair model
		Vector( -75, 30, 20 ), Angle( 0, -90, 0 ) // actual chair
	)

	local chair = ents.Create("prop_dynamic")
	chair:SetPos(self:GetPos() + Vector( -40, -5, 0 ))
	chair:SetAngles(Angle(0,0,0))
	chair:SetModel(self.ChairModel)
	chair:Spawn()
	chair:SetParent(self)

end

function ENT:SpawnFunction( ply, tr )

    if !tr.Hit then return end

    local SpawnPos = tr.HitPos + tr.HitNormal * 16
    local ent = ents.Create( self.ClassName )
    ent:SetPos( SpawnPos + Vector( 0, 0, 4 ) )
    ent:Spawn()
    ent:Activate()

    return ent

end
