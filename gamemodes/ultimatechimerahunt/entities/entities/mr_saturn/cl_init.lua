include( "shared.lua" )
include( "SCHED.lua" )

function ENT:Initialize()

	self.Hat = self.Hat or nil
	self:SetupSchedules()

end

function ENT:Draw() self:DrawModel() end

function ENT:OnRemove()

	if IsValid( self.Hat ) then
		self.Hat:Remove()
	end

end

function ENT:Think()
	
	if IsValid( self.Hat ) then
	
		local hat = self.Hat
		
		local atch = self:LookupAttachment( "hat" )
		atch = self:GetAttachment( atch )
		local pos, ang = atch.Pos, atch.Ang
		pos = pos + ( self:GetRight() * hat.pos.x )
		pos = pos + ( self:GetForward() * hat.pos.y )
		pos = pos + ( self:GetUp() * hat.pos.z )
		ang = ang + hat.ang
		
		hat:SetPos(pos)
		hat:SetAngles(ang)
	
	end
	
	self:NextThink( CurTime() )
	return true
	
end

function ENT:SetCLHat( num, skin )
	
	local snum = math.random( 0, 1 )
	if skin then snum = skin end

	local rndhat = MrSaturnHatTable[num]
	local hat = ClientsideModel( rndhat.mdl, RENDERGROUP_OPAQUE )
	hat.pos = rndhat.pos
	hat.ang = rndhat.ang
	hat:PhysicsInit( SOLID_NONE )
	hat:SetMoveType( MOVETYPE_NONE )
	hat:SetSolid( SOLID_NONE )
	hat:SetCollisionGroup( COLLISION_GROUP_NONE )
	hat.IsSaturnHat = true
	hat:Spawn()
	hat:SetSkin(snum)
	
	self.Hat = hat

end

local function GetHat(um)

	local ent = um:ReadEntity()
	local num, skin = um:ReadLong(), um:ReadLong()

	timer.Simple( .1, function()
		if IsValid( ent ) then ent:SetCLHat(num, skin) end
	end )
	
end
usermessage.Hook("SaturnHat", GetHat)