
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Force = 5000000

function ENT:Initialize()
  self:SetModel(self.Model)
  self:DrawShadow(false)

  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)

  local phys = self:GetPhysicsObject()
  if IsValid(phys) then
    phys:SetMass(2)
    phys:SetDamping( 0, 0 )
    phys:SetBuoyancyRatio(0.5)
    phys:SetMaterial("gmod_ice")
    phys:EnableDrag( false )
    phys:EnableGravity( false )
  end

  self:EmitSound( SOUND_ROCKET )

  timer.Simple(5,function()
    if IsValid(self) then self:DoExplosion() end
  end)

end

function ENT:Think()

  if !self.Velocity then self.Velocity = self:GetVelocity() end

end

function ENT:DoExplosion()
  local vPoint = Vector( self:GetPos() )
  local effectdata = EffectData()
  effectdata:SetOrigin( vPoint )
  util.Effect( "explode", effectdata )

  self:EmitSound( SOUND_EXPLOSION )

  self:Remove()

end

function ENT:HitPlayer( attacker, victim, kart )

  if kart:GetIsInvincible() then
    kart:EmitSound( SOUND_REFLECT, 80 )
    return
  end

  if GAMEMODE:IsBattle() then
    victim:TakeBattleDamage( attacker )
  end

  kart:Spin( attacker )

  net.Start( "HUDMessage" )
    net.WriteString( "YOU HIT "..string.upper( victim:Name() ) )
  net.Send( attacker )

end

function ENT:PhysicsCollide( data, collider )
    local ent = data.HitEntity

      if ent:GetClass() == "worldspawn" && data.OurOldVelocity:Length() < 800 then
        self:DoExplosion()
      elseif ent:GetClass() == "player" then
        local vic = ent
        local att = self:GetOwner()

        if IsValid( att ) && IsValid( vic ) then
          self:HitPlayer( att, vic, vic:GetKart() )
        end

        self:DoExplosion()
      elseif ent:GetClass() == "sk_kart" then
        local vic = ent:GetOwner()
        local att = self:GetOwner()

        if IsValid( att ) && IsValid( vic ) then
          self:HitPlayer( att, vic, vic:GetKart() )
        end

        self:DoExplosion()

      end

end
