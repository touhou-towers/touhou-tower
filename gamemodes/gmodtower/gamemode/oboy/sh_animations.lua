

-----------------------------------------------------
function GM:CalcMainActivity( ply, velocity )

	ply.CalcIdeal = ACT_MP_STAND_IDLE
	ply.CalcSeqOverride = -1

	self:HandlePlayerLanding( ply, velocity, ply.m_bWasOnGround );
	
	if ( self:HandlePlayerNoClipping( ply, velocity ) ||
		self:HandlePlayerDriving( ply ) ||
		self:HandlePlayerVaulting( ply, velocity ) ||
		self:HandlePlayerJumping( ply, velocity ) ||
		self:HandlePlayerDucking( ply, velocity ) ||
		self:HandlePlayerSwimming( ply, velocity ) ) then
		
	else

		local len2d = velocity:Length2D()
		if ( len2d > 150 ) then ply.CalcIdeal = ACT_MP_RUN elseif ( len2d > 0.5 ) then ply.CalcIdeal = ACT_MP_WALK end

	end
	
	-- a bit of a hack because we're missing ACTs for a couple holdtypes
	local weapon = ply:GetActiveWeapon()
	local ht = "pistol"

	if ( IsValid( weapon ) ) then ht = weapon:GetHoldType() end
	
	if ( ply.CalcIdeal == ACT_MP_CROUCH_IDLE &&	( ht == "knife" || ht == "melee2" ) ) then
		ply.CalcSeqOverride = ply:LookupSequence("cidle_" .. ht)
	end

	// ===ANIMATION OVERRIDES===
	-- Store the model so we don't retrieve it multiple times
	local model = ply:GetModel()
	// Roleplay as a zombie
	if model == "models/player/zombie_classic.mdl" --[[&& Hats.IsWearing( ply, "hatheadcrab" )]] && ply:IsOnGround() then
		ply.CalcSeqOverride = ply:LookupSequence( "zombie_idle" )
		local len2d = velocity:Length2D()
		if ( len2d > 250 ) then
			ply.CalcSeqOverride = ply:LookupSequence( "zombie_run" )
		elseif ( len2d > 0.5 ) then
			ply.CalcSeqOverride = ply:LookupSequence( "zombie_walk_03" )
		end
	end
	// fastie
	if model == "models/player/zombie_fast.mdl" --[[&& Hats.IsWearing( ply, "hatheadcrab" )]] && ply:IsOnGround() then

		ply.CalcSeqOverride = ply:LookupSequence( "zombie_idle" )

		local len2d = velocity:Length2D()
		if ( len2d > 250 ) then
			ply.CalcIdeal = ACT_HL2MP_RUN_ZOMBIE_FAST
		end

	end
	// Dog animations
	if model == "models/zom/dog.mdl" then

		ply.CalcSeqOverride = ply:LookupSequence( "idle_scratch" )

		local len2d = velocity:Length2D()
		if ( len2d > 250 ) then
			ply.CalcSeqOverride = ply:LookupSequence( "run" )
		elseif ( len2d > 0.5 ) then
			ply.CalcSeqOverride = ply:LookupSequence( "walk" )
		end

		if !ply:IsOnGround() then
			ply.CalcSeqOverride = ply:LookupSequence( "equip" )
		end

		if ply:Crouching() then
			ply.CalcSeqOverride = ply:LookupSequence( "idle_sit" )
			
			if ( len2d > 0.5 ) then
				ply.CalcSeqOverride = ply:LookupSequence( "walk_sniff" )
			end
		end

		if ply:InVehicle() then
			ply.CalcSeqOverride = ply:LookupSequence( "idle_sit" )
		end

	end

	// Trex animations
	if model== "models/dinosaurs/trex.mdl" then

		ply.CalcSeqOverride = ply:LookupSequence( "idle" )

		local len2d = velocity:Length2D()
		if ( len2d > 250 ) then
			ply.CalcSeqOverride = ply:LookupSequence( "run1" )
		elseif ( len2d > 0.5 ) then
			ply.CalcSeqOverride = ply:LookupSequence( "walk1" )
		end

		if !ply:IsOnGround() then
			ply.CalcSeqOverride = ply:LookupSequence( "pain" )
		end

		if ply:Crouching() then
			ply.CalcSeqOverride = ply:LookupSequence( "biteattack1" )
			
			if ( len2d > 0.5 ) then
				ply.CalcSeqOverride = ply:LookupSequence( "charge_loop" )
			end
		end

	end

	// Spider animations
	if model == "models/npc/spider_regular/npc_spider_regular.mdl" then

		ply.CalcSeqOverride = ply:LookupSequence( "Idle_1" )

		local len2d = velocity:Length2D()
		if ( len2d > 250 ) then
			ply.CalcSeqOverride = ply:LookupSequence( "Run" )
		elseif ( len2d > 0.5 ) then
			ply.CalcSeqOverride = ply:LookupSequence( "Walk" )
		end

		if !ply:IsOnGround() then
			ply.CalcSeqOverride = ply:LookupSequence( "Attack_1" )
		end

		if ply:Crouching() then
			ply.CalcSeqOverride = ply:LookupSequence( "Backfalling" )
			
			if ( len2d > 0.5 ) then
				ply.CalcSeqOverride = ply:LookupSequence( "CombatWalk" )
			end
		end

	end

	// Big spider animations
	if model == "models/npc/spider_monster/npc_spider_monster.mdl" then

		ply.CalcSeqOverride = ply:LookupSequence( "Idle_1" )

		local len2d = velocity:Length2D()
		if ( len2d > 250 ) then
			ply.CalcSeqOverride = ply:LookupSequence( "Run" )
		elseif ( len2d > 0.5 ) then
			ply.CalcSeqOverride = ply:LookupSequence( "Walk" )
		end

		if !ply:IsOnGround() then
			ply.CalcSeqOverride = ply:LookupSequence( "Attack_1" )
		end

		if ply:Crouching() then
			ply.CalcSeqOverride = ply:LookupSequence( "Low_attack_1" )
			
			if ( len2d > 0.5 ) then
				ply.CalcSeqOverride = ply:LookupSequence( "Search_1" )
			end
		end

	end

	// Walk fixes
	if model == "models/player/hhp227/kilik.mdl" then

		// For some reason he lacks a proper walk animation...
		local len2d = velocity:Length2D()
		if ( len2d > 0 ) && ( len2d < 250 ) && ply:IsOnGround() && !ply:Crouching() then
			ply.CalcIdeal = ACT_MP_RUN
		end

	end

	// Midna float
	if model == "models/player/midna.mdl" then

		local len2d = velocity:Length2D()
		if ply:GetMoveType() == MOVETYPE_NOCLIP && len2d == 0 && !ply:InVehicle() then
			ply.CalcSeqOverride = ply:LookupSequence( "midna_float" )
		end

	end	

	// ===END ANIMATION OVERRIDES===


	ply.m_bWasOnGround = ply:IsOnGround()
	ply.m_bWasNoclipping = (ply:GetMoveType() == MOVETYPE_NOCLIP)

	return ply.CalcIdeal, ply.CalcSeqOverride

