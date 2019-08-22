
include( "shared.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

local ImpactSounds = {

{
	"player/footsteps/grass1.wav",
	"player/footsteps/grass2.wav",
	"player/footsteps/grass3.wav",
	"player/footsteps/grass4.wav",
},

{
	"player/footsteps/mud1.wav",
	"player/footsteps/mud2.wav",
	"player/footsteps/mud4.wav",
},

}

game.AddDecal("1splash1","decals/blackpaint01")
game.AddDecal("1splash2","decals/blackpaint02")
game.AddDecal("1splash3","decals/blackpaint03")
game.AddDecal("1splash4","decals/blackpaint04")

game.AddDecal("2splash1","decals/whitepaint01")
game.AddDecal("2splash2","decals/whitepaint02")
game.AddDecal("2splash3","decals/whitepaint03")
game.AddDecal("2splash4","decals/whitepaint04")

function ENT:Initialize()
	self:SetModel( "models/dav0r/hoverball.mdl" )

	self:PhysicsInit( SOLID_VPHYSICS )
  self:SetMoveType( MOVETYPE_VPHYSICS )
  self:SetSolid( SOLID_VPHYSICS )
	self:SetColor(Color(0,0,0,0))
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

	local phys = self:GetPhysicsObject()

	if phys:IsValid() then
		phys:Wake()
	end

	self:SetNWInt("color", 0)
end

function ENT:SetPaintColor(col)
	self:SetNWInt("color", col)
end

function ENT:PhysicsCollide(data, physobj)
	if self.Hit or data.HitEntity:IsPlayer() then
		return
	end

	local decal = (self:GetNWInt("color") + 1).."splash"..math.random(1,4)
	local impact = table.Random(ImpactSounds[self:GetNWInt("color")+1])

	util.Decal(decal, data.HitPos + data.HitNormal, data.HitPos - data.HitNormal)

	if string.StartWith( data.HitEntity:GetClass(), "prop_" ) then
		// Add additional decals so models get paint on em aswell.
		util.Decal(decal, data.HitPos, data.HitPos + Vector(0,0,50))
		util.Decal(decal, data.HitPos, data.HitPos + Vector(0,0,-50))
		util.Decal(decal, data.HitPos, data.HitPos + Vector(0,50,0))
		util.Decal(decal, data.HitPos, data.HitPos + Vector(0,-50,0))
		util.Decal(decal, data.HitPos, data.HitPos + Vector(50,0,0))
		util.Decal(decal, data.HitPos, data.HitPos + Vector(-50,0,0))
	end

	if data.HitEntity:GetClass() == "prop_door_rotating" then
		data.HitEntity:Fire("Open","",0)
	end

	self.Hit = true
	self:EmitSound(impact, 100, math.random(100,110))
	self:Fire("kill", "", 0.01)

	if data.HitObject and data.HitObject:IsValid() then
		data.HitObject:ApplyForceOffset(physobj:GetVelocity(),data.HitPos)
	end
end
