include('shared.lua')
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Draw()
end

function ENT:Think()

	local owner = self:GetOwner()
	if !IsValid( owner ) then return end

	local Flame = self:GetNetworkedEntity("Flame1")
	local Flame2 = self:GetNetworkedEntity("Flame2")

	if IsValid( Flame ) && IsValid( Flame2 ) then

		local Torso = owner:LookupBone( "ValveBiped.Bip01_Spine2" )
		local pos, ang
		if !Torso then
			pos, ang = owner:GetPos(), owner:GetAngles()
		else
			pos, ang = owner:GetBonePosition( Torso )
		end

		if IsValid( owner.BallRaceBall ) then
			pos = owner.BallRaceBall:GetPos()
		end

		Flame:SetPos( pos )
		Flame2:SetPos( pos )

	end

end
