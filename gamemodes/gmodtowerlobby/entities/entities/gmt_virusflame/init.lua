include('shared.lua')
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

function ENT:Initialize()
	
	self:DrawShadow( false )
	self:SetNotSolid( true )

end

function ENT:Think()

	local owner = self:GetOwner()

	if !IsValid( owner ) then self:Remove() return end
	if !owner:Alive() then return end
	
	if !IsValid( owner.Flame ) || !IsValid( owner.Flame2 ) then
		self:SetupFlame( owner )
	end

end

function ENT:SetupFlame( ply )

	local pos = ply:GetPos( ) + Vector( 0, 0, 50 )

	self:SetPos( pos )

	if !ply.Flame then

		local sprite = ents.Create( "env_sprite" )
		sprite:SetPos( pos )
		sprite:SetKeyValue( "rendercolor", "70 255 70" )
		sprite:SetKeyValue( "renderamt", "150" )
		sprite:SetKeyValue( "rendermode", "5" )
		sprite:SetKeyValue( "renderfx", "0" )
		sprite:SetKeyValue( "model", "sprites/fire1.spr" )
		sprite:SetKeyValue( "glowproxysize", "32" )
		sprite:SetKeyValue( "scale", "0.4" )
		sprite:SetKeyValue( "framerate", "20" )
		sprite:SetKeyValue( "spawnflags", "1" )
		sprite:SetParent( ply )
		sprite:Spawn()

		ply.Flame = sprite
		self:SetNetworkedEntity( "Flame1", ply.Flame )

	end

	if !ply.Flame2 then

		sprite = ents.Create( "env_sprite" )
		sprite:SetPos( pos )
		sprite:SetKeyValue( "rendercolor", "110 255 110" )
		sprite:SetKeyValue( "renderamt", "150" )
		sprite:SetKeyValue( "rendermode", "5" )
		sprite:SetKeyValue( "renderfx", "0" )
		sprite:SetKeyValue( "model", "sprites/fire1.spr" )
		sprite:SetKeyValue( "glowproxysize", "32" )
		sprite:SetKeyValue( "scale", "0.5" )
		sprite:SetKeyValue( "framerate", "14" )
		sprite:SetKeyValue( "spawnflags", "1" )
		sprite:SetParent( ply )
		sprite:Spawn()

		ply.Flame2 = sprite
		self:SetNetworkedEntity( "Flame2", ply.Flame2 )

	end

end

function ENT:OnRemove()

	local owner = self:GetOwner()

	if IsValid( owner ) then
		if IsValid( owner.Flame ) then
			owner.Flame:Remove()
			owner.Flame = nil
		end
		if IsValid( owner.Flame2 ) then
			owner.Flame2:Remove()
			owner.Flame2 = nil
		end
	end

end