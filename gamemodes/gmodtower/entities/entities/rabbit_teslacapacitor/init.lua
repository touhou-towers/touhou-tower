
include('shared.lua')
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

function ENT:Initialize()

	self:DrawShadow( false )
	self:SetNotSolid(true)

end

function ENT:SetRabbit( ply )

	self:SetPos( ply:GetPos() + Vector(0,0,64) )
	self:SetOwner( ply )
	self:SetParent( ply )

end

function ENT:Probability()

	local Owner = self:GetOwner()

	if !IsValid( Owner ) then
		return
	end

	local Wep = Owner:GetActiveWeapon()

	if Wep.TeslaProbalitiy then
		return Wep:TeslaProbalitiy( self )
	end

	//Hehe, let's have some random fun
	local Time = CurTime()
	local ModValue = math.min( math.fmod( Time, 41 ), math.fmod( Time, 59 ) )

	if ModValue < math.pi * 3 then
		return math.sin( math.pi / 3 ) * 2.15 //Start from 0, goes up to 1, and goes back to 0!
	end

	return math.Rand( 0, 1.2 )

end

function ENT:GetAllCoils()
	return ents.FindByClass("rabbit_tesl*")
end

function ENT:FindCoils()

	local Pos = self:GetPos()
	local Coils = self:GetAllCoils()

	local Probability = self:Probability()
	local Attempts = math.Round( Probability * #Coils )

	if Attempts < 0 then
		return
	end

	for i=1, Attempts do

		local coil = table.Random( Coils )

		if coil != self then

			local Owner = coil:GetOwner()

			if IsValid( Owner ) && Owner:Alive() && Owner:IsRabbit() then

				local CoilPos = coil:GetPos()
				local Tesla = tesla.New()

				Tesla:SetFilter( { self:GetOwner(), Owner, self, coil } )

				if Tesla:AttemptFindList( Pos, CoilPos ) then
					Tesla:BreakUpTrace( 4 )

					return Tesla:Get()
				end

			end

		end

	end

end

function ENT:SendToClients()

	/*local List = self:FindCoils()

	umsg.Start("rabbit_tesla", nil )
		umsg.Entity( self )

		if !List || #List <= 2 then
			umsg.Char( 0 )
		else
			umsg.Char( #List )

			for _, v in pairs( List ) do
				umsg.Vector( v )
			end

		end

	umsg.End()*/

end

function ENT:Think()

	self:SendToClients()
	self:NextThink( CurTime() + 0.1 )


end
