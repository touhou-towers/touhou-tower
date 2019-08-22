
-----------------------------------------------------
AddCSLuaFile("shared.lua")

ENT.Base		= "base_anim"
ENT.Type		= "anim"
ENT.PrintName	= "Christmas Tree"

ENT.Model		= Model( "models/wilderness/hanukkahtree.mdl" )

if SERVER then
	function ENT:Initialize()

		self:SetModel( self.Model )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		local phys = self:GetPhysicsObject()
		if IsValid( phys ) then
			phys:EnableMotion(false)
		end

		-- Rotate the train about the tree's center so it spawns correctly
		local trainOffset = Vector( 0, 0, .5 );
		trainOffset:Rotate( self:GetAngles())

		self.Train = ents.Create( "gmt_train" )
		self.Train:SetAngles(self:GetAngles())
		self.Train:SetPos( self:GetPos() + trainOffset )
		self.Train:Spawn()
		self.Train:Activate()
		self.Train:SetRadius( 50 )
		self.Train:SetTrainVelocity( 25 )
		self.Train:SetTrainCount( 5 )
		self.Train:SetParent( self )

	end

	function ENT:OnRemove()

		if IsValid( self.Train ) then
			self.Train:Remove()
		end

	end

else -- CLIENT

	function ENT:Initialize()

		self.Ornaments = {}

		for i=1, 40 do
			z = math.random( 15, 100 )
			mul = math.Fit( z, 15, 100, 22, 5 )
			y = math.sin( math.random( 0, 360 ) ) * mul
			x = math.cos( math.random( 0, 360 ) ) * mul

			local pos = Vector( x, y, z )
			pos:Rotate( self:GetAngles() )

			self:CreateOrnament( pos )
		end

		self.Star = ClientsideModel( "models/wilderness/treestar.mdl" )
		local pos = Vector( -2, -2, 120 )
		pos:Rotate( self:GetAngles() )

		self.Star:SetPos( self:GetPos() + pos )
		self.Star:SetModelScale( .25, 0 )
		self.Star:SetParent( self )
		self.Star:SetAngles( self:GetAngles() )

	end

	function ENT:RegenLights()

		self.Lights = {}

		-- Store the seed so when we regen the lights, it'll be the same position
		self.Seed = self.Seed or RealTime()

		-- Set the seed to make it do the thing again
		math.randomseed(self.Seed)

		for i=1, 40 do
			z = math.random( 15, 100 )
			mul = math.Fit( z, 15, 100, 22, 5 )
			y = math.sin( math.random( 0, 360 ) ) * mul
			x = math.cos( math.random( 0, 360 ) ) * mul

			local pos = Vector( x, y, z )
			pos:Rotate( self:GetAngles() )

			table.insert( self.Lights, pos )
		end

	end

	function ENT:CreateOrnament( pos )

		ornament = ClientsideModel( "models/wilderness/ornament1.mdl" )
		ornament:SetPos( self:GetPos() + pos )
		ornament:SetParent( self )
		ornament:SetSkin( math.random( 0, 2 ) )

		table.insert( self.Ornaments, ornament )

	end

	ENT.SpriteMat = Material( "sprites/powerup_effects" )

	function ENT:Draw()

		self:DrawModel()

		local color = colorutil.Rainbow(RealTime() / 500)

		if self.Lights then
			render.SetMaterial( self.SpriteMat )
			color = colorutil.Rainbow(RealTime()/500)

			if IsValid( self ) then
				for _, pos in pairs( self.Lights ) do
					render.DrawSprite( self:GetPos() + pos, 20, 20, color )
				end
			end

			color = colorutil.Rainbow(RealTime() / 100)
			if IsValid( self.Star ) then
				render.DrawSprite( self.Star:GetPos(), 60, 60, color )
			end
		end
	
		--[[local dlight = DynamicLight( self:EntIndex() )
		if dlight then
			dlight.Pos = self:GetPos()
			dlight.r = color.r
			dlight.g = color.g
			dlight.b = color.b
			dlight.Brightness = .5
			dlight.Decay = 512
			dlight.size = 256
			dlight.DieTime = CurTime() + .1
		end]]

	end

	function ENT:Think()

		if self.LastPos ~= self:GetPos() then
			self.LastPos = self:GetPos()
			self:RegenLights()
		end

	end

	function ENT:OnRemove()
		for _, ent in pairs( self.Ornaments ) do
			ent:Remove()
		end
		if IsValid( self.Star ) then
			self.Star:Remove()
		end
	end

end