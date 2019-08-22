
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
  self:SetModel(self.Model)
  self:DrawShadow(false)
  --self:PhysicsInitBox( Vector(-5,-5,-5), Vector(5,5,5) )
  self:PhysicsInitSphere(8)
  self:GetPhysicsObject():SetMass(100)

end

function ENT:PhysicsCollide( colData, collider )
  local ent = colData.HitEntity

  if ( ent:GetClass() == "worldspawn" ) then
    self:OnHitGround()
  end

end

function ENT:OnHitGround()
  local phys = self:GetPhysicsObject()

  if IsValid(phys) then

    phys:EnableMotion(false)
    --self:DropToFloor()

  end

end

function ENT:Think()
    for k,v in pairs( ents.FindInSphere( self:GetPos(), 18 ) ) do
      if v:GetClass() == "sk_kart" && v:GetOwner():Team() == TEAM_PLAYING then

        if v:GetIsInvincible() then
          v:EmitSound( SOUND_REFLECT, 80 )
          return
        end

        if GAMEMODE:IsBattle() && self:GetOwner() != v:GetOwner() then
          v:GetOwner():TakeBattleDamage( self:GetOwner() )
        end

        v:Spin( self:GetOwner(), (self:GetOwner() == v:GetOwner()) )

        self:EmitSound( SOUND_BLOB, 80 )

        net.Start( "HUDMessage" )
			if self:GetOwner() == v:GetOwner() then
				net.WriteString( "YOU HIT YOURSELF!" )
			else
				net.WriteString( "YOU HIT "..string.upper( v:GetOwner():Name() ) )
			end
        net.Send( self:GetOwner() )

        local vPoint = self:GetPos()
        local effectdata = EffectData()
        effectdata:SetOrigin( vPoint )
        util.Effect( "blob_explode", effectdata )

        self:Remove()

      end
    end
end
