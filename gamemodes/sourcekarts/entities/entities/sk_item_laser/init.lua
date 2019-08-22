
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
  self:SetModel(self.Model)
  self:DrawShadow(false)
end

function ENT:Think()
  self:UpdateEndPos()
    if ( IsValid( self.HitEntity ) && self.HitEntity:GetClass() == "sk_kart" && !self.HitEntity:IsSpinning() ) then

      if self.HitEntity:GetIsInvincible() then
        self.HitEntity:EmitSound( SOUND_REFLECT, 80 )
        return
      end

      if GAMEMODE:IsBattle() then
        self.HitEntity:GetOwner():TakeBattleDamage( self:GetOwner() )
      end

      self.HitEntity:Spin( self:GetOwner() )

      net.Start( "HUDMessage" )
        net.WriteString( "YOU HIT "..string.upper( self.HitEntity:GetOwner():Name() ) )
      net.Send( self:GetOwner() )
	  
	  self:GetOwner():AddAchivement( ACHIVEMENTS.SKLASER, 1 )

      self:GetOwner():GetKart():EmitSound(SOUND_LASERHIT,80)

    end
end