end

function GM:HandlePlayerLanding( ply, velocity, WasOnGround ) 
	// Removes Max's DUMB ASS LANDING ANIMATION THAT LOOKS LIKE SHIT
end


function GM:HandlePlayerJumping( ply, velocity )
	--if ( ply:GetMoveType() == MOVETYPE_NOCLIP ) then
	--	ply.m_bJumping = false;
	--	return
	--end

	if ( !ply.m_bJumping && !ply:OnGround() && ply:WaterLevel() <= 0 ) then
	
		if ( !ply.m_fGroundTime ) then

			ply.m_fGroundTime = CurTime()
			
		elseif (CurTime() - ply.m_fGroundTime) > 0 && velocity.z > 100 then
			ply.m_bJumping = true
			ply.m_bFirstJumpFrame = false
			ply.m_flJumpStartTime = 0

		end
	end
	
	if ply.m_bJumping then
	
		if ply.m_bFirstJumpFrame then

			ply.m_bFirstJumpFrame = false
			ply:AnimRestartMainSequence()

		end
		
		if ( ply:WaterLevel() >= 2 ) ||	( (CurTime() - ply.m_flJumpStartTime) > 0.2 && ply:OnGround() ) then

			ply.m_bJumping = false
			ply.m_fGroundTime = nil
			ply:AnimRestartMainSequence()

		end
		
		if ply.m_bJumping then
			ply.CalcIdeal = ACT_MP_JUMP
			return true
		end
	end
	
	return false
end

function GM:HandlePlayerNoClipping( ply, velocity )

	if ply:InVehicle() || ply:GetMoveType() != MOVETYPE_NOCLIP then
		return
	end

	// Override noclip to be like swimming
	if ( velocity:Length2D() > 10 ) then
		ply.CalcIdeal = ACT_MP_SWIM
	else
		ply.CalcIdeal = ACT_MP_SWIM

		// Fix swimming animation
		local weapon = ply:GetActiveWeapon()
		if IsValid( weapon ) && weapon:GetClass() == "gmt_hands" then
			ply.CalcIdeal = ACT_MP_SWIM
			ply.CalcSeqOverride = ply:LookupSequence( "swimming" )
		end

	end

	return true

	/*if ( ply:InVehicle() ) || ( ply:GetMoveType() != MOVETYPE_NOCLIP ) then 

		if ( ply.m_bWasNoclipping ) then

			ply.m_bWasNoclipping = nil
			ply:AnimResetGestureSlot( GESTURE_SLOT_CUSTOM )
			if ( CLIENT ) then ply:SetIK( true ); end

		end

		return

	end

	if ( !ply.m_bWasNoclipping ) then

		ply:AnimRestartGesture( GESTURE_SLOT_CUSTOM, ACT_GMOD_NOCLIP_LAYER, false )
		if ( CLIENT ) then ply:SetIK( false ); end

	end

			
	return true*/

end

if SERVER then

	/*hook.Add( "PlayerThink", "ForceHandsInWater", function( ply )

		if !ply.m_bInSwim then return end

		if !ply:GetActiveWeapon() then
			GTowerItems:GiveDefaultWeapon( ply )
		end

	end )*/

else

	concommand.Add( "gmt_listanims", function( ply ) 

		if !ply:IsAdmin() then return end
			
		for _, seq in pairs( ply:GetSequenceList() ) do
			MsgN( seq )
		end

		if IsValid( ply:GetActiveWeapon() ) then

			MsgN( "===Weapon anims===")

			for _, seq in pairs( ply:GetActiveWeapon():GetSequenceList() ) do
				MsgN( seq )
			end

		end

	end )

end