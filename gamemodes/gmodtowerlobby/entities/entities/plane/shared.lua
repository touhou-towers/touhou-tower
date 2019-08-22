ENT.Type = "anim"


function ENT:Initialize()

	if SERVER then
		self:DrawShadow( false )
		return
	end

	self.Parts = {}
	self.NextSound = 0

	self:AddPlanePart( Vector( 0, 0, -7 ), Angle( 0, 92, 0 ), "models/props_junk/plasticcrate01a.mdl" )
	self:AddPlanePart( Vector( 0, 19, -9 ), Angle( -1.682, 120.148, 10.0717 ), "models/props_c17/playground_swingset_seat01a.mdl" )
	self:AddPlanePart( Vector( 0, -19, -9 ), Angle( -1.682, 70.648, 10.0717 ), "models/props_c17/playground_swingset_seat01a.mdl" )
	self:AddPlanePart( Vector( 21, 0, -9 ), Angle( -90, 270 + 180, -90 ), "models/props_junk/trafficcone001a.mdl" )
	self:AddPlanePart( Vector( -18, -1, -7 ), Angle( -90, 90 + 180, -90 ), "models/props_lab/powerbox02d.mdl" )

end

if CLIENT then
function ENT:AddPlanePart( pos, ang, mdl )

	pos = pos + Vector( 0, 0, -3 )

	local ent = ClientsideModel( mdl )//ents.Create( "prop_dynamic" )

		//ent:SetModel( mdl )

		ent:Spawn()

		ent:SetParent( self:GetOwner() )
		ent:SetPos( pos )
		ent:SetAngles( ang )

		ent.RelativePos = pos
		ent.RelativeAngles = ang

	table.insert( self.Parts, ent )

end

function ENT:Think()
	local Owner = self:GetOwner()

	for _, v in pairs( self.Parts ) do
		v:SetPos( Owner:LocalToWorld( v.RelativePos ) )
		v:SetAngles( Owner:LocalToWorldAngles( v.RelativeAngles ) )
	end

	if self.Shooting && Owner != LocalPlayer() && CurTime() > self.NextSound then
		Owner:EmitSound("Weapon_AR2.Single")
		self.NextSound = CurTime() + 0.1
	end

end

function ENT:Draw()
end

function ENT:OnRemove()

	for _, ent in pairs( self.Parts ) do
		ent:Remove()
	end

end
end
