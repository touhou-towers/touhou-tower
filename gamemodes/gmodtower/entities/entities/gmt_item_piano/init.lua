
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()

	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow(true)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
	end

	self.Playing = false
	self.LastSong = 0

	self:Precache()

end

function ENT:Think()

	if !self.Playing then return end

	self:EmitNotes()
	self:NextThink(CurTime() + 2)

end

function ENT:LoadRoom()
	self.RoomId = GtowerRooms.ClosestRoom( self:GetPos() )
end

function ENT:Use(ply)

	if self.Playing then return end
	local Room = GtowerRooms.Get( self.RoomId )
	if !ply:IsPlayer() || (ply != Room.Owner && !ply:IsAdmin()) then return end

	self.Playing = true

	local riff = self:PickRiff()

	self:EmitSoundInLocation(riff, 80)
	timer.Simple(30,function()
		if IsValid(self) then self:EndRiff() end
	end)

end

function ENT:EndRiff()

	if !IsValid( self ) then return end

	self.Playing = false

	if self.GuitarRiff then

		self.GuitarRiff:Stop()
		self.GuitarRiff = nil

	end

end

function ENT:PickRiff()

	local riff = self.Riffs[math.random(#self.Riffs)]
	if self.LastSong == riff then return self:PickRiff() end
	self.LastSong = riff

	return riff

end

function ENT:EmitNotes()

	local edata = EffectData()
	edata:SetOrigin(self:GetPos() + Vector(0, 0, 50) + Vector(math.random(25,-25),math.random(25,-25),0) )
	edata:SetEntity(self)

	util.Effect("musicnotes", edata, true, true)

end

function ENT:OnRemove()

	if !IsValid( self ) then return end

	if self.GuitarRiff then

		self.GuitarRiff:Stop()
		self.GuitarRiff = nil

	end

end
