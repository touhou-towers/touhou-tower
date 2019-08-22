
-----------------------------------------------------
include( "shared.lua" )

-- TODO
-- Make cart position not 100% dependnt on curtime (cart.PosAroundCircle or something)
-- sounds
-- models

/*********** Really fricken fancy cart model's offsets
local CartInfo = 
{
	FirstCart = 
	{
		model = Model("models/swwsl.mdl"),
		offset = Vector( -105, 950, -25)
	},
	SecondCart = 
	{
		model = Model("models/swwsl_tender.mdl"),
		offset = Vector( -55, 310, -10)
	},
	MiddleCart = 
	{
		model = Model("models/swwsl_pass.mdl"),
		offset = Vector( -55, 0, -10)
	},
	Caboose = 
	{
		model = Model("models/swwsl_braker.mdl"),
		offset = Vector( -55, 0, -10)
	},
}
*/

local CartInfo = 
{
	FirstCart = 
	{
		model = Model("models/minitrains/loco/swloco007.mdl"),
		offset = Vector( 2, 0, -3),
		smokeOffset = Vector(13.53,0,20)
	},
	MiddleCart = 
	{
		model = Model("models/minitrains/wagon/swwagon003.mdl"),
		offset = Vector( 2, 0, -3)
	},
	Caboose = 
	{
		model = Model("models/minitrains/wagon/swwagon004.mdl"),
		offset = Vector( 2, 0, -3)
	},
}

local ChuggaSound = Sound( "train/track.wav" )
local ChooChooSound = Sound( "train/whistle.wav")

-- Fine tune cart spacing/scaling
ENT.CartSpaceFactor = 2.2 -- The factor that controls the spacing between carts
ENT.CartScaleFactor = 0.1 -- The scale factor that controls the relative scale of the carts
ENT.SmokeScaleFactor = 1.31916352 -- The scale factor that controls the scale of the smoke
ENT.Rotate90 = true -- quick fix because some models are rotated 90 degrees
ENT.SmokeEjectVelocity = Vector( 0, 0, 160 ) -- The vertical velocity the smoke is ejected from the engine

-- Re-add the old scaling functionality
local scalefix = Matrix()
local function SetModelScale( ent, scale )
		if !IsValid( ent ) then return end
		scalefix = Matrix()
		scalefix:Scale( scale )

		ent:EnableMatrix("RenderMultiply", scalefix)
end

-- Given an index, return the proper cart type (first is engine, last is caboose, etc.)
local function GetCartInfo( index, max )
	if index==1 and CartInfo.FirstCart then return CartInfo.FirstCart end
	if index==2 and CartInfo.SecondCart then return CartInfo.SecondCart end
	if index==max and CartInfo.Caboose then return CartInfo.Caboose end

	return CartInfo.MiddleCart
end

function ENT:Initialize()
	self.Size = self:OBBMaxs() - self:OBBMins()
	self.ScaleFactor = self.ScaleFactor or 1
end

function ENT:Think()

	-- Update this all the time because it doesn't require a rebuild
	self.TrainVelocity = self:GetTrainVelocity()

	-- Make sure we've actually got something loaded
	if (self.TrainModels) then
		-- WEEEE. Make the train go!
		for k, v in pairs( self.TrainModels ) do
			-- Check to see if we're gonna have some ISSUES
			if (!IsValid( v ) || !v.Size || !v.Scale || !v.cartInformation ) then self:RebuildTrain() return end
			local offset = v.cartInformation.offset 
			local angleOffset = math.asin( ( ( self.Rotate90 and v.Size.x or v.Size.y ) * v.Scale * self.CartSpaceFactor + v.Scale * offset.y )/ ( self.Radius * 2) ) * -k 
			local angFromCenter = (CurTime() * self.TrainVelocity / self.Radius) + angleOffset
			local distFromCenter = self.Radius - ((self.Rotate90 and v.Size.y or v.Size.x ) * v.Scale + offset.x * v.Scale)

			local yaw = angFromCenter * 57.2957795 + (self.Rotate90 and 90 or 0)
			local pos = Vector( math.cos(angFromCenter) * distFromCenter, math.sin( angFromCenter) * distFromCenter, (self.Size.z/2) * self.ScaleFactor ) + Vector(0, 0, offset.z * v.Scale )

			local angles = self:GetAngles()
			pos:Rotate( angles )
			//ang = ang * self:GetAngles()
			//local temp = ang:Forward() 


			angles:RotateAroundAxis( angles:Up(), yaw )

			v:SetPos( pos + self:GetPos() )
			v:SetAngles( angles )
		end
	end

	-- Because there's no event for when a networkvar changes, we have to do this icky check stuff
	if (!self.NextPropertyUpdate || self.NextPropertyUpdate < CurTime() ) then

		local newRad = self:GetRadius()
		local newNum = self:GetTrainCount()

		-- If any of these have changed, rebuild ourselves
		if (newRad != self.Radius || newNum != self.TrainCount ) || !self.TrainModels then
			self.Radius = newRad 
			self.TrainCount = newNum

			self:RebuildTrain()
		end

		-- this won't happen very often
		self.NextPropertyUpdate = CurTime() + 1
	end

	-- Think about playing some festive choo choo sound
	self:SoundThink( self )
	self:DrawSmoke()
end

