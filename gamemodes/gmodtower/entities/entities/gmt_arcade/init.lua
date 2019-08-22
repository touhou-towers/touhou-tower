
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:KeyValue(key, value)
	if key == "skin" then
		self.Skin = tonumber(value)
	end
end

function ENT:Initialize()

	self.Entity:SetModel( self.Model )

	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_NONE )
	
	local phys = self:GetPhysicsObject()
	
	if IsValid( phys ) then
		phys:EnableMotion( false )
	end
	
	self.NextUse = 0
	self.NextAchiThink = 0
	self:SetSkin( self.Skin )
end


function ENT:Think()

	if self.NextAchiThink > CurTime() then
		return
	end
	
	self.NextAchiThink = CurTime() + 10.0

	local Skin = self:GetSkin()

	if Skin <= 1 then return end
	
	local EntPos = self:GetPos()
	
	for _, ply in pairs( player.GetAll() ) do
		if ply:GetPos():Distance( EntPos ) < 512 then
			
			local EyeTrace = ply:GetEyeTrace()
			
			if EyeTrace.Entity == self then
				
				if !ply._ArcadeTimers then
					ply._ArcadeTimers = {}
				end
				
				if !ply._ArcadeTimers[ Skin ] then
					ply._ArcadeTimers[ Skin ] = 0
				else
					ply._ArcadeTimers[ Skin ] = ply._ArcadeTimers[ Skin ] + 10
					
					if ply._ArcadeTimers[ Skin ] >= 300 then
						ply:SetAchivement( ACHIVEMENTS.ArcadeJunkie, nil, Skin - 2 )
					end					
				end
				
			end		
		end		
	end

end

function ENT:Use( ply )
	if CurTime() < self.NextUse then return end
	self.NextUse = CurTime() + 0.2

	umsg.Start("StartGame", ply)
		umsg.Char(self:GetSkin())
	umsg.End()
	
	local PlyHat = GTowerHats:GetHat( ply )
	
	if PlyHat != nil then
	
		if self.GameIDs[ self:GetSkin() ] == "Fancy Pants" && GTowerHats.Hats[ PlyHat ] && GTowerHats.Hats[ PlyHat ].Name == "Top Hat"  then
			ply:SetAchivement( ACHIVEMENTS.FANCYPANTS, 1 )
		end
		
	end
end


//local GameIDS = ENT.GameIDs
local StartId = ENT.StartId

concommand.Add("gmt_arcadejunkie", function( ply, cmd, args )
	
	if (ply._LastCheckGameTime or 0) > CurTime() then
		return
	end
	ply._LastCheckGameTime = CurTime() + 0.4
	
	local Achivements = bit.tobits( ply:GetAchivement( ACHIVEMENTS.ArcadeJunkie, true ) )
	local NotFound = {}
	
	for i=2, 22 do
		
		if Achivements[ i - 1 ] == 0 then
			Msg("Not found: " .. i .."\n")
			table.insert( NotFound, i )
		end
		
	end
	
	if !ply._ArcadeTimers then
		ply._ArcadeTimers = {}
	end
	
	umsg.Start("ArcJunkie", ply )
		umsg.Char( #NotFound )
		for _, v in pairs( NotFound ) do
			umsg.Char( v )
		end	
	umsg.End()

end )
