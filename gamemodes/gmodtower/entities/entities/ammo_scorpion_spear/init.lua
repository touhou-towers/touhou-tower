
util.AddNetworkString("ResetSpear")
util.AddNetworkString("ResetSpearServer")
util.AddNetworkString("FatalityClient")
util.AddNetworkString("FatalityServer")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
  self:SetModel(self.Model)

  Active = false

	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Lit = 0


  self:EmitSound(self.SoundThrow)

	local phys = self:GetPhysicsObject()

  phys:EnableGravity( false )

  timer.Simple(1,function()
    if !Active then
      net.Start("ResetSpear")
      net.Broadcast()
    end
  end)

end

function ENT:StartTouch( ent )
  if Active then return end

  if ent:GetClass() == "player" then
    Victim = ent
    Active = true

    self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

    self:SetParent(Victim)

    Victim:Freeze(true)

    self:EmitSound(self.SoundHit)
    self.Owner:EmitSound(Sound("gmodtower/lobby/scorpion/getoverhere.wav"), 75)
    --ent:SetEyeAngles(self.Owner:GetShootPos():Angle() )
    --ent:ApplyForceCenter(self.Owner:GetForward() * -800 )
  else
    net.Start("ResetSpear")
    net.Broadcast()
  end
end

function ENT:Think()

  if Active then
    if table.HasValue(ents.FindInSphere( self.Owner:GetPos(), 64 ),Victim) then
      TooFar = false
      Active = false
      net.Start("FatalityClient")
      net.WriteEntity(Victim)
      net.Broadcast()
    else
      TooFar = true
    end
  end

  if Active and TooFar then
    Victim:SetVelocity(self.Owner:GetForward() * -250)
  end
end