-- Think about playing sounds/whistles
function ENT:SoundThink( ent )
	if (!self.TrainModels || !IsValid(self.TrainModels[1])) then return end

	if (!ent.Chugga || !ent.ChooChoo ) then self:RefreshSounds( ent ) end

	-- Play the chugga
	if (ent.Chugga and !ent.Chugga:IsPlaying()) then
		ent.Chugga:Stop()
		ent.Chugga:PlayEx(0.1, 100)
	end

	-- CHOO CHOO
	if (ent.ChooChoo && (!self.NextChooChoo || self.NextChooChoo < CurTime())) then
		ent.ChooChoo:Stop()
		ent.ChooChoo:PlayEx(0.1, math.random(90, 110))
		//engineMod:EmitSound( ChooChooSound )

		self.NextChooChoo = CurTime() + math.random( 5, 25 )
	end
end

function ENT:RefreshSounds( ent )
	ent.Chugga = CreateSound( ent, ChuggaSound )
	ent.ChooChoo = CreateSound( ent, ChooChooSound )
end

function ENT:RebuildTrain()
	self.ScaleFactor = self.Radius/(self.Size.x/2)
	SetModelScale( self, Vector( self.ScaleFactor, self.ScaleFactor, self.ScaleFactor ) )

	-- Set the render bounds
	self:SetRenderBounds( -self.Size * self.ScaleFactor,self.Size * self.ScaleFactor)

	if (!self.TrainModels) then self.TrainModels = {}
	else -- if it's a valid list, remove all the clientside models
		self:ClearTrains()
	end

	-- Create a train with a specified number of carts
	for i=1, self.TrainCount do
		local info = GetCartInfo( i, self.TrainCount )
		local model = ClientsideModel( info.model )

		-- Store their physical width too
		local min, max = model:GetRenderBounds()
		model.Size = max - min

		-- Alright right here is a bit more fiddly, modify the last constant at will
		local scaleFactor = (self.Radius / model.Size.x) * self.CartScaleFactor

		model.Scale = scaleFactor

		SetModelScale( model, Vector( scaleFactor, scaleFactor, scaleFactor) )

		--Set their render bounds
		model:SetRenderBounds( model.Size * -model.Scale, model.Size * model.Scale )

		-- Store their information on them
		model.cartInformation = info

		-- slap em into the list
		self.TrainModels[i] = model
	end

	-- Because CSoundPatch requires an entity to specify the location, we associate it with a clientside model
	-- Guess who has two thumbs and just created some clientside models (this guy)
	-- NEVERMIND DOESN'T WORK ON CLIENTSIDE MODELS >:(
	-- self:RefreshSounds( self.TrainModels[1] )
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:DrawSmoke()

	if not self.Emitter then
		self.Emitter = ParticleEmitter( self:GetPos() )
	end

	if !self.NextParticle then
		self.NextParticle = CurTime() + .001
	end

	if CurTime() > self.NextParticle then
		self.NextParticle = CurTime() + .001
	end

	local engineCart = self.TrainModels[1]

	-- Do a quick check o rama
	if not IsValid(engineCart) or not engineCart.cartInformation then return end

	local smokeOffset = Vector( engineCart.cartInformation.smokeOffset.x, engineCart.cartInformation.smokeOffset.y, engineCart.cartInformation.smokeOffset.z )
	local smokeVelocity = Vector( self.SmokeEjectVelocity.x, self.SmokeEjectVelocity.y, self.SmokeEjectVelocity.z )
	smokeVelocity:Rotate( self:GetAngles())
	smokeOffset:Rotate( engineCart:GetAngles() )
	local pos = engineCart:GetPos() + smokeOffset * engineCart.Scale

	local smokeScale = engineCart.Scale * self.SmokeScaleFactor

	for i=1, 2 do

		if math.random( 3 ) > 1 then

			local particle = self.Emitter:Add( "particles/smokey", pos )
			if particle then
				particle:SetVelocity( (VectorRand() * 10 + smokeVelocity )* smokeScale ) 
				particle:SetLifeTime( 0 ) 
				particle:SetDieTime( math.Rand( 1.5, 2 ) ) 
				particle:SetStartAlpha( math.Rand( 100, 150 ) ) 
				particle:SetEndAlpha( 0 ) 
				particle:SetStartSize( math.random( 0, smokeScale ) ) 
				particle:SetEndSize( math.random( 10, 15 ) * smokeScale ) 
				particle:SetRoll( math.Rand( -10, 10 ) )
				particle:SetRollDelta( math.Rand( -5, 5 ) )

				local dark = math.Rand( 100, 200 )
				particle:SetColor( dark, dark, dark ) 
				particle:SetAirResistance( 800 )
				particle:SetGravity( Vector( 0, 0, math.random( 150, 200 ) ) )
				particle:SetCollide( true )
				particle:SetBounce( 0.2 )
			end

		end

	end

end

function ENT:ClearTrains()
	if (!self.TrainModels) then return end

	for _, v in pairs( self.TrainModels ) do
		if IsValid( v ) then v:Remove() end
	end
end

function ENT:OnRemove()
	self:ClearTrains()
	
	if self.ChooChoo then
		self.ChooChoo:Stop()
	end
	if self.Chugga then
		self.Chugga:Stop()
	end

	if IsValid( self.Emitter ) then
		self.Emitter:Finish()
		self.Emitter = nil
	end

end