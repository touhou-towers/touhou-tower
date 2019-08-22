
-----------------------------------------------------
if true then return end
--Create particle system (8000 max particles, .5x emission rate)
local psystem = particle_system.new(8000,.3)

--Timer
local next_emit = RealTime()

hook.Add( "PreRender", "think_particles", function()

	--Update all particle emitters
	particle_emitter.UpdateAll()

	--Update particle system (delta time)
	psystem:Update(FrameTime())

	--Spawn emitters at random positions and intervals
	if next_emit < RealTime() then

		--Create emitter (class, particle system)
		local emitter = particle_emitter.new("camera_flash", psystem)

		--Set multiplier for size of emitted particles
		emitter:Set("size", math.random(10,20)/10 )
		emitter:Set("rand_rot", 360)
		emitter:Set("life", 1)
		emitter:Set("weight", -1)

		//local pickups = ents.FindByClass("sk_item_rocket")
		//local pk = pickups[math.random(1,#pickups)]
		/*if pk then
			local dist = (pk:GetPos() - LocalPlayer():GetKart():GetPos()):Length() / 5
			local v = pk:GetPos():ToScreen()
		end

		emitter:Set("size", 80 / dist )*/

		local v = {}
		v.x = math.random( 0, ScrW() )
		v.y = math.random( 0, ScrH() )

		--Start emitter
		emitter:Start(
			v.x, --x
			v.y, --y
			.5 --life of emitter (seconds) [nil = forever]
		)

		--Set next emit time
		next_emit = RealTime() + math.Rand( .05, .07 )
	end

end )

hook.Add( "HUDPaint", "draw_particles", function()

	--Draw all particles (delta time)
	psystem:Draw(FrameTime())

end )