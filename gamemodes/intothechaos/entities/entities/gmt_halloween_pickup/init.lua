
include( "shared.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

function ENT:Initialize()
    self:SetModel( self.Model )
    self:SetSolid( SOLID_NONE )
    self:DrawShadow( false )
end

function ENT:Think()
    for k,v in pairs( ents.FindInSphere(self:GetPos(),15) ) do
      if IsValid( v ) && v:IsPlayer() then
        if !v.PickupDelay then v.PickupDelay = 0 end
        if CurTime() > v.PickupDelay then
          v.PickupDelay = CurTime() + self.PickupDelay

          v:Msg2( "Ammo and battery replenished. Good luck." )
          v:EmitSound( "HealthKit.Touch", 80, 75 )

          v:SetNWFloat("Battery",1)

          v:SetHealth(100)
          v:SetAmmo(48,"XBowBolt",true)

        end
      end
    end
end
