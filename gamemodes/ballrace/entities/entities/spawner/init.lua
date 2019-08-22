AddCSLuaFile( "cl_init.lua" )

ENT.Type 			= "point"
ENT.Base			= "base_point"

ENT.Delay			= nil
ENT.Class 			= nil

ENT.NextSpawn		= 0
ENT.Enabled			= false


function ENT:Initialize()

	self.Enabled = false
	
end

function ENT:AcceptInput( name, activator, caller, data )

	if name == "Enable" then
		self.Enabled = true
	elseif name == "Disable" then
		self.Enabled = false
	end
	
end

function ENT:KeyValue( key, value )

	if ( key == "delay" ) then
		self.Delay = tonumber( value )
	elseif ( key == "model" ) then
		self.Class = value
	end
	
	if key == "StartDisabled" then
		if value == "1" then
			self.Enabled = false
		else
			self.Enabled = true
		end
	end
	
end

function ENT:OnRemove()

end

function ENT:Dissolve( ent )

	umsg.Start( "Dissolve" )
		umsg.Entity( ent )
	umsg.End()
	
	local eff = EffectData()
	eff:SetEntity( ent )
	
	util.Effect( "disappear", eff )
	
	timer.Simple( 1, ent.Remove, ent )
	
end

function ENT:Think()
	
	if ( !self.Enabled ) then return end
	
	if ( CurTime() < self.NextSpawn ) then return end
	
	self.NextSpawn = CurTime() + self.Delay
	
	local ent = ents.Create( self.Class )
	
	ent:SetPos( self:GetPos() )
	ent:Spawn()
	
	timer.Simple( self.Delay, self.Dissolve, ent )
	
end