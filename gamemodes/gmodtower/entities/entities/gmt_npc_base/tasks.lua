


/*---------------------------------------------------------
   Task: PlaySequence

   Accepts:

    data.ID 	- sequence id
	data.Name 	- sequence name (Must provide either id or name)
	data.Wait	- Optional. Should we wait for sequence to finish
	data.Speed	- Optional. Playback speed of sequence

---------------------------------------------------------*/
function ENT:TaskStart_PlaySequence( data )
	local SequenceID = data.ID

	if ( data.Name ) then SequenceID = self:LookupSequence( data.Name )	end

	self:ResetSequence( SequenceID )
	self:SetNPCState( NPC_STATE_SCRIPT )

	local Duration = self:SequenceDuration()

	if ( data.Speed && data.Speed > 0 ) then

		SequenceID = self:SetPlaybackRate( data.Speed )
		Duration = Duration / data.Speed

	end

	self.TaskSequenceEnd = CurTime() + Duration
	local function ResetIdle()
		if !self or !IsValid( self ) or self:Health() <= 0 then return end
		self:TaskComplete()
		self:SetNPCState( NPC_STATE_NONE )
		self.TaskSequenceEnd = nil
		self:SelectSchedule()
		//self:SetHealth( self:Health() +1 )	// really, REALLY bad solution for the broken conditions after playing an animation
		//self:TakeDamage( 1 )	// but it works
	end
	timer.Create( tostring(self) .. "_anim_reset_idle_timer", Duration, 1, ResetIdle )

end
/*---------------------------------------------------------*/
function ENT:Task_PlaySequence( data )

	// Wait until sequence is finished
	if ( CurTime() < self.TaskSequenceEnd ) then return end


	self:TaskComplete()
	self:SetNPCState( NPC_STATE_NONE )
	/*local schdIdle = ai_schedule.New( "Idle" )
	schdIdle:EngTask( "TASK_STOP_MOVING", 0 )
	schdIdle:EngTask( "TASK_PLAY_SEQUENCE", ACT_IDLE )
	self:StartSchedule( schdIdle )
	Msg( "Starting idle schedule... \n" )*/

	// Clean up
	self.TaskSequenceEnd = nil

end



/*---------------------------------------------------------
   Task: FindEnemy

   Accepts:

    data.ID 	- sequence id
	data.Name 	- sequence name (Must provide either id or name)
	data.Wait	- Optional. Should we wait for sequence to finish
	data.Speed	- Optional. Playback speed of sequence

---------------------------------------------------------*/

function ENT:TaskStart_FindEnemy( data )

	local et =  ents.FindInSphere( self:GetPos(), data.Radius or 512 )
	for k, v in ipairs( et ) do

		if (  v:IsValid() && v != self && v:GetClass() == data.Class  ) then
			self:SetEnemy( v, true )
			self:UpdateEnemyMemory( v, v:GetPos() )
			self:TaskComplete()
			return
		end

	end

	self:SetEnemy( NULL )

end

function ENT:Task_FindEnemy( data )
end
